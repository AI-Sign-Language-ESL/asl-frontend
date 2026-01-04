import 'package:dio/dio.dart';
import 'package:tafahom_english_light/core/network/dio_client.dart';

class ProfileService {
  final Dio _dio = DioClient().dio;

  Future<Map<String, dynamic>> getProfile() async {
    final response = await _dio.get('/auth/me/');
    return response.data;
  }
}
