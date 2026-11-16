import 'package:flutter/material.dart';

import 'sage_nav_tokens.dart';

class BarShapePainter extends CustomPainter {
  const BarShapePainter({
    this.domeDepth = SageNavTokens.domeDepth,
    this.color = SageNavTokens.barColor,
    this.shadowColor = SageNavTokens.barShadow,
  });

  final double domeDepth;
  final Color color;
  final Color shadowColor;

  Path barPath(Size size) {
    final w = size.width;
    final d = domeDepth;
    return Path()
      ..moveTo(0, d)
      ..cubicTo(w * 0.28, d, w * 0.32, 0, w / 2, 0)
      ..cubicTo(w * 0.68, 0, w * 0.72, d, w, d)
      ..lineTo(w, size.height)
      ..lineTo(0, size.height)
      ..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final path = barPath(size);
    final shadow = Paint()
      ..color = shadowColor
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawPath(path.shift(const Offset(0, -6)), shadow);
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(BarShapePainter oldDelegate) =>
      oldDelegate.domeDepth != domeDepth ||
      oldDelegate.color != color ||
      oldDelegate.shadowColor != shadowColor;
}
