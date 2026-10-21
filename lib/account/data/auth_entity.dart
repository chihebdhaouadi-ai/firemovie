class LoginEntity {
  const LoginEntity({required this.email, required this.password});

  final String email;
  final String password;
}

class RegisterEntity {
  const RegisterEntity({
    required this.username,
    required this.email,
    required this.password,
  });

  final String username;
  final String email;
  final String password;
}
