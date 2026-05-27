import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_config.dart';

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final int? statusCode;
  final String message;

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<dynamic> getJson(String path, {Map<String, String>? headers}) async {
    return _send('GET', path, headers: headers);
  }

  Future<dynamic> postJson(
    String path, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    return _send('POST', path, headers: headers, body: body);
  }

  Future<dynamic> deleteJson(
    String path, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    return _send('DELETE', path, headers: headers, body: body);
  }

  Future<dynamic> _send(
    String method,
    String path, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    final mergedHeaders = <String, String>{
      'Accept': 'application/json',
      if (body != null) 'Content-Type': 'application/json',
      if (headers != null) ...headers,
    };

    final response = switch (method) {
      'GET' => await _client.get(uri, headers: mergedHeaders),
      'POST' => await _client.post(
        uri,
        headers: mergedHeaders,
        body: body == null ? null : jsonEncode(body),
      ),
      'DELETE' => await _client.delete(
        uri,
        headers: mergedHeaders,
        body: body == null ? null : jsonEncode(body),
      ),
      _ => throw UnsupportedError('Unsupported method: $method'),
    };

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        _extractErrorMessage(response.body),
        statusCode: response.statusCode,
      );
    }

    if (response.body.isEmpty) {
      return null;
    }

    return jsonDecode(response.body);
  }

  String _extractErrorMessage(String body) {
    if (body.isEmpty) {
      return 'Request failed';
    }

    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final detail = decoded['detail'];
        if (detail is String) {
          return detail;
        }
        if (detail is List && detail.isNotEmpty) {
          return detail.first.toString();
        }
      }
    } catch (_) {
      return body;
    }

    return body;
  }
}
