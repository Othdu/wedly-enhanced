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
          message: 'لا يوجد اتصال بالإنترنت. الرجاء التحقق من الشبكة.\n'
              'No internet connection. Please check your network.',
          statusCode: 0,
        );
}

/// Exception thrown when request times out
class TimeoutException extends ApiException {
  TimeoutException()
      : super(
          message: 'انتهت مهلة الطلب. الرجاء المحاولة مرة أخرى.\n'
              'Request timeout. Please try again.',
          statusCode: 408,
        );
}

/// Exception thrown for server errors (5xx)
class ServerException extends ApiException {
  ServerException({String? message, int? statusCode})
      : super(
          message: message ??
              'خطأ في الخادم. الرجاء المحاولة لاحقاً.\n'
                  'Server error occurred. Please try again later.',
          statusCode: statusCode ?? 500,
        );
}

/// Exception thrown for client errors (4xx)
class ClientException extends ApiException {
  ClientException({String? message, int? statusCode, dynamic data})
      : super(
          message: message ??
              'خطأ في الطلب.\n'
                  'Client error occurred.',
          statusCode: statusCode ?? 400,
          data: data,
        );
}

/// Exception thrown when authentication fails
class UnauthorizedException extends ApiException {
  UnauthorizedException({String? message})
      : super(
          message: message ??
              'غير مصرح. الرجاء تسجيل الدخول مرة أخرى.\n'
                  'Unauthorized. Please login again.',
          statusCode: 401,
        );
}

/// Exception thrown when user doesn't have permission
class ForbiddenException extends ApiException {
  ForbiddenException({String? message})
      : super(
          message: message ??
              'الوصول محظور.\n'
                  'Access forbidden.',
          statusCode: 403,
        );
}

/// Exception thrown when resource is not found
class NotFoundException extends ApiException {
  NotFoundException({String? message})
      : super(
          message: message ??
              'العنصر غير موجود.\n'
                  'Resource not found.',
          statusCode: 404,
        );
}

/// Exception thrown when there's a validation error
class ValidationException extends ApiException {
  final Map<String, dynamic>? errors;

  ValidationException({String? message, this.errors})
      : super(
          message: message ??
              'خطأ في التحقق من البيانات.\n'
                  'Validation error.',
          statusCode: 422,
          data: errors,
        );
}

/// Exception thrown for unknown/unexpected errors
class UnknownException extends ApiException {
  UnknownException({String? message})
      : super(
          message: message ??
              'حدث خطأ غير متوقع.\n'
                  'An unexpected error occurred.',
        );
}

/// Exception thrown when refresh token expires (session truly expired)
/// This triggers logout flow in the app
class SessionExpiredException extends ApiException {
  SessionExpiredException({String? message})
      : super(
          message: message ?? 'جلستك انتهت. يرجى تسجيل الدخول مرة أخرى.',
          statusCode: 401,
        );
}

/// Exception thrown when SSL/TLS certificate validation fails
/// This indicates a security issue with the server's certificate
class SslCertificateException extends ApiException {
  SslCertificateException({String? message})
      : super(
          message: message ??
              'خطأ في الاتصال الآمن. الرجاء التواصل مع الدعم الفني.\n'
                  'SSL certificate error. Please contact support.',
          statusCode: 0,
        );
}

/// Exception thrown when there's a TLS handshake error
/// This indicates the server's SSL configuration is invalid or incompatible
class TlsHandshakeException extends ApiException {
  TlsHandshakeException({String? message})
      : super(
          message: message ??
              'فشل الاتصال الآمن بالخادم. قد تكون هناك مشكلة في إعدادات الأمان.\n'
                  'الرجاء المحاولة لاحقاً أو التواصل مع الدعم الفني.\n\n'
                  'Secure connection failed. There may be a server security configuration issue.\n'
                  'Please try again later or contact support.',
          statusCode: 0,
        );
}

/// Exception thrown when network connection fails
/// Different from NoInternetException - this is when connection attempt fails
class ConnectionException extends ApiException {
  ConnectionException({String? message})
      : super(
          message: message ??
              'فشل الاتصال بالخادم. الرجاء التحقق من اتصالك بالإنترنت.\n'
                  'Connection to server failed. Please check your internet connection.',
          statusCode: 0,
        );
}

/// Exception thrown when provider account is pending approval
class ProviderPendingApprovalException extends ApiException {
  ProviderPendingApprovalException({String? message})
      : super(
          message: message ??
              'حسابك قيد المراجعة. يرجى الانتظار حتى يتم الموافقة على حسابك.\n'
                  'Your account is pending approval. Please wait for your account to be approved.',
          statusCode: 403,
        );
}
