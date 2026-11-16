import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/api_config.dart';
import 'auth_entity.dart';
import 'login_model.dart';

class LoginRepo {
  static const _timeout = Duration(seconds: 30);

  Future<Login> login(LoginEntity entity) {
    return _post('/api/account/login', {
      'email': entity.email,
      'password': entity.password,
    });
  }

  Future<Login> register(RegisterEntity entity) {
    return _post('/api/account/register', {
      'username': entity.username,
      'email': entity.email,
      'password': entity.password,
    });
  }

  Future<Login> _post(String path, Map<String, String> body) async {
    final response = await http
        .post(Uri.parse('${ApiConfig.baseUrl}$path'), body: body)
        .timeout(_timeout);
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final status = json['status'];

    return Login(
      message: _text(json['message']),
      feature: _text(json['feature']),
      status: status is int ? status : response.statusCode,
      token: _text(json['token']),
    );
  }

  /// Field-level validation errors arrive as a map of lists; surface the first.
  static String _text(Object? value) {
    if (value is Map && value.isNotEmpty) return _text(value.values.first);
    if (value is List && value.isNotEmpty) return _text(value.first);
    return value?.toString() ?? '';
  }
}
