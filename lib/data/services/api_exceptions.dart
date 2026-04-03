// Custom API Exception classes for better error handling
// These exceptions wrap different types of network and API errors

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
  String toString() => message;
}

/// Exception thrown when there's no internet connection
class NoInternetException extends ApiException {
  NoInternetException()
      : super(
          message: 'لا يوجد اتصال بالإنترنت. الرجاء التحقق من الشبكة.',
          statusCode: 0,
        );
}

/// Exception thrown when request times out
class TimeoutException extends ApiException {
  TimeoutException()
      : super(
          message: 'انتهت مهلة الطلب. الرجاء المحاولة مرة أخرى.',
          statusCode: 408,
        );
}

/// Exception thrown for server errors (5xx)
class ServerException extends ApiException {
  ServerException({String? message, int? statusCode})
      : super(
          message: message ??
              'خطأ في الخادم. الرجاء المحاولة لاحقاً.',
          statusCode: statusCode ?? 500,
        );
}

/// Exception thrown for client errors (4xx)
class ClientException extends ApiException {
  ClientException({String? message, int? statusCode, super.data})
      : super(
          message: message ??
              'خطأ في الطلب. حاول مرة أخرى.',
          statusCode: statusCode ?? 400,
        );
}

/// Exception thrown when authentication fails
class UnauthorizedException extends ApiException {
  UnauthorizedException({String? message})
      : super(
          message: message ??
              'غير مصرح. الرجاء تسجيل الدخول مرة أخرى.',
          statusCode: 401,
        );
}

/// Exception thrown when user doesn't have permission
class ForbiddenException extends ApiException {
  ForbiddenException({String? message})
      : super(
          message: message ??
              'الوصول محظور.',
          statusCode: 403,
        );
}

/// Exception thrown when resource is not found
class NotFoundException extends ApiException {
  NotFoundException({String? message})
      : super(
          message: message ??
              'العنصر غير موجود.',
          statusCode: 404,
        );
}

/// Exception thrown when there's a validation error
class ValidationException extends ApiException {
  final Map<String, dynamic>? errors;

  ValidationException({String? message, this.errors})
      : super(
          message: message ??
              'خطأ في التحقق من البيانات.',
          statusCode: 422,
          data: errors,
        );
}

/// Exception thrown when a resource already exists (409 Conflict)
class ConflictException extends ApiException {
  ConflictException({String? message, super.data})
      : super(
          message: message ?? 'هذا العنصر موجود بالفعل.',
          statusCode: 409,
        );
}

/// Exception thrown for unknown/unexpected errors
class UnknownException extends ApiException {
  UnknownException({String? message})
      : super(
          message: message ??
              'حدث خطأ غير متوقع.',
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
              'خطأ في الاتصال الآمن. الرجاء التواصل مع الدعم الفني.',
          statusCode: 0,
        );
}

/// Exception thrown when there's a TLS handshake error
/// This indicates the server's SSL configuration is invalid or incompatible
class TlsHandshakeException extends ApiException {
  TlsHandshakeException({String? message})
      : super(
          message: message ??
              'عذراً، نواجه مشكلة مؤقتة في الاتصال الآمن.\n\n'
                  'يبدو أن خادم التطبيق يواجه مشكلة في إعدادات الأمان. '
                  'نحن نعمل على حل المشكلة في أقرب وقت ممكن.\n\n'
                  'يرجى:\n'
                  '• المحاولة مرة أخرى بعد قليل\n'
                  '• التحقق من اتصالك بالإنترنت\n'
                  '• التواصل مع الدعم الفني إذا استمرت المشكلة',
          statusCode: 0,
        );
}

/// Exception thrown when network connection fails
/// Different from NoInternetException - this is when connection attempt fails
class ConnectionException extends ApiException {
  ConnectionException({String? message})
      : super(
          message: message ??
              'فشل الاتصال بالخادم. الرجاء التحقق من اتصالك بالإنترنت.',
          statusCode: 0,
        );
}

/// Exception thrown when provider account is pending approval
class ProviderPendingApprovalException extends ApiException {
  ProviderPendingApprovalException({String? message})
      : super(
          message: message ??
              'حسابك قيد المراجعة. يرجى الانتظار حتى يتم الموافقة على حسابك.',
          statusCode: 403,
        );
}

/// Exception thrown when user tries to submit a duplicate review
class DuplicateReviewException extends ApiException {
  DuplicateReviewException({String? message})
      : super(
          message: message ?? 'لقد قمت بتقييم هذه الخدمة مسبقاً',
          statusCode: 400,
        );
}
