import 'package:flutter/material.dart';
import 'package:wedly/data/services/api_exceptions.dart';

/// A reusable error view widget that displays user-friendly error messages
/// with icons, descriptions, and action buttons based on the error type
class ErrorView extends StatelessWidget {
  final dynamic error;
  final VoidCallback? onRetry;
  final VoidCallback? onGoBack;
  final String? customMessage;
  final bool showBackButton;

  const ErrorView({
    super.key,
    required this.error,
    this.onRetry,
    this.onGoBack,
    this.customMessage,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final errorInfo = _getErrorInfo();

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Error Icon with animated container
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: child,
                );
              },
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: errorInfo.color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  errorInfo.icon,
                  size: 64,
                  color: errorInfo.color,
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Error Title
            Text(
              errorInfo.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 12),

            // Error Description
            Text(
              customMessage ?? errorInfo.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 32),

            // Action Buttons
            if (onRetry != null) ...[
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text(
                    'إعادة المحاولة',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],

            if (showBackButton && onGoBack != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: onGoBack,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text(
                    'العودة للخلف',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey.shade700,
                    side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],

            // Additional help text for specific errors
            if (errorInfo.helpText != null) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.blue.shade100,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: Colors.blue.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        errorInfo.helpText!,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue.shade700,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  ErrorInfo _getErrorInfo() {
    // Handle different error types
    if (error is NoInternetException) {
      return ErrorInfo(
        icon: Icons.wifi_off_rounded,
        color: Colors.orange,
        title: 'لا توجد اتصال بالإنترنت',
        description:
            'يرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى',
        helpText:
            'تأكد من تفعيل الواي فاي أو بيانات الجوال، ثم اضغط إعادة المحاولة',
      );
    } else if (error is TimeoutException) {
      return ErrorInfo(
        icon: Icons.timer_off_rounded,
        color: Colors.amber,
        title: 'انتهت مهلة الطلب',
        description:
            'استغرق الاتصال بالخادم وقتاً طويلاً. يرجى المحاولة مرة أخرى',
        helpText: 'قد يكون الإنترنت بطيئاً. جرّب الاتصال بشبكة أسرع',
      );
    } else if (error is ServerException) {
      return ErrorInfo(
        icon: Icons.cloud_off_rounded,
        color: Colors.red,
        title: 'خطأ في الخادم',
        description:
            'حدثت مشكلة في الخادم. نعمل على حلها في أقرب وقت',
        helpText: 'حاول مرة أخرى بعد قليل. إذا استمرت المشكلة، تواصل مع الدعم الفني',
      );
    } else if (error is UnauthorizedException ||
        error is SessionExpiredException) {
      return ErrorInfo(
        icon: Icons.lock_outline_rounded,
        color: Colors.deepOrange,
        title: 'انتهت جلستك',
        description: 'يرجى تسجيل الدخول مرة أخرى للمتابعة',
        helpText: 'ستحتاج لإدخال بيانات تسجيل الدخول مرة أخرى',
      );
    } else if (error is ForbiddenException) {
      return ErrorInfo(
        icon: Icons.block_rounded,
        color: Colors.red,
        title: 'غير مسموح',
        description: 'ليس لديك صلاحية للوصول إلى هذا المحتوى',
      );
    } else if (error is NotFoundException) {
      return ErrorInfo(
        icon: Icons.search_off_rounded,
        color: Colors.grey,
        title: 'لم يتم العثور على المحتوى',
        description: 'المحتوى المطلوب غير موجود أو تم حذفه',
      );
    } else if (error is ValidationException) {
      final validationError = error as ValidationException;
      String errorMessage = 'البيانات المدخلة غير صحيحة';

      // Extract first validation error if available
      if (validationError.errors != null &&
          validationError.errors!.isNotEmpty) {
        final firstError = validationError.errors!.values.first;
        if (firstError is List && firstError.isNotEmpty) {
          errorMessage = firstError.first.toString();
        }
      }

      return ErrorInfo(
        icon: Icons.error_outline_rounded,
        color: Colors.orange,
        title: 'خطأ في البيانات',
        description: errorMessage,
        helpText: 'راجع المعلومات المدخلة وتأكد من صحتها',
      );
    } else if (error is ClientException) {
      return ErrorInfo(
        icon: Icons.warning_amber_rounded,
        color: Colors.orange,
        title: 'خطأ في الطلب',
        description:
            'حدث خطأ أثناء معالجة طلبك. يرجى المحاولة مرة أخرى',
      );
    }

    // Default/Unknown error
    return ErrorInfo(
      icon: Icons.error_outline_rounded,
      color: Colors.red,
      title: 'حدث خطأ ما',
      description: error?.toString() ?? 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى',
      helpText: 'إذا استمرت المشكلة، يرجى التواصل مع الدعم الفني',
    );
  }
}

/// Error information model for consistent error display
class ErrorInfo {
  final IconData icon;
  final Color color;
  final String title;
  final String description;
  final String? helpText;

  ErrorInfo({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
    this.helpText,
  });
}
