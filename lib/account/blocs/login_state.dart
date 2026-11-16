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

enum LoginErrorKind { invalidCredentials, registerFailed, network }

final class LoginFailed extends LoginState {
  const LoginFailed(this.kind, {this.serverMessage});

  final LoginErrorKind kind;
  final String? serverMessage;
}
