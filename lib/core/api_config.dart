import 'package:flutter/foundation.dart';

import 'session.dart';

/// Central place for API configuration.
///
/// The default base URL is pointed at the local Django backend for development.
/// It can be overridden at build time with `--dart-define=API_BASE_URL=...`.
/// Never put secrets, API keys, or credentials here.
abstract final class ApiConfig {
  static const String _defaultBaseUrl = 'http://127.0.0.1:8000';

  /// The base URL of the Django backend, without a trailing slash.
  static String get baseUrl {
    final fromEnv = const String.fromEnvironment('API_BASE_URL');
    if (fromEnv.isNotEmpty) return fromEnv;
    // Allow override at runtime (tests / preview).
    if (kDebugMode && override != null) return override!;
    return _defaultBaseUrl;
  }

  /// Test-only override. Not used in production.
  @visibleForTesting
  static String? override;

  /// Authorization header value for the current session, if any.
  static String? get authorization =>
      Session.token.isEmpty ? null : 'Token ${Session.token}';
}
