import 'dart:math' as math;

import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:film_wise_mobile/core/l10n_context.dart';
import 'package:film_wise_mobile/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

enum SocialProvider { google, apple, reddit }

const _buttonSize = 56.0;
const _redditOrange = Color(0xFFFF4500);

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
    final l10n = context.l10n;
    final label = switch (provider) {
      SocialProvider.google => l10n.authContinueWithGoogle,
      SocialProvider.apple => l10n.authContinueWithApple,
      SocialProvider.reddit => l10n.authContinueWithReddit,
    };

    return Tooltip(
      message: label,
      child: Semantics(
        button: true,
        label: label,
        child: Material(
          color: AppColors.surface,
          shape: CircleBorder(
            side: BorderSide(
              color: AppColors.outline,
              width: context.tokens.borderWidth,
            ),
          ),
          child: InkWell(
            onTap: onPressed,
            customBorder: const CircleBorder(),
            child: SizedBox.square(
              dimension: _buttonSize,
              child: Center(child: _icon()),
            ),
          ),
        ),
      ),
    );
  }

  Widget _icon() => switch (provider) {
        SocialProvider.google => const SizedBox.square(
            dimension: 22,
            child: CustomPaint(painter: _GoogleGlyphPainter()),
          ),
        SocialProvider.apple => Icon(
            BootstrapIcons.apple,
            size: 24,
            color: AppColors.textPrimary,
          ),
        SocialProvider.reddit => const Icon(
            BootstrapIcons.reddit,
            size: 24,
            color: _redditOrange,
          ),
      };
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
