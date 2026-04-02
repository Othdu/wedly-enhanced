import 'package:wedly/data/services/api_exceptions.dart';

/// Error Handler Utility
/// Provides clean, user-friendly Arabic error messages.
class ErrorHandler {
  /// Get a user-friendly message from any exception
  static String getUserFriendlyMessage(dynamic error) {
    if (error is NoInternetException) {
      return 'لا يوجد اتصال بالإنترنت، تحقق من الشبكة وحاول مجدداً.';
    }
    if (error is TimeoutException) {
      return 'انتهت مهلة الاتصال، الخادم يستغرق وقتاً أطول من المعتاد.';
    }
    if (error is ServerException) {
      return 'الخادم غير متاح حالياً، حاول مرة أخرى بعد قليل.';
    }
    if (error is TlsHandshakeException || error is SslCertificateException) {
      return 'فشل الاتصال الآمن، هناك مشكلة مؤقتة في الخادم.';
    }
    if (error is ConnectionException) {
      return 'تعذّر الاتصال بالخادم، تحقق من اتصالك وحاول مجدداً.';
    }
    if (error is UnauthorizedException) {
      return 'انتهت جلستك، سجّل الدخول مرة أخرى للمتابعة.';
    }
    if (error is SessionExpiredException) {
      return 'انتهت جلستك، سجّل الدخول مرة أخرى للمتابعة.';
    }
    if (error is ForbiddenException) {
      return 'ليس لديك صلاحية للوصول إلى هذا المحتوى.';
    }
    if (error is NotFoundException) {
      return 'المحتوى المطلوب غير موجود أو تم حذفه.';
    }
    if (error is ValidationException) {
      if (error.errors != null && error.errors!.isNotEmpty) {
        final firstError = error.errors!.values.first;
        if (firstError is List && firstError.isNotEmpty) {
          return firstError.first.toString();
        }
      }
      return 'البيانات المدخلة غير صحيحة، راجعها وحاول مجدداً.';
    }
    if (error is ClientException) {
      return 'حدث خطأ في الطلب، حاول مرة أخرى.';
    }
    if (error is ApiException) {
      return error.message;
    }
    return 'حدث خطأ غير متوقع، حاول مرة أخرى.';
  }

  /// Get error message with context (e.g. during login vs other screens)
  static String getContextualMessage(dynamic error, String context) {
    if (error is UnauthorizedException) {
      if (context == 'login') {
        return 'البريد الإلكتروني أو كلمة المرور غير صحيحة.';
      }
      return 'انتهت جلستك، سجّل الدخول مرة أخرى للمتابعة.';
    }
    return getUserFriendlyMessage(error);
  }

  /// Check if error is network-related
  static bool isNetworkError(dynamic error) {
    return error is NoInternetException ||
        error is ConnectionException ||
        error is TimeoutException ||
        error is TlsHandshakeException ||
        error is SslCertificateException;
  }

  /// Check if error is security-related
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

  /// Get icon for error type
  static String getErrorIcon(dynamic error) {
    if (error is NoInternetException) return '📡';
    if (error is TlsHandshakeException || error is SslCertificateException) return '🔒';
    if (error is TimeoutException) return '⏱️';
    if (error is ServerException) return '🔧';
    if (error is ValidationException) return '⚠️';
    if (error is UnauthorizedException) return '🔐';
    return '❌';
  }
}