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
  static const transparent = Color(0x00000000);
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
    required this.minTouchTarget,
    required this.borderWidth,
    required this.topTileGap,
    required this.filmTileWidth,
    required this.recommendCardWidth,
    required this.generateButtonHeight,
    required this.maxContentWidth,
    required this.logoHeight,
    required this.posterAspectRatio,
    required this.iconSmall,
    required this.iconLarge,
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
  final double minTouchTarget;
  final double borderWidth;
  final double topTileGap;
  final double filmTileWidth;
  final double recommendCardWidth;
  final double generateButtonHeight;
  final double maxContentWidth;
  final double logoHeight;
  final double posterAspectRatio;
  final double iconSmall;
  final double iconLarge;

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
    minTouchTarget: 48,
    borderWidth: 1,
    topTileGap: 8,
    filmTileWidth: 78,
    recommendCardWidth: 77,
    generateButtonHeight: 48,
    maxContentWidth: 640,
    logoHeight: 28,
    posterAspectRatio: 0.7,
    iconSmall: 16,
    iconLarge: 40,
  );

  double posterHeight(double width) => width / posterAspectRatio;

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
    double? minTouchTarget,
    double? borderWidth,
    double? topTileGap,
    double? filmTileWidth,
    double? recommendCardWidth,
    double? generateButtonHeight,
    double? maxContentWidth,
    double? logoHeight,
    double? posterAspectRatio,
    double? iconSmall,
    double? iconLarge,
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
      minTouchTarget: minTouchTarget ?? this.minTouchTarget,
      borderWidth: borderWidth ?? this.borderWidth,
      topTileGap: topTileGap ?? this.topTileGap,
      filmTileWidth: filmTileWidth ?? this.filmTileWidth,
      recommendCardWidth: recommendCardWidth ?? this.recommendCardWidth,
      generateButtonHeight: generateButtonHeight ?? this.generateButtonHeight,
      maxContentWidth: maxContentWidth ?? this.maxContentWidth,
      logoHeight: logoHeight ?? this.logoHeight,
      posterAspectRatio: posterAspectRatio ?? this.posterAspectRatio,
      iconSmall: iconSmall ?? this.iconSmall,
      iconLarge: iconLarge ?? this.iconLarge,
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
      minTouchTarget: lerpDouble(minTouchTarget, other.minTouchTarget, t),
      borderWidth: lerpDouble(borderWidth, other.borderWidth, t),
      topTileGap: lerpDouble(topTileGap, other.topTileGap, t),
      filmTileWidth: lerpDouble(filmTileWidth, other.filmTileWidth, t),
      recommendCardWidth: lerpDouble(recommendCardWidth, other.recommendCardWidth, t),
      generateButtonHeight: lerpDouble(generateButtonHeight, other.generateButtonHeight, t),
      maxContentWidth: lerpDouble(maxContentWidth, other.maxContentWidth, t),
      logoHeight: lerpDouble(logoHeight, other.logoHeight, t),
      posterAspectRatio: lerpDouble(posterAspectRatio, other.posterAspectRatio, t),
      iconSmall: lerpDouble(iconSmall, other.iconSmall, t),
      iconLarge: lerpDouble(iconLarge, other.iconLarge, t),
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
