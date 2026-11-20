import 'package:flutter/material.dart';

import 'app_palette.dart';

export 'app_palette.dart';

/// Font family names registered in pubspec.yaml.
///
/// The whole app uses Pangram Sans, the FILMSAGE wordmark font, so titles,
/// body text and labels read as one family. The roles stay separate so a
/// role can change again without touching every screen.
abstract final class AppFonts {
  static const brand = 'PangramSans'; // FILMSAGE wordmark
  static const display = brand; // headings and titles
  static const body = brand; // body copy and UI text
  static const mono = brand; // labels and small metadata
}

/// App colour roles. Each reads the palette for the current light or dark
/// mode (see [AppPalette]), so these are getters, not constants.
abstract final class AppColors {
  static AppPalette get _p => AppPalette.current;

  static Color get background => _p.background;
  static Color get surface => _p.surface;
  static Color get surfaceRaised => _p.surfaceRaised;
  static Color get textPrimary => _p.textPrimary;
  static Color get textSecondary => _p.textSecondary;
  static Color get textMuted => _p.textMuted;
  static Color get accent => _p.accent;
  static Color get accentGlow => _p.accentGlow;
  static Color get primaryButton => _p.primaryButton;
  static Color get outline => _p.outline;
  static Color get panelBorder => _p.panelBorder;
  static Color get star => _p.star;
  static Color get error => _p.error;
  static Color get onPrimaryButton => _p.onPrimaryButton;
  static const transparent = Color(0x00000000);
  static Color get tabSelected => _p.tabSelected;
  static Color get tabUnselected => _p.tabUnselected;
  static Color get cardPill => _p.cardPill;
  static Color get reactionCount => _p.reactionCount;
  static Color get movieReference => _p.movieReference;
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
    posterAspectRatio: 2 / 3,
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
      glowShadow:
          BoxShadow.lerpList(glowShadow, other.glowShadow, t) ?? glowShadow,
      durationFast: t < 0.5 ? durationFast : other.durationFast,
      durationBase: t < 0.5 ? durationBase : other.durationBase,
      minTouchTarget: lerpDouble(minTouchTarget, other.minTouchTarget, t),
      borderWidth: lerpDouble(borderWidth, other.borderWidth, t),
      topTileGap: lerpDouble(topTileGap, other.topTileGap, t),
      filmTileWidth: lerpDouble(filmTileWidth, other.filmTileWidth, t),
      recommendCardWidth:
          lerpDouble(recommendCardWidth, other.recommendCardWidth, t),
      generateButtonHeight:
          lerpDouble(generateButtonHeight, other.generateButtonHeight, t),
      maxContentWidth: lerpDouble(maxContentWidth, other.maxContentWidth, t),
      logoHeight: lerpDouble(logoHeight, other.logoHeight, t),
      posterAspectRatio:
          lerpDouble(posterAspectRatio, other.posterAspectRatio, t),
      iconSmall: lerpDouble(iconSmall, other.iconSmall, t),
      iconLarge: lerpDouble(iconLarge, other.iconLarge, t),
    );
  }

  static double lerpDouble(double a, double b, double t) => a + (b - a) * t;
}

abstract final class AppTheme {
  /// The original dark theme; the reference look.
  static ThemeData dark() => forPalette(AppPalette.dark);

  /// Warm paper light theme with black buttons.
  static ThemeData light() => forPalette(AppPalette.light);

  static ThemeData forPalette(AppPalette p) {
    final scheme = p.isDark
        ? ColorScheme.dark(
            primary: p.accent,
            onPrimary: p.onPrimaryButton,
            secondary: p.accentGlow,
            onSecondary: p.background,
            surface: p.surface,
            onSurface: p.textPrimary,
            onSurfaceVariant: p.textMuted,
            outline: p.outline,
            error: p.error,
            onError: p.background,
          )
        : ColorScheme.light(
            primary: p.primaryButton,
            onPrimary: p.onPrimaryButton,
            secondary: p.accentGlow,
            onSecondary: p.onPrimaryButton,
            surface: p.surface,
            onSurface: p.textPrimary,
            onSurfaceVariant: p.textMuted,
            surfaceContainerHighest: p.surfaceRaised,
            outline: p.outline,
            outlineVariant: p.panelBorder,
            error: p.error,
            onError: p.onPrimaryButton,
          );

    // Typography roles:
    //  - Space Grotesk: headings and titles
    //  - Inter: body copy and UI text
    //  - Space Mono: labels and small metadata
    const base = TextTheme(
      headlineSmall: TextStyle(
          fontFamily: AppFonts.display,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          height: 1.3),
      titleLarge: TextStyle(
          fontFamily: AppFonts.display,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          height: 1.3),
      titleMedium: TextStyle(
          fontFamily: AppFonts.display,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          height: 1.35),
      titleSmall: TextStyle(
          fontFamily: AppFonts.display,
          fontSize: 15,
          fontWeight: FontWeight.w600,
          height: 1.35),
      bodyLarge: TextStyle(
          fontFamily: AppFonts.body,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.5),
      bodyMedium: TextStyle(
          fontFamily: AppFonts.body,
          fontSize: 15,
          fontWeight: FontWeight.w400,
          height: 1.5),
      bodySmall: TextStyle(
          fontFamily: AppFonts.body,
          fontSize: 13,
          fontWeight: FontWeight.w400,
          height: 1.45),
      labelLarge: TextStyle(
          fontFamily: AppFonts.mono,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.35,
          height: 1.35),
      labelSmall: TextStyle(
          fontFamily: AppFonts.mono,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          height: 1.4,
          letterSpacing: 0.15),
    );

    final theme = ThemeData(
      useMaterial3: true,
      brightness: p.brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: p.background,
      fontFamily: AppFonts.body,
      textTheme: base.apply(
        bodyColor: p.textPrimary,
        displayColor: p.textPrimary,
      ),
      iconTheme: IconThemeData(color: p.textSecondary, size: 24),
      appBarTheme: AppBarTheme(
        backgroundColor: p.background,
        foregroundColor: p.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: p.surfaceRaised,
        contentTextStyle:
            TextStyle(color: p.textPrimary, fontFamily: AppFonts.body),
        actionTextColor: p.accentGlow,
        behavior: SnackBarBehavior.floating,
      ),
      extensions: [AppTokens.light, p],
    );
    if (p.isDark) return theme;

    // Light only: black filled buttons with white labels, ink-coloured text
    // buttons, warm surfaces for sheets and dialogs, soft hairlines.
    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    );
    return theme.copyWith(
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: p.primaryButton,
          foregroundColor: p.onPrimaryButton,
          shape: buttonShape,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: p.primaryButton,
          foregroundColor: p.onPrimaryButton,
          elevation: 0,
          shape: buttonShape,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: p.textPrimary,
          side: BorderSide(color: p.textPrimary),
          shape: buttonShape,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: p.textPrimary),
      ),
      dividerTheme: DividerThemeData(color: p.luxeHair, thickness: 1),
      dialogTheme: DialogThemeData(backgroundColor: p.background),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.background,
        modalBackgroundColor: p.background,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: p.textPrimary,
        linearTrackColor: p.surfaceRaised,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: p.textPrimary,
        selectionColor: p.textPrimary.withValues(alpha: 0.18),
        selectionHandleColor: p.textPrimary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(color: p.textMuted),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: p.textPrimary, width: 2),
        ),
      ),
    );
  }
}

extension AppThemeContext on BuildContext {
  AppTokens get tokens => Theme.of(this).extension<AppTokens>()!;

  Duration motion(Duration duration) =>
      MediaQuery.disableAnimationsOf(this) ? Duration.zero : duration;
}
