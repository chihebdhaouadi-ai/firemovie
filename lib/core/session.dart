class Session {
  static String token = '';

  static bool get isLoggedIn => token.isNotEmpty;

  static void clear() {
    token = '';
  }
}
