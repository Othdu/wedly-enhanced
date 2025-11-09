/// Custom API Exception classes for better error handling
/// These exceptions wrap different types of network and API errors

/// Base class for all API exceptions
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException({
    required this.message,
    this.statusCode,
    this.data,
  });

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

/// Exception thrown when there's no internet connection
class NoInternetException extends ApiException {
  NoInternetException()
      : super(
          message: 'No internet connection. Please check your network.',
          statusCode: 0,
        );
}

/// Exception thrown when request times out
class TimeoutException extends ApiException {
  TimeoutException()
      : super(
          message: 'Request timeout. Please try again.',
          statusCode: 408,
        );
}

/// Exception thrown for server errors (5xx)
class ServerException extends ApiException {
  ServerException({String? message, int? statusCode})
      : super(
          message: message ?? 'Server error occurred. Please try again later.',
          statusCode: statusCode ?? 500,
        );
}

/// Exception thrown for client errors (4xx)
class ClientException extends ApiException {
  ClientException({String? message, int? statusCode, dynamic data})
      : super(
          message: message ?? 'Client error occurred.',
          statusCode: statusCode ?? 400,
          data: data,
        );
}

/// Exception thrown when authentication fails
class UnauthorizedException extends ApiException {
  UnauthorizedException({String? message})
      : super(
          message: message ?? 'Unauthorized. Please login again.',
          statusCode: 401,
        );
}

/// Exception thrown when user doesn't have permission
class ForbiddenException extends ApiException {
  ForbiddenException({String? message})
      : super(
          message: message ?? 'Access forbidden.',
          statusCode: 403,
        );
}

/// Exception thrown when resource is not found
class NotFoundException extends ApiException {
  NotFoundException({String? message})
      : super(
          message: message ?? 'Resource not found.',
          statusCode: 404,
        );
}

/// Exception thrown when there's a validation error
class ValidationException extends ApiException {
  final Map<String, dynamic>? errors;

  ValidationException({String? message, this.errors})
      : super(
          message: message ?? 'Validation error.',
          statusCode: 422,
          data: errors,
        );
}

/// Exception thrown for unknown/unexpected errors
class UnknownException extends ApiException {
  UnknownException({String? message})
      : super(
          message: message ?? 'An unexpected error occurred.',
        );
}
