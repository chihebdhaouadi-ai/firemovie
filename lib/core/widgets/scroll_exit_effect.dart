import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../motion.dart';

/// Where the exit line sits, in pixels below the top of the scroll viewport,
/// for a given scroll offset (a collapsing header moves it as it shrinks).
typedef ExitInset = double Function(double scrollPixels);

/// Fades out the part of its child that has scrolled past a pinned,
/// see-through header, and narrows the child toward its center as it goes.
///
/// The child is fully visible below the exit line ([exitInset]) and fades to
/// nothing over [fade] pixels above it, with a soft edge rather than a hard
/// band. The rest of the child is untouched until it reaches the line. The narrowing grows with how far the
/// child has gone under, reaching [maxShrink] after [range] pixels.
class ScrollExitEffect extends StatefulWidget {
  const ScrollExitEffect({
    super.key,
    required this.child,
    required this.exitInset,
    this.fade = 56,
    this.range = 180,
    this.maxShrink = 0.2,
  });

  final Widget child;

  /// The exit line for the current scroll offset.
  final ExitInset exitInset;

  /// Distance above the line over which the child fades out.
  final double fade;

  /// Distance under the line over which the narrowing reaches full strength
  /// (or the child's height, if shorter).
  final double range;

  /// Fraction of the width removed at full strength, split evenly between the
  /// left and right edges.
  final double maxShrink;

  @override
  State<ScrollExitEffect> createState() => _ScrollExitEffectState();
}

class _ScrollExitEffectState extends State<ScrollExitEffect> {
  /// Height, in pixels, of the child's slice that sits above the exit line.
  final ValueNotifier<double> _covered = ValueNotifier<double>(0);
  ScrollableState? _scrollable;

  /// How far under the line the child must go for full narrowing.
  double _reach = 1;

  /// The child's height at the last measurement.
  double _height = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!scrollEffectsEnabled) return;
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
    if (scrollEffectsEnabled) _schedule();
  }

  @override
  void dispose() {
    _scrollable?.position.removeListener(_measure);
    _covered.dispose();
    super.dispose();
  }

  /// Measures after the current frame's layout, so the positions are fresh.
  void _schedule() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
  }

  void _measure() {
    if (!mounted) return;
    final scrollable = _scrollable;
    final child = context.findRenderObject();
    final viewport = scrollable?.context.findRenderObject();
    if (scrollable == null) return;
    if (child is! RenderBox || !child.hasSize) return;
    if (viewport is! RenderBox || !viewport.hasSize) return;

    final pixels =
        scrollable.position.hasPixels ? scrollable.position.pixels : 0.0;
    final top = child.localToGlobal(Offset.zero).dy;
    final exitLine =
        viewport.localToGlobal(Offset.zero).dy + widget.exitInset(pixels);
    // Past the child's height too, so its bottom edge finishes fading.
    final covered =
        (exitLine - top).clamp(0.0, child.size.height + widget.fade);
    _reach = math.min(widget.range, child.size.height);
    _height = child.size.height;
    if (covered != _covered.value) _covered.value = covered;
  }

  @override
  Widget build(BuildContext context) {
    // Web: no scroll effect at all; the header is opaque there instead.
    if (!scrollEffectsEnabled) return widget.child;
    // Re-measure after every rebuild, since the child may have resized.
    _schedule();
    return ValueListenableBuilder<double>(
      valueListenable: _covered,
      child: widget.child,
      builder: (context, covered, child) {
        final reach = _reach;
        final t = reach <= 0 ? 0.0 : (covered / reach).clamp(0.0, 1.0);
        // Fully faded: paint nothing at all, so no edge can show through.
        final gone = covered >= _height + widget.fade;
        // Always the same tree (at rest the mask is fully opaque, the scale
        // is 1 and the opacity is 1), so the child keeps its state. The mask
        // sits outside the narrowing so it also covers the narrowed edges.
        return Opacity(
          opacity: gone ? 0 : 1,
          child: ShaderMask(
            blendMode: BlendMode.dstIn,
            shaderCallback: (rect) {
              final h = rect.height <= 0 ? 1.0 : rect.height;
              final fade = widget.fade;
              // Opaque below the line (at [covered]), fading to nothing
              // [fade] px above it.
              double alphaAt(double y) =>
                  ((y - (covered - fade)) / fade).clamp(0.0, 1.0);
              final y0 = (covered - fade).clamp(0.0, h);
              final y1 = covered.clamp(y0, h);
              return LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromRGBO(0, 0, 0, alphaAt(y0)),
                  Color.fromRGBO(0, 0, 0, alphaAt(y1)),
                ],
                stops: [y0 / h, y1 / h],
              ).createShader(rect);
            },
            child: Transform(
              alignment: Alignment.center,
              transform:
                  Matrix4.diagonal3Values(1 - widget.maxShrink * t, 1, 1),
              child: child,
            ),
          ),
        );
      },
    );
  }
}
