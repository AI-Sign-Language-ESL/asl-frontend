class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

class RateLimitException extends ApiException {
  final int? retryAfterSeconds;

  RateLimitException(super.message, [this.retryAfterSeconds, super.statusCode]);

  @override
  String toString() {
    if (retryAfterSeconds != null) {
      return '$message Expected available in $retryAfterSeconds seconds.';
    }
    return message;
  }
}

class ValidationException extends ApiException {
  final Map<String, dynamic>? errors;

  ValidationException(super.message, [this.errors, super.statusCode]);

  @override
  String toString() {
    if (errors != null && errors!.isNotEmpty) {
      final buffer = StringBuffer();
      errors!.forEach((key, value) {
        if (value is List) {
          buffer.writeln('${key.toUpperCase()}: ${value.join(', ')}');
        } else {
          buffer.writeln('${key.toUpperCase()}: $value');
        }
      });
      return buffer.toString().trim();
    }
    return message;
  }
}

class UnauthorizedException extends ApiException {
  UnauthorizedException([super.message = "Session expired. Please log in again.", super.statusCode = 401]);
}

class ForbiddenException extends ApiException {
  ForbiddenException([super.message = "You do not have permission to perform this action.", super.statusCode = 403]);
}

class ServerException extends ApiException {
  ServerException([super.message = "An internal server error occurred.", super.statusCode]);
}

class NetworkException extends ApiException {
  NetworkException([super.message = "No internet connection or server is unreachable.", super.statusCode]);
}
