import 'package:flutter/material.dart';

import '../theme/app_palette.dart';

/// Calm, premium surfaces for SAGE navigation: matte fills, hairline borders
/// and one accent with a soft glow. Reads the current light or dark palette.
abstract final class LuxeColors {
  static AppPalette get _p => AppPalette.current;

  static Color get bg => _p.luxeBg;
  static Color get surface => _p.luxeSurface;
  static Color get surface2 => _p.luxeSurface2;
  static Color get hair => _p.luxeHair;
  static Color get text => _p.luxeText;
  static Color get muted => _p.luxeMuted;
  static Color get accent => _p.luxeAccent;
  static Color get accentHi => _p.luxeAccentHi;
  static Color get accentLo => _p.luxeAccentLo;

  static LinearGradient get accentGradient => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [accentHi, accentLo],
      );
}
