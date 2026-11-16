import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

const angelBirdHoldTag = 'angelBirdHold';

List<HitTestEntry> hitPathAt(BuildContext context, Offset position) {
  final result = HitTestResult();
  GestureBinding.instance
      .hitTestInView(result, position, View.of(context).viewId);
  return result.path.toList();
}

bool isInHoldRegion(List<HitTestEntry> path) => path.any((entry) {
      final target = entry.target;
      return target is RenderMetaData && target.metaData == angelBirdHoldTag;
    });

bool isTapTargetUnder(BuildContext scope, List<HitTestEntry> path) {
  final hit = [
    for (final entry in path)
      if (entry.target case final RenderObject render) render,
  ];
  final tappable = <RenderObject>[];
  void collect(Element element) {
    final render = element.renderObject;
    if (render != null && _isTappable(element.widget)) tappable.add(render);
    element.visitChildren(collect);
  }

  scope.visitChildElements(collect);
  return tappable.any((render) => hit.any((t) => _isWithin(t, render)));
}

bool _isTappable(Widget widget) => switch (widget) {
      GestureDetector w => w.onTap != null ||
          w.onTapDown != null ||
          w.onDoubleTap != null ||
          w.onLongPress != null,
      InkResponse w =>
        w.onTap != null || w.onDoubleTap != null || w.onLongPress != null,
      ButtonStyleButton w => w.onPressed != null || w.onLongPress != null,
      EditableText _ => true,
      _ => false,
    };

bool _isWithin(RenderObject node, RenderObject ancestor) {
  Object? current = node;
  while (current is RenderObject) {
    if (identical(current, ancestor)) return true;
    current = current.parent;
  }
  return false;
}

class BirdHoldRegion extends StatefulWidget {
  const BirdHoldRegion({
    super.key,
    required this.onHold,
    required this.child,
    this.duration = const Duration(milliseconds: 1700),
  });

  final VoidCallback onHold;
  final Duration duration;
  final Widget child;

  @override
  State<BirdHoldRegion> createState() => _BirdHoldRegionState();
}

class _BirdHoldRegionState extends State<BirdHoldRegion> {
  Timer? _timer;
  Offset? _start;

  @override
  void dispose() {
    _cancel();
    super.dispose();
  }

  void _down(PointerDownEvent event) {
    _cancel();
    if (isTapTargetUnder(context, hitPathAt(context, event.position))) return;
    _start = event.position;
    _timer = Timer(widget.duration, _fire);
  }

  void _move(PointerMoveEvent event) {
    final start = _start;
    if (start != null && (event.position - start).distance > kTouchSlop) {
      _cancel();
    }
  }

  void _fire() {
    _timer = null;
    _start = null;
    widget.onHold();
  }

  void _cancel() {
    _timer?.cancel();
    _timer = null;
    _start = null;
  }

  @override
  Widget build(BuildContext context) {
    return MetaData(
      metaData: angelBirdHoldTag,
      behavior: HitTestBehavior.translucent,
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: _down,
        onPointerMove: _move,
        onPointerUp: (_) => _cancel(),
        onPointerCancel: (_) => _cancel(),
        child: widget.child,
      ),
    );
  }
}
