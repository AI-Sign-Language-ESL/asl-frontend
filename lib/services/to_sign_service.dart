import 'package:dio/dio.dart';
import 'api_service.dart';

class SignTranslationService {
  final Dio dio = ApiService.dio;

  Future<String> translateTextToSign({
    required String text,
  }) async {
    try {
      final response = await dio.post(
        '/translation/to-sign/',
        data: {'text': text},
        options: Options(
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer ${ApiService.accessToken}",
          },
        ),
      );

      return response.data['video'] ?? '';
    } catch (e) {
      print("to-sign backend failed: $e");

      return "https://www.api.tafahom.io/media/generated/test_fallback.mp4";
    }
  }
}