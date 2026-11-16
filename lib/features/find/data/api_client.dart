import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/api_config.dart';
import '../../../core/session.dart';
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
    final response =
        await _send(() => _inner.get(_uri(path, query), headers: _headers));
    return _decodeObject(response);
  }

  Future<List<Map<String, dynamic>>> getList(
    String path, {
    Map<String, String>? query,
  }) async {
    final response =
        await _send(() => _inner.get(_uri(path, query), headers: _headers));
    final decoded = _decodeAny(response);
    if (decoded is List) return decoded.cast<Map<String, dynamic>>();
    throw ServerFailure('bad_response', 'Unexpected response from server.');
  }

  Future<void> postNoContent(String path) async {
    await _send(() => _inner.post(_uri(path), headers: _headers));
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

  Future<Map<String, dynamic>> putJson(
    String path, {
    required Map<String, dynamic> body,
  }) async {
    final response = await _send(() =>
        _inner.put(_uri(path), headers: _headers, body: jsonEncode(body)));
    return _decodeObject(response);
  }

  Future<Map<String, dynamic>> patchMultipart(
    String path, {
    required String fileField,
    required XFile file,
  }) async {
    final bytes = await file.readAsBytes();
    final response = await _send(() async {
      final request = http.MultipartRequest('PATCH', _uri(path))
        ..files.add(
          http.MultipartFile.fromBytes(fileField, bytes, filename: file.name),
        );
      if (ApiConfig.authorization case final auth?) {
        request.headers['Authorization'] = auth;
      }
      final streamed = await _inner.send(request);
      return http.Response.fromStream(streamed);
    });
    return _decodeObject(response);
  }

  /// Posts form fields plus an optional image, as multipart form data.
  /// [fieldLists] sends each value under a repeated key, such as `options`.
  Future<Map<String, dynamic>> postMultipart(
    String path, {
    Map<String, String> fields = const {},
    Map<String, List<String>> fieldLists = const {},
    XFile? file,
    String fileField = 'image',
    MediaType? fileType,
  }) async {
    final bytes = file == null ? null : await file.readAsBytes();
    final response = await _send(() async {
      final request = http.MultipartRequest('POST', _uri(path))
        ..fields.addAll(fields);
      for (final entry in fieldLists.entries) {
        for (final value in entry.value) {
          request.files.add(http.MultipartFile.fromString(entry.key, value));
        }
      }
      if (file != null && bytes != null) {
        request.files.add(http.MultipartFile.fromBytes(
          fileField,
          bytes,
          filename: file.name,
          contentType: fileType,
        ));
      }
      if (ApiConfig.authorization case final auth?) {
        request.headers['Authorization'] = auth;
      }
      final streamed = await _inner.send(request);
      return http.Response.fromStream(streamed);
    });
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
    // 401 means the token is missing or expired: drop the session to guest.
    // 403 is a permission refusal for a signed-in person, so it stays an
    // ordinary server error and does not sign anyone out.
    if (code == 401) {
      Session.reportUnauthorized();
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
    final decoded = _decodeAny(response);
    return decoded is Map<String, dynamic> ? decoded : null;
  }

  Object? _decodeAny(http.Response response) {
    if (response.bodyBytes.isEmpty) return null;
    try {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } on FormatException {
      return null;
    }
  }

  String? _detailOf(http.Response response) =>
      _tryDecode(response)?['detail'] as String?;
}
