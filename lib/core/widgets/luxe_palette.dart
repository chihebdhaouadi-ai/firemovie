import 'package:flutter/material.dart';

/// Calm, premium surfaces for SAGE navigation: matte fills, hairline borders
/// and one blue accent with a soft glow.
abstract final class LuxeColors {
  static const bg = Color(0xFF0E0F12);
  static const surface = Color(0xFF16181D);
  static const surface2 = Color(0xFF1D2027);
  static const hair = Color(0x14FFFFFF);
  static const text = Color(0xFFF2F3F5);
  static const muted = Color(0xFF8B90A0);
  static const accent = Color(0xFF4A8CF0);
  static const accentHi = Color(0xFF5B9BFF);
  static const accentLo = Color(0xFF2A57B8);

  static const accentGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [accentHi, accentLo],
  );
}
