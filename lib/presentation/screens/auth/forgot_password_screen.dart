import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  // Controllers
  final _emailController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  final _formKey = GlobalKey<FormState>();

  // State
  bool _isLoading = false;
  int _currentStep = 0; // 0: Email, 1: OTP, 2: New Password
  bool _isResendDisabled = true; // Start disabled like signup OTP
  int _resendCountdown = 60;
  Timer? _timer;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  // Step 1: Send OTP to email
  Future<void> _sendOtp() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final authRepository = getIt<AuthRepository>();
        final result = await authRepository.forgotPassword(
          email: _emailController.text.trim(),
        );

        setState(() => _isLoading = false);

        if (result['success'] == true) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  result['message'] ?? 'تم إرسال رمز التحقق إلى بريدك الإلكتروني',
                  textDirection: TextDirection.rtl,
                ),
                backgroundColor: AppColors.gold,
              ),
            );

            // Move to OTP step
            setState(() {
              _currentStep = 1;
            });
            _startCountdownTimer(60);
          }
        } else {
          if (mounted) {
            _showErrorSnackBar(result['message'] ?? 'حدث خطأ أثناء إرسال الكود');
          }
        }
      } catch (e) {
        setState(() => _isLoading = false);
        if (mounted) {
          _showErrorSnackBar('حدث خطأ أثناء إرسال الكود. الرجاء المحاولة مرة أخرى');
        }
      }
    }
  }

  // Step 2: Verify OTP (just validate and move to next step, no API call)
  void _verifyOtp() {
    final otp = _otpControllers.map((c) => c.text).join();

    if (otp.length != 6) {
      _showErrorSnackBar('الرجاء إدخال الكود كاملاً (6 أرقام)');
      return;
    }

    // Just move to password reset step - OTP will be verified with the password
    setState(() {
      _currentStep = 2;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'الآن أدخل كلمة المرور الجديدة',
            textDirection: TextDirection.rtl,
          ),
          backgroundColor: AppColors.gold,
        ),
      );
    }
  }

  // Step 3: Reset Password with OTP
  Future<void> _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final authRepository = getIt<AuthRepository>();
        final otp = _otpControllers.map((c) => c.text).join();

        final result = await authRepository.resetPassword(
          email: _emailController.text.trim(),
          otp: otp,
          password: _newPasswordController.text,
        );

        setState(() => _isLoading = false);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                result['message'] ?? 'تم تغيير كلمة المرور بنجاح',
                textDirection: TextDirection.rtl,
              ),
              backgroundColor: AppColors.gold,
            ),
          );

          // Navigate to login
          Navigator.of(context).pushReplacementNamed(AppRouter.login);
        }
      } catch (e) {
        setState(() => _isLoading = false);
        if (mounted) {
          final errorMessage = e.toString();
          _showErrorSnackBar(errorMessage.contains('Exception: ')
              ? errorMessage.replaceFirst('Exception: ', '')
              : 'حدث خطأ أثناء تغيير كلمة المرور. الرجاء المحاولة مرة أخرى');
        }
      }
    }
  }

  Future<void> _resendOtp() async {
    if (_isResendDisabled) return;

    try {
      final authRepository = getIt<AuthRepository>();
      final result = await authRepository.resendOtp(
        email: _emailController.text.trim(),
      );

      // Success - start 60 second countdown
      _startCountdownTimer(60);

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
        // Check if it's a rate limit error and parse wait time from message
        final errorMessage = e.toString();
        final waitTime = _parseWaitTimeFromMessage(errorMessage);

        if (errorMessage.contains('wait') ||
            errorMessage.contains('انتظار') ||
            errorMessage.contains('Please wait')) {
          // Rate limit error - start countdown with the time from backend
          _startCountdownTimer(waitTime);
        }

        _showErrorSnackBar(errorMessage.contains('Exception: ')
            ? errorMessage.replaceFirst('Exception: ', '')
            : 'حدث خطأ أثناء إعادة إرسال الكود');
      }
    }
  }

  void _startCountdownTimer(int seconds) {
    setState(() {
      _isResendDisabled = true;
      _resendCountdown = seconds;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendCountdown > 0) {
          _resendCountdown--;
        } else {
          _isResendDisabled = false;
          timer.cancel();
        }
      });
    });
  }

  int _parseWaitTimeFromMessage(String message) {
    // Parse messages like "Please wait 31 seconds before requesting a new OTP"
    // or "الرجاء الانتظار 31 ثانية قبل طلب رمز جديد"
    final regex = RegExp(r'(\d+)\s*(?:seconds|ثانية|ثواني)');
    final match = regex.firstMatch(message);
    if (match != null) {
      return int.tryParse(match.group(1) ?? '60') ?? 60;
    }
    return 60; // Default to 60 seconds
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textDirection: TextDirection.rtl),
        backgroundColor: Colors.red,
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
          _currentStep == 0
              ? 'نسيت كلمة المرور'
              : _currentStep == 1
                  ? 'أدخل كود التحقق'
                  : 'كلمة مرور جديدة',
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
            // White card with content
            Expanded(
              child: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                behavior: HitTestBehavior.opaque,
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
                    child: _buildCurrentStepContent(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildEmailStep();
      case 1:
        return _buildOtpStep();
      case 2:
        return _buildResetPasswordStep();
      default:
        return _buildEmailStep();
    }
  }

  // STEP 1: Email Input
  Widget _buildEmailStep() {
    return Form(
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
          const Text(
            'أدخل بريدك الإلكتروني وسيُرسل لك كود تحقق لإعادة تعيين كلمة المرور الخاصة بك.',
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textPrimary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 40),
          // Email input
          TextFormField(
            controller: _emailController,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) {
              FocusScope.of(context).unfocus();
              if (!_isLoading) _sendOtp();
            },
            decoration: InputDecoration(
              hintText: 'البريد الإلكتروني',
              hintTextDirection: TextDirection.rtl,
              hintStyle: const TextStyle(color: AppColors.textHint),
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
                borderSide: const BorderSide(color: AppColors.gold, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 1),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
              onPressed: _isLoading ? null : _sendOtp,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
                    )
                  : const Text(
                      'إرسال الكود',
                      textDirection: TextDirection.rtl,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // STEP 2: OTP Input
  Widget _buildOtpStep() {
    return Column(
      children: [
        // Icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.greyBackground,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.mail_outline, size: 40, color: AppColors.gold),
        ),
        const SizedBox(height: 32),
        // Title
        const Text(
          'من فضلك أدخل الكود لتأكيد هويتك ومتابعة إعادة تعيين كلمة المرور الخاصة بك.',
          textAlign: TextAlign.center,
          textDirection: TextDirection.rtl,
          style: TextStyle(fontSize: 16, color: AppColors.textPrimary, height: 1.6),
        ),
        const SizedBox(height: 8),
        // Subtitle
        const Text(
          'أدخل الكود المكون من 6 أرقام',
          textAlign: TextAlign.center,
          textDirection: TextDirection.rtl,
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 40),
        // OTP Input boxes
        Directionality(
          textDirection: TextDirection.ltr,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double availableWidth = constraints.maxWidth;
              final double totalSpacing = 5 * 8;
              final double boxWidth = ((availableWidth - totalSpacing) / 6).clamp(40.0, 60.0);

              return Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                children: List.generate(6, (index) => _buildOtpBox(index, boxWidth)),
              );
            },
          ),
        ),
        const SizedBox(height: 32),
        // Verify button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _verifyOtp,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
                  )
                : const Text(
                    'تحقق',
                    textDirection: TextDirection.rtl,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
          ),
        ),
        const SizedBox(height: 24),
        // Resend code
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'لم تستلم الكود؟',
              textDirection: TextDirection.rtl,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: _isResendDisabled ? null : _resendOtp,
              child: Text(
                _isResendDisabled ? 'أعد الإرسال ($_resendCountdown)' : 'أعد الإرسال',
                style: TextStyle(
                  color: _isResendDisabled ? AppColors.textSecondary : AppColors.gold,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // STEP 3: Reset Password
  Widget _buildResetPasswordStep() {
    return Form(
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
            child: const Icon(Icons.lock_reset, size: 40, color: AppColors.gold),
          ),
          const SizedBox(height: 32),
          // Title
          const Text(
            'أدخل كلمة المرور الجديدة الخاصة بك.',
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            style: TextStyle(fontSize: 16, color: AppColors.textPrimary, height: 1.6),
          ),
          const SizedBox(height: 40),
          // New Password
          TextFormField(
            controller: _newPasswordController,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              hintText: 'كلمة المرور الجديدة',
              hintTextDirection: TextDirection.rtl,
              hintStyle: const TextStyle(color: AppColors.textHint),
              suffixIcon: IconButton(
                icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
              filled: true,
              fillColor: AppColors.greyBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.gold, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 1),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            textDirection: TextDirection.rtl,
            enabled: !_isLoading,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'الرجاء إدخال كلمة المرور';
              }
              if (value.length < 8) {
                return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          // Confirm Password
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) {
              FocusScope.of(context).unfocus();
              if (!_isLoading) _resetPassword();
            },
            decoration: InputDecoration(
              hintText: 'تأكيد كلمة المرور',
              hintTextDirection: TextDirection.rtl,
              hintStyle: const TextStyle(color: AppColors.textHint),
              suffixIcon: IconButton(
                icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
              ),
              filled: true,
              fillColor: AppColors.greyBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.gold, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 1),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            textDirection: TextDirection.rtl,
            enabled: !_isLoading,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'الرجاء تأكيد كلمة المرور';
              }
              if (value != _newPasswordController.text) {
                return 'كلمة المرور غير متطابقة';
              }
              return null;
            },
          ),
          const SizedBox(height: 32),
          // Reset button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _resetPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
                    )
                  : const Text(
                      'تأكيد',
                      textDirection: TextDirection.rtl,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpBox(int index, double boxWidth) {
    final bool hasValue = _otpControllers[index].text.isNotEmpty;
    final double boxHeight = boxWidth * 1.3;

    return Container(
      width: boxWidth,
      height: boxHeight,
      child: KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: (KeyEvent event) {
          if (event is KeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.backspace) {
              if (_otpControllers[index].text.isEmpty && index > 0) {
                // Move to previous box (left in LTR) when backspace on empty field
                _focusNodes[index - 1].requestFocus();
              }
            }
          }
        },
        child: TextField(
          controller: _otpControllers[index],
          focusNode: _focusNodes[index],
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          obscureText: false,
          enableSuggestions: false,
          autocorrect: false,
          style: TextStyle(
            fontSize: boxWidth * 0.5,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
            letterSpacing: 0,
          ),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          decoration: InputDecoration(
            counterText: '',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: AppColors.greyBackground,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: hasValue ? AppColors.gold : Colors.transparent,
                width: 2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.gold,
                width: 2,
              ),
            ),
            contentPadding: EdgeInsets.zero,
            isDense: true,
          ),
          onChanged: (value) {
            setState(() {}); // Rebuild to show border color change
            if (value.isNotEmpty) {
              // Move to next box (right in LTR) when digit is entered
              if (index < 5) {
                _focusNodes[index + 1].requestFocus();
              }
            }
          },
          onTap: () {
            // Place cursor at the end when tapping
            _otpControllers[index].selection = TextSelection.fromPosition(
              TextPosition(offset: _otpControllers[index].text.length),
            );
          },
        ),
      ),
    );
  }
}
