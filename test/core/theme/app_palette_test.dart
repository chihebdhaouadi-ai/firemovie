import 'package:film_wise_mobile/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

double _contrast(Color a, Color b) {
  final la = a.computeLuminance(), lb = b.computeLuminance();
  final hi = la > lb ? la : lb, lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  tearDown(() => AppPalette.current = AppPalette.dark);

  test('dark palette keeps the original colours', () {
    expect(AppPalette.dark.background, const Color(0xFF151515));
    expect(AppPalette.dark.accent, const Color(0xFF1B8CE0));
    expect(AppPalette.dark.luxeBg, const Color(0xFF0E0F12));
  });

  test('AppColors follow the current palette', () {
    AppPalette.current = AppPalette.light;
    expect(AppColors.background, AppPalette.light.background);
    expect(AppColors.primaryButton, AppPalette.light.primaryButton);
    AppPalette.current = AppPalette.dark;
    expect(AppColors.background, const Color(0xFF151515));
  });

  test('light text colours reach 4.5:1 on page and card surfaces', () {
    const p = AppPalette.light;
    for (final text in [p.textPrimary, p.textSecondary, p.textMuted]) {
      expect(_contrast(text, p.background), greaterThanOrEqualTo(4.5));
      expect(_contrast(text, p.surface), greaterThanOrEqualTo(4.5));
    }
    expect(_contrast(p.onPrimaryButton, p.primaryButton),
        greaterThanOrEqualTo(4.5));
  });

  test('paletteFor resolves system mode from the device brightness', () {
    expect(AppThemeMode.paletteFor(ThemeMode.light, Brightness.dark),
        AppPalette.light);
    expect(AppThemeMode.paletteFor(ThemeMode.dark, Brightness.light),
        AppPalette.dark);
    expect(AppThemeMode.paletteFor(ThemeMode.system, Brightness.light),
        AppPalette.light);
    expect(AppThemeMode.paletteFor(ThemeMode.system, Brightness.dark),
        AppPalette.dark);
  });

  test('the chosen mode is saved and restored, dark by default', () async {
    SharedPreferences.setMockInitialValues({});
    await AppThemeMode.load();
    expect(AppThemeMode.current.value, ThemeMode.dark);

    await AppThemeMode.select(ThemeMode.light);
    AppThemeMode.current.value = ThemeMode.dark;
    await AppThemeMode.load();
    expect(AppThemeMode.current.value, ThemeMode.light);
  });
}
