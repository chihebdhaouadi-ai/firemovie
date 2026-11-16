/// Synchronous view of the signed-in token, read by [ApiConfig] and the
/// login gate.
///
/// [AuthCubit] is the only writer in the running app: it mirrors every state
/// change here. Do not set [token] from feature code.
class Session {
  static String token = '';

  static bool get isLoggedIn => token.isNotEmpty;

  /// Called when the server rejects the token (HTTP 401). [AuthCubit] registers
  /// itself here so an expired session drops back to guest.
  static void Function()? onUnauthorized;

  static void reportUnauthorized() => onUnauthorized?.call();

  static void clear() {
    token = '';
  }
}
