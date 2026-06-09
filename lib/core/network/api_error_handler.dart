import 'package:dio/dio.dart';
import 'api_exceptions.dart';

class ApiErrorHandler {
  static ApiException handle(dynamic error) {
    if (error is DioException) {
      return _handleDioException(error);
    } else {
      return ApiException("An unexpected error occurred: ${error.toString()}");
    }
  }

  static ApiException _handleDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return NetworkException();
      case DioExceptionType.badResponse:
        return _handleBadResponse(error.response);
      case DioExceptionType.cancel:
        return ApiException("Request to server was cancelled.");
      case DioExceptionType.badCertificate:
        return ApiException("Bad certificate from server.");
      case DioExceptionType.unknown:
        return ApiException("An unexpected networking error occurred.");
    }
  }

  static ApiException _handleBadResponse(Response? response) {
    if (response == null) {
      return ServerException();
    }

    final int statusCode = response.statusCode ?? 500;
    final data = response.data;

    // Helper to extract common 'detail' or 'message' fields from response
    String extractMessage(String defaultMessage) {
      if (data is Map<String, dynamic>) {
        if (data.containsKey('detail')) return data['detail'].toString();
        if (data.containsKey('message')) return data['message'].toString();
        if (data.containsKey('error')) return data['error'].toString();
      } else if (data is String && data.isNotEmpty) {
        return data;
      }
      return defaultMessage;
    }

    switch (statusCode) {
      case 400:
        return ValidationException(
          "Validation Error",
          data is Map<String, dynamic> ? data : null,
          statusCode,
        );
      case 401:
        return UnauthorizedException(extractMessage("Unauthorized access."), statusCode);
      case 403:
        return ForbiddenException(extractMessage("Access forbidden."), statusCode);
      case 404:
        return ApiException(extractMessage("Resource not found."), statusCode);
      case 429:
        int? retryAfter;
        // Try to get Retry-After from headers if available
        if (response.headers.value('Retry-After') != null) {
          retryAfter = int.tryParse(response.headers.value('Retry-After')!);
        }
        
        // Sometimes backend includes expected wait time in 'detail' or similar fields
        // Let RateLimitException handle it or use extracted retryAfter
        return RateLimitException(extractMessage("Too many requests."), retryAfter, statusCode);
      case 500:
      case 502:
      case 503:
      case 504:
      default:
        return ServerException(extractMessage("Server error occurred."), statusCode);
    }
  }
}
