import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flowboard/core/network/api_exception.dart';

/// HTTP client of the Flowboard REST API.
///
/// It resolves paths against the base URL, sends and receives JSON, and turns every failure
/// into an [ApiException] so repositories never see transport details.
class ApiClient {
  /// Creates the client; [baseUrl] defaults to [defaultBaseUrl].
  ApiClient({required http.Client client, String baseUrl = defaultBaseUrl})
      : _client = client,
        _baseUri = Uri.parse(baseUrl);

  /// Base URL of the Flowboard mobile service.
  static const String defaultBaseUrl = 'https://flowboard-mobile-service.onrender.com/api/v1/';

  static const Duration _timeout = Duration(seconds: 60);
  static const Map<String, String> _headers = <String, String>{
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  final http.Client _client;
  final Uri _baseUri;

  /// Sends a GET request and returns the decoded JSON body.
  Future<dynamic> get(String path, {Map<String, dynamic>? query}) {
    return _send(() => _client.get(_uri(path, query), headers: _headers));
  }

  /// Sends a POST request with an optional JSON [body].
  Future<dynamic> post(String path, {Object? body}) {
    return _send(() => _client.post(_uri(path), headers: _headers, body: _encode(body)));
  }

  /// Sends a PUT request with an optional JSON [body].
  Future<dynamic> put(String path, {Object? body}) {
    return _send(() => _client.put(_uri(path), headers: _headers, body: _encode(body)));
  }

  /// Sends a PATCH request with an optional JSON [body].
  Future<dynamic> patch(String path, {Object? body}) {
    return _send(() => _client.patch(_uri(path), headers: _headers, body: _encode(body)));
  }

  /// Sends a DELETE request.
  Future<dynamic> delete(String path) {
    return _send(() => _client.delete(_uri(path), headers: _headers));
  }

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final Map<String, String> parameters = <String, String>{
      if (query != null)
        for (final MapEntry<String, dynamic> entry in query.entries)
          if (entry.value != null) entry.key: entry.value.toString(),
    };
    final Uri resolved = _baseUri.resolve(path);
    return parameters.isEmpty ? resolved : resolved.replace(queryParameters: parameters);
  }

  String? _encode(Object? body) => body == null ? null : jsonEncode(body);

  Future<dynamic> _send(Future<http.Response> Function() request) async {
    try {
      final http.Response response = await request().timeout(_timeout);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return _decode(response);
      }
      throw _parseError(response);
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw const ApiException(message: 'No se pudo conectar con el servidor.');
    } on http.ClientException {
      throw const ApiException(message: 'No se pudo conectar con el servidor.');
    }
  }

  dynamic _decode(http.Response response) {
    if (response.bodyBytes.isEmpty) return null;
    return jsonDecode(utf8.decode(response.bodyBytes));
  }

  ApiException _parseError(http.Response response) {
    try {
      final dynamic json = jsonDecode(utf8.decode(response.bodyBytes));
      if (json is Map<String, dynamic>) {
        return ApiException(
          code: json['code'] as String?,
          message: json['message'] as String? ?? 'Error ${response.statusCode}',
          details: json['details'] as String?,
        );
      }
    } catch (_) {
      return ApiException(message: 'Error ${response.statusCode}');
    }
    return ApiException(message: 'Error ${response.statusCode}');
  }
}
