import 'package:dio/dio.dart';
import 'token_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:core';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  final Dio dio = Dio(
    BaseOptions(
      // Dynamic base URL for web vs emulator/mobile
      baseUrl: _resolveBaseUrl(),
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 20),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );

  ApiClient._internal() {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await TokenStorage.getToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (e, handler) async {
        // If 401, drop token (it may be expired)
        if (e.response?.statusCode == 401) {
          await TokenStorage.clearToken();
        }
        handler.next(e);
      },
    ));
  }
}

String _resolveBaseUrl() {
  if (kIsWeb) {
    // On web, use same host the app is served from, port 3000
    final host = Uri.base.host.isEmpty ? 'localhost' : Uri.base.host;
    final scheme = Uri.base.scheme.isEmpty ? 'http' : Uri.base.scheme;
    return '$scheme://$host:3000';
  }
  // Android emulator -> host machine
  return 'http://10.0.2.2:3000';
}
