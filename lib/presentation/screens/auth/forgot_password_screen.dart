import 'package:flutter/material.dart';
import 'package:wedly/core/constants/app_colors.dart';
import 'package:wedly/routes/app_router.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _sendCode() {
    if (_formKey.currentState!.validate()) {
      // Navigate to OTP screen
      Navigator.of(context).pushNamed(
        AppRouter.otpVerification,
        arguments: {
          'phoneOrEmail': _phoneController.text,
          'isForPasswordReset': true,
        },
      );
    }
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
                          'أدخل رقم هاتفك وسيُرسل لك كود تحقق لإعادة تعيين كلمة المرور الخاصة بك.',
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.textPrimary,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 40),
                        // Phone input
                        TextFormField(
                          controller: _phoneController,
                          decoration: InputDecoration(
                            hintText: 'رقم الهاتف',
                            hintTextDirection: TextDirection.rtl,
                            hintStyle: TextStyle(
                              color: AppColors.textHint,
                            ),
                            suffixIcon: const Icon(Icons.phone_outlined),
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
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'الرجاء إدخال رقم الهاتف';
                            }
                            if (value.length < 10) {
                              return 'رقم الهاتف غير صحيح';
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
                            onPressed: _sendCode,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.gold,
                              foregroundColor: AppColors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
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
