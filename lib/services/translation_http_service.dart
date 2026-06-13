import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'api_service.dart';

class TranslationHttpService {
  Future<Map<String, dynamic>> predictModal(List<List<List<double>>> sequence) async {
    try {
      final response = await ApiService.dio.post(
        '/api/translation/predict',
        data: {'sequence': sequence},
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      debugPrint('[HTTP] predictModal error: ${e.response?.data ?? e.message}');
      throw Exception(e.response?.data?['error'] ?? 'HTTP Request failed');
    } catch (e) {
      debugPrint('[HTTP] predictModal error: $e');
      throw Exception('HTTP Request failed: $e');
    }
  }

  Future<Map<String, dynamic>> translateGloss(String gloss) async {
    try {
      final response = await ApiService.dio.post(
        '/api/translation/translate',
        data: {'gloss': gloss},
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      debugPrint('[HTTP] translateGloss error: ${e.response?.data ?? e.message}');
      throw Exception(e.response?.data?['error'] ?? 'NLP Translation failed');
    } catch (e) {
      debugPrint('[HTTP] translateGloss error: $e');
      throw Exception('NLP Translation failed: $e');
    }
  }
}
