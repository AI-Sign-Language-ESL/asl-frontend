// lib/services/dataset_contribution_service.dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:tafahom_english_light/core/network/dio_client.dart';

class DatasetContributionService {
  final Dio _dio = DioClient().dio;

  /// Upload dataset contribution (video + label)
  Future<void> uploadContribution({
    required File video,
    required String label,
  }) async {
    final formData = FormData.fromMap({
      "label": label,
      "video": await MultipartFile.fromFile(
        video.path,
        filename: video.path.split('/').last,
      ),
    });

    await _dio.post(
      "/api/dataset/upload/",
      data: formData,
    );
  }

  /// My contributions
  Future<List<dynamic>> myContributions() async {
    final response = await _dio.get("/api/dataset/my/");
    return response.data;
  }

  /// Admin – pending contributions
  Future<List<dynamic>> pendingContributions() async {
    final response = await _dio.get("/api/dataset/pending/");
    return response.data;
  }
}
