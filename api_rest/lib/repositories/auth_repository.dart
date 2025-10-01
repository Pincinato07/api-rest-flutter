import 'package:dio/dio.dart';
import '../core/api_client.dart';
import '../core/token_storage.dart';
import '../models/user.dart';
import '../core/user_cache.dart';

class AuthRepository {
  final Dio _dio = ApiClient().dio;

  Future<String> login({required String email, required String password}) async {
    final res = await _dio.post('/login', data: {
      'email': email,
      'password': password,
    });
    final token = res.data['token'] as String?;
    if (token == null || token.isEmpty) {
      throw Exception('Token não recebido.');
    }
    await TokenStorage.saveToken(token);
    return token;
  }

  Future<UserModel> me() async {
    final res = await _dio.get('/me');
    return UserModel.fromJson(res.data);
  }

  Future<void> logout() async {
    await TokenStorage.clearToken();
    await UserCache.clear();
  }
}
