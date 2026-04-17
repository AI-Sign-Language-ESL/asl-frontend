import 'package:dio/dio.dart';
import 'api_service.dart';

class DatasetService {
  final Dio _dio = ApiService.dio;

  Future<void> submitContribution({
    required String word,
    required String videoPath,
  }) async {
    final formData = FormData.fromMap({
      "word": word,
      "video": await MultipartFile.fromFile(videoPath),
    });

    await _dio.post(
      "/api/v1/dataset/contributions/",
      data: formData,
    );
  }
}
