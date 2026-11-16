import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

/// Makes its child blur, narrow toward the center and fade as it scrolls out
/// of the top of the enclosing scrollable.
///
/// The effect starts when the child's top edge crosses [exitInset] pixels
/// below the top of the scroll viewport (use the pinned header's height), and
/// reaches full strength after the child has moved [range] pixels further up.
/// Content that is still on screen below that line is left untouched.
class ScrollExitEffect extends StatefulWidget {
  const ScrollExitEffect({
    super.key,
    required this.child,
    this.exitInset = 0,
    this.range = 180,
    this.maxBlur = 10,
    this.maxShrink = 0.2,
    this.minOpacity = 0.4,
  });

  final Widget child;

  /// Y offset from the top of the scroll viewport where the exit begins.
  final double exitInset;

  /// Distance over which the effect ramps from 0 to full strength.
  final double range;

  /// Blur sigma at full strength.
  final double maxBlur;

  /// Fraction of the width removed at full strength, split evenly between the
  /// left and right edges.
  final double maxShrink;

  /// Opacity at full strength.
  final double minOpacity;

  @override
  State<ScrollExitEffect> createState() => _ScrollExitEffectState();
}

class _ScrollExitEffectState extends State<ScrollExitEffect> {
  final ValueNotifier<double> _progress = ValueNotifier<double>(0);
  ScrollableState? _scrollable;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scrollable = Scrollable.maybeOf(context);
    if (!identical(scrollable, _scrollable)) {
      _scrollable?.position.removeListener(_measure);
      _scrollable = scrollable;
      _scrollable?.position.addListener(_measure);
    }
    _schedule();
  }

  @override
  void didUpdateWidget(ScrollExitEffect oldWidget) {
    super.didUpdateWidget(oldWidget);
    _schedule();
  }

  @override
  void dispose() {
    _scrollable?.position.removeListener(_measure);
    _progress.dispose();
    super.dispose();
  }

  /// Measures after the current frame's layout, so the positions are fresh.
  void _schedule() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
  }

  void _measure() {
    if (!mounted) return;
    final child = context.findRenderObject();
    final viewport = _scrollable?.context.findRenderObject();
    if (child is! RenderBox || !child.hasSize) return;
    if (viewport is! RenderBox || !viewport.hasSize) return;

    final top = child.localToGlobal(Offset.zero).dy;
    final exitLine = viewport.localToGlobal(Offset.zero).dy + widget.exitInset;
    final range = math.min(widget.range, math.max(child.size.height, 1.0));
    final t = ((exitLine - top) / range).clamp(0.0, 1.0);
    if (t != _progress.value) _progress.value = t;
  }

  @override
  Widget build(BuildContext context) {
    // Re-measure after every rebuild, since the child may have resized.
    _schedule();
    return ValueListenableBuilder<double>(
      valueListenable: _progress,
      child: widget.child,
      builder: (context, t, child) {
        // Always the same widget tree (a zero blur, scale of 1 and full
        // opacity are no-ops), so the child keeps its state when t crosses 0.
        final sigma = widget.maxBlur * t;
        final scale = 1 - widget.maxShrink * t;
        final opacity = 1 - (1 - widget.minOpacity) * t;
        return RepaintBoundary(
          child: Opacity(
            opacity: opacity,
            child: Transform(
              alignment: Alignment.topCenter,
              transform: Matrix4.diagonal3Values(scale, 1, 1),
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}
