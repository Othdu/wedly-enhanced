import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wedly/core/constants/app_colors.dart';
import 'package:wedly/core/di/injection_container.dart';
import 'package:wedly/core/utils/enums.dart';
import 'package:wedly/data/repositories/auth_repository.dart';
import 'package:wedly/routes/app_router.dart';

class SignupOtpScreen extends StatefulWidget {
  final String phoneOrEmail;
  final UserRole userRole;

  const SignupOtpScreen({
    super.key,
    required this.phoneOrEmail,
    required this.userRole,
  });

  @override
  State<SignupOtpScreen> createState() => _SignupOtpScreenState();
}

class _SignupOtpScreenState extends State<SignupOtpScreen> {
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isLoading = false;
  bool _isResendDisabled = false;
  int _resendCountdown = 60;
  Timer? _timer;

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _handleOtpSubmit() async {
    final otp = _otpControllers.map((c) => c.text).join();

    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'الرجاء إدخال الكود كاملاً (6 أرقام)',
            textDirection: TextDirection.rtl,
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authRepository = getIt<AuthRepository>();
      final user = await authRepository.verifyOtp(
        email: widget.phoneOrEmail,
        otp: otp,
      );

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم التحقق بنجاح!',
              textDirection: TextDirection.rtl,
            ),
            backgroundColor: AppColors.gold,
          ),
        );

        // Navigate to success screen
        Navigator.of(context).pushReplacementNamed(
          AppRouter.signupSuccess,
          arguments: {
            'userRole': widget.userRole,
          },
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        _showErrorDialog('الكود غير صحيح. الرجاء المحاولة مرة أخرى');
      }
    }
  }

  Future<void> _resendOtp() async {
    if (_isResendDisabled) return;

    setState(() {
      _isResendDisabled = true;
      _resendCountdown = 60;
    });

    // Start countdown timer
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendCountdown > 0) {
          _resendCountdown--;
        } else {
          _isResendDisabled = false;
          timer.cancel();
        }
      });
    });

    try {
      final authRepository = getIt<AuthRepository>();
      final result = await authRepository.resendOtp(
        email: widget.phoneOrEmail,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message'] ?? 'تم إعادة إرسال الكود',
              textDirection: TextDirection.rtl,
            ),
            backgroundColor: AppColors.gold,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'حدث خطأ أثناء إعادة إرسال الكود',
              textDirection: TextDirection.rtl,
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'خطأ',
          textDirection: TextDirection.rtl,
          style: TextStyle(
            color: AppColors.gold,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          message,
          textDirection: TextDirection.rtl,
          style: TextStyle(
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'حسناً',
              style: TextStyle(
                color: AppColors.gold,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gold,
      appBar: AppBar(
        backgroundColor: AppColors.gold,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'أدخل كود التحقق',
          style: const TextStyle(
            color: AppColors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // White card
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      // Icon
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.greyBackground,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.mail_outline,
                          size: 40,
                          color: AppColors.gold,
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Title
                      Text(
                        'من فضلك أدخل الكود المرسل إلى بريدك الإلكتروني لتأكيد حسابك.',
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.textPrimary,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Subtitle with number
                      Text(
                        'أدخل الكود المكون من 6 أرقام',
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 40),
                      // OTP Input boxes
                      Directionality(
                        textDirection: TextDirection.rtl,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(6, (index) {
                            return Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4),
                              child: _buildOtpBox(5 - index), // Reverse order for RTL
                            );
                          }),
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Submit button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleOtpSubmit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.gold,
                            foregroundColor: AppColors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.white,
                                  ),
                                )
                              : Text(
                                  'تأكيد',
                                  textDirection: TextDirection.rtl,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Resend code
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'لم تستلم الكود؟',
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: _isResendDisabled ? null : _resendOtp,
                            child: Text(
                              _isResendDisabled
                                  ? 'أعد الإرسال ($_resendCountdown)'
                                  : 'أعد الإرسال',
                              style: TextStyle(
                                color: _isResendDisabled
                                    ? AppColors.textSecondary
                                    : AppColors.gold,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtpBox(int index) {
    return SizedBox(
      width: 50,
      height: 60,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.greyBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _otpControllers[index].text.isNotEmpty
                ? AppColors.gold
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Center(
          child: TextField(
            controller: _otpControllers[index],
            focusNode: _focusNodes[index],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            obscureText: false,
            enableSuggestions: false,
            autocorrect: false,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
              letterSpacing: 0,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            decoration: const InputDecoration(
              counterText: '',
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              isDense: true,
            ),
            onChanged: (value) {
              setState(() {}); // Rebuild to show border color change
              if (value.isNotEmpty && index > 0) {
                _focusNodes[index - 1].requestFocus();
              } else if (value.isEmpty && index < 5) {
                _focusNodes[index + 1].requestFocus();
              }
            },
          ),
        ),
      ),
    );
  }
}
