import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../session.dart';
import 'auth_state.dart';
import 'auth_token_store.dart';

/// Owns the session: restores the stored token, signs in, signs out, and
/// drops to guest when the server rejects the token.
///
/// Every change is mirrored to [Session] before it is emitted, so the
/// synchronous readers (`ApiConfig`, the login gate, the angel bird host)
/// always see the same token as this state.
class AuthCubit extends Cubit<AuthState> {
  AuthCubit({required AuthTokenStore store})
      : _store = store,
        super(const AuthUnknown()) {
    Session.onUnauthorized = _onUnauthorized;
  }

  final AuthTokenStore _store;

  /// Reads the stored token. Call once before the first frame.
  Future<void> restore() async {
    final token = await _store.read();
    if (isClosed) return;
    if (token == null) {
      _becomeGuest();
    } else {
      _becomeAuthenticated(token);
    }
  }

  /// Stores [token] and switches to authenticated. The token is set on
  /// [Session] before this method's first await.
  Future<void> signIn(String token) async {
    _becomeAuthenticated(token);
    await _store.write(token);
  }

  /// Clears the token everywhere and switches to guest.
  Future<void> signOut() async {
    _becomeGuest();
    await _store.clear();
  }

  void _onUnauthorized() {
    if (state is! AuthAuthenticated) return;
    _becomeGuest();
    unawaited(_store.clear());
  }

  void _becomeAuthenticated(String token) {
    Session.token = token;
    if (!isClosed) emit(AuthAuthenticated(token));
  }

  void _becomeGuest() {
    Session.clear();
    if (!isClosed) emit(const AuthGuest());
  }

  @override
  Future<void> close() {
    if (identical(Session.onUnauthorized, _onUnauthorized)) {
      Session.onUnauthorized = null;
    }
    return super.close();
  }
}
