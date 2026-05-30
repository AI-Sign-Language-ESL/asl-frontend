import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_service.dart';

class GoogleAuthException implements Exception {
  final String userFriendlyMessage;
  const GoogleAuthException(this.userFriendlyMessage);

  @override
  String toString() => userFriendlyMessage;
}

class GoogleAuthService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static Future<Map<String, dynamic>> loginWithGoogle(String idToken) async {
    try {
      final response = await ApiService.dio.post(
        '/api/v1/authentication/login/google/',
        data: {'token': idToken},
      );

      final data = response.data as Map<String, dynamic>;
      final access = data['access'] as String?;
      final refresh = data['refresh'] as String?;
      final user = data['user'] as Map<String, dynamic>?;

      if (access == null || refresh == null) {
        throw const GoogleAuthException(
            'Server error. Please try again later.');
      }

      await _storage.write(key: 'access', value: access);
      await _storage.write(key: 'refresh', value: refresh);
      ApiService.setTokens(access: access, refresh: refresh);

      return user ?? {};
    } on GoogleAuthException {
      rethrow;
    } on DioException catch (e) {
      throw GoogleAuthException(_mapDioError(e));
    } catch (e) {
      throw const GoogleAuthException('Unable to sign in with Google.');
    }
  }

  static String _mapDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return 'Network error. Please try again.';
      case DioExceptionType.connectionError:
        return 'Network error. Please try again.';
      case DioExceptionType.cancel:
        return 'Google sign-in was cancelled.';
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final body = e.response?.data;
        if (statusCode == 400 || statusCode == 422) {
          if (body is Map && body['detail'] != null) {
            return body['detail'].toString();
          }
          if (body is Map && body['error'] != null) {
            return body['error'].toString();
          }
          return 'Unable to sign in with Google.';
        }
        if (statusCode == 401) {
          return 'Invalid Google credentials. Please try again.';
        }
        if (statusCode != null && statusCode >= 500) {
          return 'Server error. Please try again later.';
        }
        return 'Unable to sign in with Google.';
      default:
        return 'Unable to sign in with Google.';
    }
  }
}
