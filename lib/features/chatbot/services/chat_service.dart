import 'package:dio/dio.dart';
import 'package:tafahom_english_light/core/network/api_error_handler.dart';
import 'package:tafahom_english_light/core/network/api_exceptions.dart';
import 'package:tafahom_english_light/services/api_service.dart';

import '../models/chat_message.dart';
import '../models/welcome_data.dart';

class ChatService {
  final Dio _dio = ApiService.dio;

  Future<ChatMessage> sendMessage({
    required String message,
    List<ChatMessage> history = const [],
  }) async {
    try {
      final response = await _dio.post(
        '/api/v1/chat/',
        data: {
          'message': message,
          'history': history.map((m) => m.toJson()).toList(),
        },
      );

      final data = response.data as Map<String, dynamic>;
      return ChatMessage.fromJson(data);
    } on DioException catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  Future<ChatMessage> sendVoiceMessage({
    required String audioPath,
    required double duration,
    String? transcription,
    List<ChatMessage> history = const [],
  }) async {
    try {
      final formData = FormData.fromMap({
        'audio': await MultipartFile.fromFile(
          audioPath,
          filename: 'voice_${DateTime.now().millisecondsSinceEpoch}.m4a',
        ),
        'duration': duration,
        if (transcription != null) 'transcription': transcription,
        'history': history.map((m) => m.toJson()).toList(),
      });

      final response = await _dio.post(
        '/api/v1/chat/voice/',
        data: formData,
      );

      final data = response.data as Map<String, dynamic>;
      return ChatMessage.fromJson(data);
    } on DioException catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  Future<List<ChatMessage>> fetchHistory() async {
    try {
      final response = await _dio.get('/api/v1/chat/history/');
      final data = response.data as List;
      return data.map((e) => ChatMessage.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  Future<void> clearHistory() async {
    try {
      await _dio.delete('/api/v1/chat/history/');
    } on DioException catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }

  Future<WelcomeData> fetchWelcomeData() async {
    try {
      final response = await _dio.get('/api/v1/chat/welcome/');
      final data = response.data as Map<String, dynamic>;
      return WelcomeData.fromJson(data);
    } on DioException catch (e) {
      throw ApiErrorHandler.handle(e);
    }
  }
}
