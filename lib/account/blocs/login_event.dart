import '../data/auth_entity.dart';

sealed class LoginEvent {
  const LoginEvent();
}

final class LoginSubmitted extends LoginEvent {
  const LoginSubmitted(this.entity);

  final LoginEntity entity;
}

final class RegisterSubmitted extends LoginEvent {
  const RegisterSubmitted(this.entity);

  final RegisterEntity entity;
}
