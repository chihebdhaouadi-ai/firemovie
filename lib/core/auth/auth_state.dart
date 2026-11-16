import 'package:equatable/equatable.dart';

/// Whether the person has a session. Guests can browse public content; gated
/// actions open the login page first (see `requireAuth`).
sealed class AuthState extends Equatable {
  const AuthState();

  bool get isAuthenticated => this is AuthAuthenticated;

  @override
  List<Object?> get props => const [];
}

/// Before the stored token has been read. The app waits for this to settle
/// in `main()`, so screens normally never observe it.
final class AuthUnknown extends AuthState {
  const AuthUnknown();
}

final class AuthGuest extends AuthState {
  const AuthGuest();
}

final class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.token);

  final String token;

  @override
  List<Object?> get props => [token];
}
