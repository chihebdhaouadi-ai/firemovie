import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Every colour role the app paints with, in one value per brightness.
///
/// [AppColors] and `LuxeColors` read from [AppPalette.current], so the many
/// screens that use them follow the chosen mode without each one reading
/// the theme. [AppThemeMode] swaps [current] and rebuilds the tree.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.brightness,
    required this.background,
    required this.surface,
    required this.surfaceRaised,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.accent,
    required this.accentGlow,
    required this.primaryButton,
    required this.onPrimaryButton,
    required this.outline,
    required this.panelBorder,
    required this.star,
    required this.error,
    required this.tabSelected,
    required this.tabUnselected,
    required this.cardPill,
    required this.reactionCount,
    required this.movieReference,
    required this.luxeBg,
    required this.luxeSurface,
    required this.luxeSurface2,
    required this.luxeHair,
    required this.luxeText,
    required this.luxeMuted,
    required this.luxeAccent,
    required this.luxeAccentHi,
    required this.luxeAccentLo,
    required this.scrim,
    required this.shadow,
    required this.grain,
  });

  final Brightness brightness;
  final Color background;
  final Color surface;
  final Color surfaceRaised;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color accent;
  final Color accentGlow;
  final Color primaryButton;
  final Color onPrimaryButton;
  final Color outline;
  final Color panelBorder;
  final Color star;
  final Color error;
  final Color tabSelected;
  final Color tabUnselected;
  final Color cardPill;
  final Color reactionCount;
  final Color movieReference;
  final Color luxeBg;
  final Color luxeSurface;
  final Color luxeSurface2;
  final Color luxeHair;
  final Color luxeText;
  final Color luxeMuted;
  final Color luxeAccent;
  final Color luxeAccentHi;
  final Color luxeAccentLo;

  /// Dark veil drawn over posters and images so overlaid text stays legible.
  final Color scrim;

  /// Drop-shadow colour for raised cards.
  final Color shadow;

  /// Speck colour of the paper grain; transparent turns the grain off.
  final Color grain;

  bool get isDark => brightness == Brightness.dark;

  /// The original look. These values must not change: dark mode is the
  /// reference the light mode is measured against.
  static const dark = AppPalette(
    brightness: Brightness.dark,
    background: Color(0xFF151515),
    surface: Color(0xFF1F1F1F),
    surfaceRaised: Color(0xFF2A2A2A),
    textPrimary: Color(0xFFF2F2F2),
    textSecondary: Color(0xFFD9D9D9),
    textMuted: Color(0xFFA8A8A8),
    accent: Color(0xFF1B8CE0),
    accentGlow: Color(0xFF35B6FF),
    primaryButton: Color(0xFF084C7C),
    onPrimaryButton: Color(0xFFFFFFFF),
    outline: Color(0xFF5D697A),
    panelBorder: Color(0xFF1C6BA8),
    star: Color(0xFFD4A21A),
    error: Color(0xFFFF6B6B),
    tabSelected: Color(0xFF0077DE),
    tabUnselected: Color(0xFF28313A),
    cardPill: Color(0xFF1E1F24),
    reactionCount: Color(0xFF2F6FD6),
    movieReference: Color(0xFF8A8F9C),
    luxeBg: Color(0xFF0E0F12),
    luxeSurface: Color(0xFF16181D),
    luxeSurface2: Color(0xFF1D2027),
    luxeHair: Color(0x14FFFFFF),
    luxeText: Color(0xFFF2F3F5),
    luxeMuted: Color(0xFF8B90A0),
    luxeAccent: Color(0xFF4A8CF0),
    luxeAccentHi: Color(0xFF5B9BFF),
    luxeAccentLo: Color(0xFF2A57B8),
    scrim: Color(0xCC000000),
    shadow: Color(0x66000000),
    grain: Color(0x00000000),
  );

  /// Warm paper: off-white page, darker warm-grey cards, near-black ink and
  /// black filled buttons. Text colours keep at least 4.5:1 on [background]
  /// and [surface].
  static const light = AppPalette(
    brightness: Brightness.light,
    background: Color(0xFFF2EEE6),
    surface: Color(0xFFE9E4DA),
    surfaceRaised: Color(0xFFDFD9CD),
    textPrimary: Color(0xFF1A1814),
    textSecondary: Color(0xFF36322B),
    textMuted: Color(0xFF615B50),
    accent: Color(0xFF1A1814),
    accentGlow: Color(0xFF1C5FB0),
    primaryButton: Color(0xFF1A1814),
    onPrimaryButton: Color(0xFFFFFFFF),
    outline: Color(0xFF9A9385),
    panelBorder: Color(0xFFCFC8BA),
    star: Color(0xFF9A6D00),
    error: Color(0xFFB3261E),
    tabSelected: Color(0xFF1A1814),
    tabUnselected: Color(0xFFDFD9CD),
    cardPill: Color(0xFFE3DED3),
    reactionCount: Color(0xFF1C5FB0),
    movieReference: Color(0xFF615B50),
    luxeBg: Color(0xFFF2EEE6),
    luxeSurface: Color(0xFFE9E4DA),
    luxeSurface2: Color(0xFFDFD9CD),
    luxeHair: Color(0x1F1A1814),
    luxeText: Color(0xFF1A1814),
    luxeMuted: Color(0xFF615B50),
    luxeAccent: Color(0xFF1A1814),
    luxeAccentHi: Color(0xFF3A362F),
    luxeAccentLo: Color(0xFF0B0A08),
    scrim: Color(0xB3000000),
    shadow: Color(0x261A1814),
    grain: Color(0xFF3B3326),
  );

  /// The palette in use. Set only through [AppThemeMode].
  static AppPalette current = dark;

  static AppPalette of(BuildContext context) =>
      Theme.of(context).extension<AppPalette>() ?? current;

  @override
  AppPalette copyWith() => this;

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) =>
      other is AppPalette && t >= 0.5 ? other : this;
}

/// The person's light / dark / system choice, persisted like `AppLocale`.
///
/// Dark is the default so the app keeps its original look until the person
/// picks another mode.
class AppThemeMode {
  AppThemeMode._();

  static const _key = 'app_theme_mode';

  static final ValueNotifier<ThemeMode> current =
      ValueNotifier<ThemeMode>(ThemeMode.dark);

  static Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString(_key);
      current.value = ThemeMode.values.firstWhere(
        (mode) => mode.name == name,
        orElse: () => ThemeMode.dark,
      );
    } catch (_) {
      // Storage is optional; the device setting applies when it is missing.
    }
  }

  static Future<void> select(ThemeMode mode) async {
    current.value = mode;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, mode.name);
    } catch (_) {
      // The choice still applies for this session when storage is unavailable.
    }
  }

  /// The palette for [mode] given the device brightness.
  static AppPalette paletteFor(ThemeMode mode, Brightness platform) {
    return switch (mode) {
      ThemeMode.light => AppPalette.light,
      ThemeMode.dark => AppPalette.dark,
      ThemeMode.system =>
        platform == Brightness.light ? AppPalette.light : AppPalette.dark,
    };
  }
}

/// Picks [dark] or [light] for the current mode. For one-off colours that
/// have no palette role; the dark value is the original look.
Color themed(Color dark, Color light) =>
    AppPalette.current.isDark ? dark : light;

/// Tint for white line-art assets (SVG icons): none in dark mode, near-black
/// ink in light mode.
ColorFilter? get inkIconFilter => AppPalette.current.isDark
    ? null
    : ColorFilter.mode(AppPalette.current.textPrimary, BlendMode.srcIn);
