import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart';

import 'auth_entity.dart';
import 'login_model.dart';

class LoginRepo {
  final url = "http://127.0.0.1:8000/api/account/login";
  final url_login = "http://127.0.0.1:8000/api/account/register";

  Future<Login> getToken(LoginEntity loginEntity) async {
    final response = await post(Uri.parse(url), body: {
      'email': '${loginEntity.email}',
      'password': '${loginEntity.passowrd}'
    });
    final services = jsonDecode(response.body);
    print(services["message"]);

    return Login(
        message: services["message"],
        feature: services["feature"],
        status: services["status"],
        token: '${services["token"] ?? ""}');
  }

  Future<Login> Registerrepo(RegisterEntity registerEntity) async {
    final response = await post(Uri.parse(url_login), body: {
      'username': '${registerEntity.username}',
      'email': '${registerEntity.email}',
      'password': '${registerEntity.passowrd}'
    });
    final services = jsonDecode(response.body) as Map<String, dynamic>;
    print(services["message"]);

    return Login(
      message: '${services["message"]}',
      feature: '${services["feature"]}',
      status: services["status"] as int,
      token: '${services["token"] ?? ""}',
    );
  }
}
