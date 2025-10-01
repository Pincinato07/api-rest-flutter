import 'package:dio/dio.dart';

String humanizeError(Object error) {
  if (error is DioException) {
    final code = error.response?.statusCode;
    final data = error.response?.data;
    String? message;
    if (data is Map && data['message'] is String) {
      message = data['message'] as String;
    } else if (data is String) {
      message = data;
    }
    return message ?? 'Erro de rede${code != null ? ' ($code)' : ''}';
  }
  return error.toString();
}
