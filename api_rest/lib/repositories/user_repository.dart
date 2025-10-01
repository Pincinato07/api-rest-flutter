import 'package:dio/dio.dart';
import '../core/api_client.dart';

class UserRepository {
  final Dio _dio = ApiClient().dio;

  Future<List<Map<String, dynamic>>> list() async {
    final res = await _dio.get('/users');
    final data = res.data as List<dynamic>;
    return data.cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> getById(String id) async {
    final res = await _dio.get('/users/$id');
    return (res.data as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> create({
    required String name,
    required String email,
    required String password,
    required String role, // 'ADMIN' or 'USER'
  }) async {
    final res = await _dio.post('/users', data: {
      'name': name,
      'email': email,
      'password': password,
      'role': role,
    });
    return (res.data as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> update(String id, {required String name}) async {
    final res = await _dio.put('/users/$id', data: {
      'name': name,
    });
    return (res.data as Map<String, dynamic>);
  }

  Future<void> delete(String id) async {
    await _dio.delete('/users/$id');
  }
}
