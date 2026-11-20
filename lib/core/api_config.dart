import 'package:flutter/foundation.dart';

import 'session.dart';

/// Central place for API configuration.
///
/// Debug runs default to the local Django backend at 127.0.0.1:8000.
/// Release builds default to the hosted Heroku backend.
/// `--dart-define=API_BASE_URL=...` overrides both.
/// Never put secrets, API keys, or credentials here.
abstract final class ApiConfig {
  static const String _defaultBaseUrl =
      'https://filwise-7a4ee29afcff.herokuapp.com';
  static const String _localBaseUrl = 'http://127.0.0.1:8000';

  /// The base URL of the Django backend, without a trailing slash.
  /// Debug runs use the local Django server; release builds use Heroku.
  static String get baseUrl {
    final fromEnv = const String.fromEnvironment('API_BASE_URL');
    if (fromEnv.isNotEmpty) return fromEnv;
    // Allow override at runtime (tests / preview).
    if (kDebugMode && override != null) return override!;
    if (kDebugMode) return _localBaseUrl;
    return _defaultBaseUrl;
  }

  /// Test-only override. Not used in production.
  @visibleForTesting
  static String? override;

  /// Authorization header value for the current session, if any.
  static String? get authorization =>
      Session.token.isEmpty ? null : 'Token ${Session.token}';
}
