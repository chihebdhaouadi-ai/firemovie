import 'package:flutter/material.dart';

abstract final class AppColors {
  static const background = Color(0xFF151515);
  static const surface = Color(0xFF1F1F1F);
  static const surfaceRaised = Color(0xFF2A2A2A);
  static const textPrimary = Color(0xFFF2F2F2);
  static const textSecondary = Color(0xFFD9D9D9);
  static const textMuted = Color(0xFFA8A8A8);
  static const accent = Color(0xFF1B8CE0);
  static const accentGlow = Color(0xFF35B6FF);
  static const primaryButton = Color(0xFF084C7C);
  static const outline = Color(0xFF5D697A);
  static const error = Color(0xFFFF6B6B);
  static const onPrimaryButton = Color(0xFFFFFFFF);
}

class AppTokens extends ThemeExtension<AppTokens> {
  const AppTokens({
    required this.spaceXs,
    required this.spaceSm,
    required this.spaceMd,
    required this.spaceLg,
    required this.spaceXl,
    required this.radiusSm,
    required this.radiusMd,
    required this.radiusLg,
    required this.glowShadow,
    required this.durationFast,
    required this.durationBase,
    required this.durationSlow,
    required this.minTouchTarget,
    required this.posterWidth,
    required this.posterHeight,
    required this.topTileSize,
    required this.topTileGap,
    required this.recommendCardWidth,
    required this.recommendCardHeight,
    required this.filmTileWidth,
    required this.filmTileHeight,
    required this.generateButtonHeight,
    required this.maxContentWidth,
  });

  final double spaceXs;
  final double spaceSm;
  final double spaceMd;
  final double spaceLg;
  final double spaceXl;
  final double radiusSm;
  final double radiusMd;
  final double radiusLg;
  final List<BoxShadow> glowShadow;
  final Duration durationFast;
  final Duration durationBase;
  final Duration durationSlow;
  final double minTouchTarget;
  final double posterWidth;
  final double posterHeight;
  final double topTileSize;
  final double topTileGap;
  final double recommendCardWidth;
  final double recommendCardHeight;
  final double filmTileWidth;
  final double filmTileHeight;
  final double generateButtonHeight;
  final double maxContentWidth;

  static const light = AppTokens(
    spaceXs: 4,
    spaceSm: 8,
    spaceMd: 12,
    spaceLg: 16,
    spaceXl: 24,
    radiusSm: 8,
    radiusMd: 12,
    radiusLg: 16,
    glowShadow: [
      BoxShadow(
        color: Color(0x6635B6FF),
        blurRadius: 16,
        spreadRadius: 1,
      ),
    ],
    durationFast: Duration(milliseconds: 150),
    durationBase: Duration(milliseconds: 220),
    durationSlow: Duration(milliseconds: 300),
    minTouchTarget: 48,
    posterWidth: 78,
    posterHeight: 100,
    topTileSize: 64,
    topTileGap: 8,
    recommendCardWidth: 77,
    recommendCardHeight: 112,
    filmTileWidth: 78,
    filmTileHeight: 100,
    generateButtonHeight: 48,
    maxContentWidth: 640,
  );

  @override
  AppTokens copyWith({
    double? spaceXs,
    double? spaceSm,
    double? spaceMd,
    double? spaceLg,
    double? spaceXl,
    double? radiusSm,
    double? radiusMd,
    double? radiusLg,
    List<BoxShadow>? glowShadow,
    Duration? durationFast,
    Duration? durationBase,
    Duration? durationSlow,
    double? minTouchTarget,
    double? posterWidth,
    double? posterHeight,
    double? topTileSize,
    double? topTileGap,
    double? recommendCardWidth,
    double? recommendCardHeight,
    double? filmTileWidth,
    double? filmTileHeight,
    double? generateButtonHeight,
    double? maxContentWidth,
  }) {
    return AppTokens(
      spaceXs: spaceXs ?? this.spaceXs,
      spaceSm: spaceSm ?? this.spaceSm,
      spaceMd: spaceMd ?? this.spaceMd,
      spaceLg: spaceLg ?? this.spaceLg,
      spaceXl: spaceXl ?? this.spaceXl,
      radiusSm: radiusSm ?? this.radiusSm,
      radiusMd: radiusMd ?? this.radiusMd,
      radiusLg: radiusLg ?? this.radiusLg,
      glowShadow: glowShadow ?? this.glowShadow,
      durationFast: durationFast ?? this.durationFast,
      durationBase: durationBase ?? this.durationBase,
      durationSlow: durationSlow ?? this.durationSlow,
      minTouchTarget: minTouchTarget ?? this.minTouchTarget,
      posterWidth: posterWidth ?? this.posterWidth,
      posterHeight: posterHeight ?? this.posterHeight,
      topTileSize: topTileSize ?? this.topTileSize,
      topTileGap: topTileGap ?? this.topTileGap,
      recommendCardWidth: recommendCardWidth ?? this.recommendCardWidth,
      recommendCardHeight: recommendCardHeight ?? this.recommendCardHeight,
      filmTileWidth: filmTileWidth ?? this.filmTileWidth,
      filmTileHeight: filmTileHeight ?? this.filmTileHeight,
      generateButtonHeight: generateButtonHeight ?? this.generateButtonHeight,
      maxContentWidth: maxContentWidth ?? this.maxContentWidth,
    );
  }

  @override
  AppTokens lerp(ThemeExtension<AppTokens>? other, double t) {
    if (other is! AppTokens) return this;
    return AppTokens(
      spaceXs: lerpDouble(spaceXs, other.spaceXs, t),
      spaceSm: lerpDouble(spaceSm, other.spaceSm, t),
      spaceMd: lerpDouble(spaceMd, other.spaceMd, t),
      spaceLg: lerpDouble(spaceLg, other.spaceLg, t),
      spaceXl: lerpDouble(spaceXl, other.spaceXl, t),
      radiusSm: lerpDouble(radiusSm, other.radiusSm, t),
      radiusMd: lerpDouble(radiusMd, other.radiusMd, t),
      radiusLg: lerpDouble(radiusLg, other.radiusLg, t),
      glowShadow: BoxShadow.lerpList(glowShadow, other.glowShadow, t) ?? glowShadow,
      durationFast: t < 0.5 ? durationFast : other.durationFast,
      durationBase: t < 0.5 ? durationBase : other.durationBase,
      durationSlow: t < 0.5 ? durationSlow : other.durationSlow,
      minTouchTarget: lerpDouble(minTouchTarget, other.minTouchTarget, t),
      posterWidth: lerpDouble(posterWidth, other.posterWidth, t),
      posterHeight: lerpDouble(posterHeight, other.posterHeight, t),
      topTileSize: lerpDouble(topTileSize, other.topTileSize, t),
      topTileGap: lerpDouble(topTileGap, other.topTileGap, t),
      recommendCardWidth: lerpDouble(recommendCardWidth, other.recommendCardWidth, t),
      recommendCardHeight: lerpDouble(recommendCardHeight, other.recommendCardHeight, t),
      filmTileWidth: lerpDouble(filmTileWidth, other.filmTileWidth, t),
      filmTileHeight: lerpDouble(filmTileHeight, other.filmTileHeight, t),
      generateButtonHeight: lerpDouble(generateButtonHeight, other.generateButtonHeight, t),
      maxContentWidth: lerpDouble(maxContentWidth, other.maxContentWidth, t),
    );
  }

  static double lerpDouble(double a, double b, double t) => a + (b - a) * t;
}

abstract final class AppTheme {
  static ThemeData dark() {
    const scheme = ColorScheme.dark(
      primary: AppColors.accent,
      onPrimary: AppColors.onPrimaryButton,
      secondary: AppColors.accentGlow,
      onSecondary: AppColors.background,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      onSurfaceVariant: AppColors.textMuted,
      outline: AppColors.outline,
      error: AppColors.error,
      onError: AppColors.background,
    );

    const base = TextTheme(
      headlineSmall: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, height: 1.3),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, height: 1.4),
      titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, height: 1.4),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, height: 1.5),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, height: 1.5),
      bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, height: 1.4),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.5),
      labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, height: 1.3),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Poppins',
      textTheme: base.apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      iconTheme: const IconThemeData(color: AppColors.textSecondary, size: 24),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.surfaceRaised,
        contentTextStyle: TextStyle(color: AppColors.textPrimary, fontFamily: 'Poppins'),
        actionTextColor: AppColors.accentGlow,
        behavior: SnackBarBehavior.floating,
      ),
      extensions: const [AppTokens.light],
    );
  }
}

extension AppThemeContext on BuildContext {
  AppTokens get tokens => Theme.of(this).extension<AppTokens>()!;

  Duration motion(Duration duration) =>
      MediaQuery.disableAnimationsOf(this) ? Duration.zero : duration;
}
