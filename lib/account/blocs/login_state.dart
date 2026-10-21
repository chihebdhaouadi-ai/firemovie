sealed class LoginState {
  const LoginState();
}

final class LoginIdle extends LoginState {
  const LoginIdle();
}

final class LoginInProgress extends LoginState {
  const LoginInProgress();
}

final class LoginSucceeded extends LoginState {
  const LoginSucceeded({required this.token, required this.isNewAccount});

  final String token;
  final bool isNewAccount;
}

final class LoginFailed extends LoginState {
  const LoginFailed(this.message);

  final String message;
}
