import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_localizations.dart';

class AppLocale {
  AppLocale._();

  static const _key = 'app_locale';

  /// Null follows the device language.
  static final ValueNotifier<Locale?> current = ValueNotifier<Locale?>(null);

  static Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_key);
      final matches = AppLocalizations.supportedLocales
          .where((locale) => locale.languageCode == code);
      current.value = matches.isEmpty ? null : matches.first;
    } catch (_) {
      // Storage is optional; the device language applies when it is unavailable.
    }
  }

  static Future<void> select(Locale? locale) async {
    current.value = locale;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (locale == null) {
        await prefs.remove(_key);
      } else {
        await prefs.setString(_key, locale.languageCode);
      }
    } catch (_) {
      // The choice still applies for this session when storage is unavailable.
    }
  }
}
