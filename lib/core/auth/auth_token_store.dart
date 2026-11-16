import 'package:shared_preferences/shared_preferences.dart';

/// Persists the signed-in token between launches.
abstract interface class AuthTokenStore {
  Future<String?> read();

  Future<void> write(String token);

  Future<void> clear();
}

/// Stores the token in shared_preferences (plain, unencrypted storage).
///
/// Storage failures are swallowed: the session still works for the current
/// launch, the person just signs in again next time. Move this to a secure
/// store (flutter_secure_storage) before release.
class SharedPrefsAuthTokenStore implements AuthTokenStore {
  static const _key = 'auth_token';

  @override
  Future<String?> read() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_key);
      return (token == null || token.isEmpty) ? null : token;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> write(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, token);
    } catch (_) {
      // Keep the in-memory session; it is lost on the next cold start.
    }
  }

  @override
  Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
    } catch (_) {
      // Nothing persisted to remove.
    }
  }
}

/// In-memory store for tests and previews.
class InMemoryAuthTokenStore implements AuthTokenStore {
  InMemoryAuthTokenStore([this.token]);

  String? token;

  @override
  Future<String?> read() async => token;

  @override
  Future<void> write(String token) async => this.token = token;

  @override
  Future<void> clear() async => token = null;
}
