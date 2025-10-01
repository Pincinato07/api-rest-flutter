import 'package:dio/dio.dart';
import '../core/api_client.dart';
import '../models/course.dart';

class CourseRepository {
  final Dio _dio = ApiClient().dio;

  Future<List<CourseModel>> list() async {
    final res = await _dio.get('/courses');
    final data = res.data as List<dynamic>;
    return data.map((e) => CourseModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<CourseModel> create(CourseModel input) async {
    final res = await _dio.post('/courses', data: input.toJson());
    return CourseModel.fromJson(res.data);
  }

  Future<CourseModel> update(String id, CourseModel input) async {
    final res = await _dio.put('/courses/$id', data: input.toJson());
    return CourseModel.fromJson(res.data);
  }

  Future<void> delete(String id) async {
    await _dio.delete('/courses/$id');
  }
}
