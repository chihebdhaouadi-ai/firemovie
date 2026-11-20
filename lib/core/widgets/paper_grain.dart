import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// A faint paper grain laid over the whole app so the light mode reads as
/// warm, slightly worn paper rather than clinical white.
///
/// The specks are drawn once from a fixed seed and never repaint, and the
/// layer ignores touches. A fully transparent [color] (the dark palette)
/// skips the layer entirely.
class PaperGrain extends StatelessWidget {
  const PaperGrain({super.key, required this.color, required this.child});

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (color.a == 0) return child;
    return Stack(
      fit: StackFit.passthrough,
      children: [
        child,
        Positioned.fill(
          child: IgnorePointer(
            child: ExcludeSemantics(
              child: RepaintBoundary(
                child: CustomPaint(painter: _GrainPainter(color)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _GrainPainter extends CustomPainter {
  _GrainPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(7);
    final count = (size.width * size.height / 90).round();
    final fine = <Offset>[];
    final coarse = <Offset>[];
    for (var i = 0; i < count; i++) {
      final point = Offset(
        random.nextDouble() * size.width,
        random.nextDouble() * size.height,
      );
      (random.nextDouble() < 0.12 ? coarse : fine).add(point);
    }
    canvas.drawPoints(
      ui.PointMode.points,
      fine,
      Paint()
        ..color = color.withValues(alpha: 0.07)
        ..strokeWidth = 1,
    );
    canvas.drawPoints(
      ui.PointMode.points,
      coarse,
      Paint()
        ..color = color.withValues(alpha: 0.10)
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_GrainPainter oldDelegate) => oldDelegate.color != color;
}
