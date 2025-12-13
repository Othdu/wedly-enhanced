import 'package:flutter/material.dart';
import 'package:wedly/core/constants/app_colors.dart';
import 'package:wedly/core/di/injection_container.dart';
import 'package:wedly/data/repositories/auth_repository.dart';
import 'package:wedly/routes/app_router.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final authRepository = getIt<AuthRepository>();
        final result = await authRepository.forgotPassword(
          email: _emailController.text.trim(),
        );

        setState(() {
          _isLoading = false;
        });

        if (result['success'] == true) {
          if (mounted) {
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  result['message'] ?? 'تم إرسال رمز التحقق إلى بريدك الإلكتروني',
                  textDirection: TextDirection.rtl,
                ),
                backgroundColor: AppColors.gold,
              ),
            );

            // Navigate to OTP verification screen
            Navigator.of(context).pushNamed(
              AppRouter.otpVerification,
              arguments: {
                'phoneOrEmail': _emailController.text.trim(),
                'isForPasswordReset': true,
              },
            );
          }
        } else {
          if (mounted) {
            _showErrorDialog(result['message'] ?? 'حدث خطأ أثناء إرسال الكود');
          }
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });

        if (mounted) {
          _showErrorDialog('حدث خطأ أثناء إرسال الكود. الرجاء المحاولة مرة أخرى');
        }
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
          'نسيت كلمة المرور',
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
            const SizedBox(height: 40),
            // Progress indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildProgressDot(true),
                const SizedBox(width: 8),
                _buildProgressDot(false),
                const SizedBox(width: 8),
                _buildProgressDot(false),
              ],
            ),
            const SizedBox(height: 40),
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
                  child: Form(
                    key: _formKey,
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
                            Icons.fingerprint,
                            size: 40,
                            color: AppColors.gold,
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Title
                        Text(
                          'أدخل بريدك الإلكتروني وسيُرسل لك كود تحقق لإعادة تعيين كلمة المرور الخاصة بك.',
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.textPrimary,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 40),
                        // Email input
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            hintText: 'البريد الإلكتروني',
                            hintTextDirection: TextDirection.rtl,
                            hintStyle: TextStyle(
                              color: AppColors.textHint,
                            ),
                            suffixIcon: const Icon(Icons.email_outlined),
                            filled: true,
                            fillColor: AppColors.greyBackground,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.gold,
                                width: 2,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Colors.red,
                                width: 1,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          textDirection: TextDirection.rtl,
                          keyboardType: TextInputType.emailAddress,
                          enabled: !_isLoading,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'الرجاء إدخال البريد الإلكتروني';
                            }
                            if (!value.contains('@')) {
                              return 'البريد الإلكتروني غير صحيح';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),
                        // Send code button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _sendCode,
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
                                    'إرسال الكود',
                                    textDirection: TextDirection.rtl,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressDot(bool isActive) {
    return Container(
      width: isActive ? 40 : 12,
      height: 12,
      decoration: BoxDecoration(
        color: isActive ? AppColors.black : AppColors.grey.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}
