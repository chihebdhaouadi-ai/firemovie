import 'dart:math' as math;

import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:film_wise_mobile/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

enum SocialProvider { google, apple }

class SocialAuthButton extends StatelessWidget {
  const SocialAuthButton({
    super.key,
    required this.provider,
    required this.onPressed,
  });

  final SocialProvider provider;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final isApple = provider == SocialProvider.apple;
    final label = isApple ? 'Continue with Apple' : 'Continue with Google';

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: isApple ? Colors.white : const Color(0xFF131314),
        foregroundColor: isApple ? Colors.black : const Color(0xFFE3E3E3),
        minimumSize: const Size.fromHeight(52),
        side: BorderSide(
          color: isApple ? Colors.transparent : const Color(0xFF8E918F),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(context.tokens.radiusMd),
        ),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isApple)
            const Icon(BootstrapIcons.apple, size: 20)
          else
            const SizedBox.square(
              dimension: 20,
              child: CustomPaint(painter: _GoogleGlyphPainter()),
            ),
          const SizedBox(width: 12),
          Text(label),
        ],
      ),
    );
  }
}

class _GoogleGlyphPainter extends CustomPainter {
  const _GoogleGlyphPainter();

  static const _red = Color(0xFFEA4335);
  static const _yellow = Color(0xFFFBBC05);
  static const _green = Color(0xFF34A853);
  static const _blue = Color(0xFF4285F4);

  @override
  void paint(Canvas canvas, Size size) {
    final side = size.shortestSide;
    final stroke = side * 0.2;
    final center = size.center(Offset.zero);
    final rect = Rect.fromCircle(
      center: center,
      radius: side / 2 - stroke / 2,
    );
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;

    void arc(Color color, double startDeg, double sweepDeg) {
      canvas.drawArc(
        rect,
        startDeg * math.pi / 180,
        sweepDeg * math.pi / 180,
        false,
        paint..color = color,
      );
    }

    arc(_red, -150, 120);
    arc(_yellow, 150, 60);
    arc(_green, 45, 105);
    arc(_blue, 0, 45);

    canvas.drawRect(
      Rect.fromLTRB(
        center.dx,
        center.dy - stroke / 2,
        size.width,
        center.dy + stroke / 2,
      ),
      Paint()..color = _blue,
    );
  }

  @override
  bool shouldRepaint(covariant _GoogleGlyphPainter oldDelegate) => false;
}
