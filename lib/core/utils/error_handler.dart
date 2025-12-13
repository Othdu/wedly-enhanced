import 'package:wedly/data/services/api_exceptions.dart';

/// Error Handler Utility
/// Provides user-friendly error messages for different exception types
class ErrorHandler {
  /// Get user-friendly message from any exception
  /// Returns a bilingual message (Arabic first, then English)
  static String getUserFriendlyMessage(dynamic error) {
    if (error is ApiException) {
      return error.message;
    }

    // Fallback for non-API exceptions
    return 'حدث خطأ غير متوقع. الرجاء المحاولة مرة أخرى.\n'
        'An unexpected error occurred. Please try again.';
  }

  /// Get error message for specific exception types with context
  static String getContextualMessage(dynamic error, String context) {
    if (error is TlsHandshakeException || error is SslCertificateException) {
      return 'فشل الاتصال الآمن. قد تكون هناك مشكلة مؤقتة في الخادم.\n'
          'الرجاء المحاولة لاحقاً.\n\n'
          'Secure connection failed. There may be a temporary server issue.\n'
          'Please try again later.';
    }

    if (error is NoInternetException) {
      return 'لا يوجد اتصال بالإنترنت.\n'
          'الرجاء التحقق من الشبكة والمحاولة مرة أخرى.\n\n'
          'No internet connection.\n'
          'Please check your network and try again.';
    }

    if (error is TimeoutException) {
      return 'انتهت مهلة الاتصال بالخادم.\n'
          'الرجاء المحاولة مرة أخرى.\n\n'
          'Connection timeout.\n'
          'Please try again.';
    }

    if (error is ServerException) {
      return 'الخادم غير متاح حالياً.\n'
          'الرجاء المحاولة بعد قليل.\n\n'
          'Server is currently unavailable.\n'
          'Please try again in a moment.';
    }

    if (error is ValidationException) {
      // Try to extract validation errors
      if (error.errors != null) {
        final errors = error.errors!;
        final firstError = errors.values.first;
        if (firstError is List && firstError.isNotEmpty) {
          return firstError.first.toString();
        }
      }
      return 'البيانات المدخلة غير صحيحة. الرجاء التحقق والمحاولة مرة أخرى.\n'
          'Invalid input. Please check your data and try again.';
    }

    if (error is UnauthorizedException) {
      return 'جلستك انتهت. الرجاء تسجيل الدخول مرة أخرى.\n'
          'Session expired. Please login again.';
    }

    return getUserFriendlyMessage(error);
  }

  /// Check if error is a network-related error
  static bool isNetworkError(dynamic error) {
    return error is NoInternetException ||
        error is ConnectionException ||
        error is TimeoutException ||
        error is TlsHandshakeException ||
        error is SslCertificateException;
  }

  /// Check if error is a security-related error
  static bool isSecurityError(dynamic error) {
    return error is TlsHandshakeException ||
        error is SslCertificateException ||
        error is UnauthorizedException ||
        error is ForbiddenException;
  }

  /// Check if error should trigger logout
  static bool shouldLogout(dynamic error) {
    return error is SessionExpiredException || error is UnauthorizedException;
  }

  /// Get error icon based on error type
  static String getErrorIcon(dynamic error) {
    if (error is NoInternetException) return '📡';
    if (error is TlsHandshakeException || error is SslCertificateException) {
      return '🔒';
    }
    if (error is TimeoutException) return '⏱️';
    if (error is ServerException) return '🔧';
    if (error is ValidationException) return '⚠️';
    if (error is UnauthorizedException) return '🔐';
    return '❌';
  }
}
