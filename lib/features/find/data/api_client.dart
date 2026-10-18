import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../../core/api_config.dart';
import 'movie.dart';

/// Thin HTTP client for the Django backend.
///
/// Handles JSON encoding/decoding, auth headers, timeout, and maps network /
/// HTTP errors to typed [FindFailure]s. Holds no secrets and reads the base
/// URL from [ApiConfig].
class ApiClient {
  ApiClient({http.Client? httpClient, String? baseUrl})
      : _inner = httpClient ?? http.Client(),
        _baseUrl = baseUrl ?? ApiConfig.baseUrl;

  final http.Client _inner;
  final String _baseUrl;

  static const _timeout = Duration(seconds: 12);

  Map<String, String> get _headers => {
        'Content-Type': 'application/json; charset=UTF-8',
        if (ApiConfig.authorization case final auth?) 'Authorization': auth,
      };

  Uri _uri(String path, [Map<String, String>? query]) =>
      Uri.parse('$_baseUrl$path').replace(queryParameters: query);

  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, String>? query,
  }) async {
    final response = await _send(() => _inner.get(_uri(path, query)));
    return _decodeObject(response);
  }

  Future<Map<String, dynamic>> postJson(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final response = await _send(
      () => _inner.post(_uri(path),
          headers: _headers, body: jsonEncode(body ?? const {})),
    );
    return _decodeObject(response);
  }

  Future<Map<String, dynamic>> patchJson(
    String path, {
    required Map<String, dynamic> body,
  }) async {
    final response = await _send(() =>
        _inner.patch(_uri(path), headers: _headers, body: jsonEncode(body)));
    return _decodeObject(response);
  }

  Future<void> delete(String path) async {
    final response =
        await _send(() => _inner.delete(_uri(path), headers: _headers));
    _throwForError(response);
  }

  Future<http.Response> _send(Future<http.Response> Function() request) async {
    try {
      final response = await request().timeout(_timeout);
      _throwForError(response);
      return response;
    } on FindFailure {
      rethrow;
    } on SocketException {
      throw const OfflineFailure();
    } on http.ClientException {
      throw const OfflineFailure();
    } on TimeoutException {
      throw const NetworkFailure('Request timed out.');
    }
  }

  void _throwForError(http.Response response) {
    final code = response.statusCode;
    if (code >= 200 && code < 300) return;
    if (code == 401 || code == 403) {
      throw AuthFailure(_detailOf(response) ?? 'You need to sign in again.');
    }
    if (code >= 500) {
      throw ServerFailure('server', 'Something went wrong on the server.');
    }
    final decoded = _tryDecode(response);
    final detail = decoded?['detail'] as String?;
    final errorCode = decoded?['code'] as String?;
    final effectiveCode =
        (errorCode == null || errorCode.isEmpty) ? 'http_$code' : errorCode;
    throw ServerFailure(
        effectiveCode, detail ?? 'Request failed (HTTP $code).');
  }

  Map<String, dynamic> _decodeObject(http.Response response) {
    _throwForError(response);
    final decoded = _tryDecode(response);
    if (decoded is Map<String, dynamic>) return decoded;
    throw ServerFailure('bad_response', 'Unexpected response from server.');
  }

  Map<String, dynamic>? _tryDecode(http.Response response) {
    if (response.bodyBytes.isEmpty) return null;
    try {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      return decoded is Map<String, dynamic> ? decoded : null;
    } on FormatException {
      return null;
    }
  }

  String? _detailOf(http.Response response) =>
      _tryDecode(response)?['detail'] as String?;
}
