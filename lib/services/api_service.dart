import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../core/constants/app_constants.dart';
import '../models/api_response.dart';

class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<ApiResponse<dynamic>> post({
    required String action,
    Map<String, dynamic>? body,
    bool forceJsonPost = false,
  }) async {
    try {
      final requestBody = jsonEncode({'action': action, ...?body});
      final uri = Uri.parse(AppConstants.googleAppsScriptUrl);
      final response = forceJsonPost
          ? await _postJson(uri, requestBody)
          : kIsWeb
          ? await _requestForWeb(uri, requestBody)
          : await _postWithRedirects(uri, requestBody);

      final responseBody = response.body.trimLeft();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return ApiResponse(
          success: false,
          message: 'Server Apps Script error (${response.statusCode}).',
        );
      }
      if (responseBody.startsWith('<')) {
        return const ApiResponse(
          success: false,
          message:
              'URL Apps Script mengembalikan HTML, bukan JSON. Cek deployment Web App: Execute as Me, akses Anyone, gunakan URL /exec, lalu redeploy.',
        );
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return ApiResponse.fromJson(json);
    } catch (error) {
      return ApiResponse(
        success: false,
        message: 'Gagal terhubung ke server: ${_safeErrorMessage(error)}',
      );
    }
  }

  String _safeErrorMessage(Object error) {
    var message = error.toString();
    message = message.replaceAll(
      RegExp(r'payload=[^,\s)]+', caseSensitive: false),
      'payload=<disembunyikan>',
    );
    message = message.replaceAll(
      RegExp(r'base64Data[^,\s)]+', caseSensitive: false),
      'base64Data=<disembunyikan>',
    );
    if (message.length > 260) {
      message = '${message.substring(0, 260)}...';
    }
    return message;
  }

  Future<http.Response> _requestForWeb(Uri uri, String body) {
    return _client.get(
      uri.replace(queryParameters: {...uri.queryParameters, 'payload': body}),
    );
  }

  Future<http.Response> _postJson(Uri uri, String body) {
    return _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );
  }

  Future<http.Response> _postWithRedirects(Uri uri, String body) async {
    var currentUri = uri;
    var method = 'POST';
    for (var i = 0; i < 5; i++) {
      final request = http.Request(method, currentUri)..followRedirects = false;
      if (method == 'POST') {
        request
          ..headers['Content-Type'] = 'text/plain;charset=utf-8'
          ..body = body;
      }
      final streamed = await _client.send(request);
      final response = await http.Response.fromStream(streamed);
      final location = response.headers['location'];
      final isRedirect =
          response.statusCode == 301 ||
          response.statusCode == 302 ||
          response.statusCode == 303 ||
          response.statusCode == 307 ||
          response.statusCode == 308;

      if (!isRedirect || location == null || location.isEmpty) {
        return response;
      }
      currentUri = currentUri.resolve(location);
      if (response.statusCode == 301 ||
          response.statusCode == 302 ||
          response.statusCode == 303) {
        method = 'GET';
      }
    }

    return http.Response(
      '{"success":false,"message":"Terlalu banyak redirect dari Apps Script","data":null}',
      508,
      headers: {'content-type': 'application/json'},
    );
  }
}
