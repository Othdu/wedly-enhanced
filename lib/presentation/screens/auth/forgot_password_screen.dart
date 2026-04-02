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

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _otpController = TextEditingController();
  final _otpFocusNode = FocusNode();

  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  int _currentStep = 0;
  bool _isResendDisabled = true;
  int _resendCountdown = 60;
  Timer? _timer;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _otpController.dispose();
    _otpFocusNode.dispose();
    _timer?.cancel();
    _shakeController.dispose();
    super.dispose();
  }

  String get _otpValue => _otpController.text;
  bool get _isOtpComplete => _otpValue.length == 6;

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
                  result['message'] ??
                      'تم إرسال رمز التحقق إلى بريدك الإلكتروني',
                  textDirection: TextDirection.rtl,
                ),
                backgroundColor: AppColors.gold,
              ),
            );
            setState(() => _currentStep = 1);
            _startCountdownTimer(60);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _otpFocusNode.requestFocus();
            });
          }
        } else {
          if (mounted) {
            _showErrorSnackBar(
                result['message'] ?? 'حدث خطأ أثناء إرسال الكود');
          }
        }
      } catch (e) {
        setState(() => _isLoading = false);
        if (mounted) {
          _showErrorSnackBar(
              'حدث خطأ أثناء إرسال الكود. الرجاء المحاولة مرة أخرى');
        }
      }
    }
  }

  void _verifyOtp() {
    if (!_isOtpComplete) {
      _shakeController.forward(from: 0);
      _showErrorSnackBar('الرجاء إدخال الكود كاملاً (6 أرقام)');
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _currentStep = 2);

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

  Future<void> _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final authRepository = getIt<AuthRepository>();

        final result = await authRepository.resetPassword(
          email: _emailController.text.trim(),
          otp: _otpValue,
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
        final errorMessage = e.toString();
        final waitTime = _parseWaitTimeFromMessage(errorMessage);

        if (errorMessage.contains('wait') ||
            errorMessage.contains('انتظار') ||
            errorMessage.contains('Please wait')) {
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
    final regex = RegExp(r'(\d+)\s*(?:seconds|ثانية|ثواني)');
    final match = regex.firstMatch(message);
    if (match != null) {
      return int.tryParse(match.group(1) ?? '60') ?? 60;
    }
    return 60;
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;
    final scale = (screenWidth / 375).clamp(0.8, 1.4);
    final vScale = (screenHeight / 812).clamp(0.7, 1.3);

    final iconSize = (72 * scale).clamp(56.0, 80.0);
    final titleFontSize = (24 * scale).clamp(20.0, 28.0);
    final bodyFontSize = (14 * scale).clamp(12.0, 16.0);
    final buttonHeight = (56 * vScale).clamp(46.0, 60.0);
    final buttonFontSize = (16 * scale).clamp(14.0, 18.0);
    final cardPaddingH = (24 * scale).clamp(16.0, 28.0);
    final cardPaddingV = (32 * vScale).clamp(20.0, 36.0);
    final outerPaddingH = (24 * scale).clamp(16.0, 28.0);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SafeArea(
            child: GestureDetector(
              onTap: () {
                if (_currentStep == 1) {
                  _otpFocusNode.requestFocus();
                } else {
                  FocusScope.of(context).unfocus();
                }
              },
              behavior: HitTestBehavior.opaque,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios,
                              color: AppColors.black, size: 20),
                          onPressed: () {
                            if (_currentStep > 0) {
                              setState(() => _currentStep--);
                            } else {
                              Navigator.of(context).pop();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding:
                          EdgeInsets.symmetric(horizontal: outerPaddingH),
                      child: Column(
                        children: [
                          SizedBox(height: isSmallScreen ? 4 : 8),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              horizontal: cardPaddingH,
                              vertical: cardPaddingV,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.black
                                      .withValues(alpha: 0.08),
                                  blurRadius: 20,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: _buildCurrentStep(
                                scale: scale,
                                vScale: vScale,
                                isSmallScreen: isSmallScreen,
                                iconSize: iconSize,
                                titleFontSize: titleFontSize,
                                bodyFontSize: bodyFontSize,
                                buttonHeight: buttonHeight,
                                buttonFontSize: buttonFontSize,
                              ),
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? 20 : 40),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep({
    required double scale,
    required double vScale,
    required bool isSmallScreen,
    required double iconSize,
    required double titleFontSize,
    required double bodyFontSize,
    required double buttonHeight,
    required double buttonFontSize,
  }) {
    switch (_currentStep) {
      case 0:
        return _buildEmailStep(
          key: const ValueKey(0),
          iconSize: iconSize,
          titleFontSize: titleFontSize,
          bodyFontSize: bodyFontSize,
          buttonHeight: buttonHeight,
          buttonFontSize: buttonFontSize,
          isSmallScreen: isSmallScreen,
        );
      case 1:
        return _buildOtpStep(
          key: const ValueKey(1),
          scale: scale,
          iconSize: iconSize,
          titleFontSize: titleFontSize,
          bodyFontSize: bodyFontSize,
          buttonHeight: buttonHeight,
          buttonFontSize: buttonFontSize,
          isSmallScreen: isSmallScreen,
        );
      case 2:
        return _buildResetPasswordStep(
          key: const ValueKey(2),
          iconSize: iconSize,
          titleFontSize: titleFontSize,
          bodyFontSize: bodyFontSize,
          buttonHeight: buttonHeight,
          buttonFontSize: buttonFontSize,
          isSmallScreen: isSmallScreen,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildEmailStep({
    Key? key,
    required double iconSize,
    required double titleFontSize,
    required double bodyFontSize,
    required double buttonHeight,
    required double buttonFontSize,
    required bool isSmallScreen,
  }) {
    return Form(
      key: _formKey,
      child: Column(
        key: key,
        children: [
          Container(
            width: iconSize,
            height: iconSize,
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(iconSize * 0.28),
            ),
            child: Icon(
              Icons.fingerprint,
              size: iconSize * 0.5,
              color: AppColors.gold,
            ),
          ),
          SizedBox(height: isSmallScreen ? 16 : 24),
          Text(
            'نسيت كلمة المرور',
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontSize: titleFontSize,
              fontWeight: FontWeight.bold,
              color: AppColors.gold,
            ),
          ),
          SizedBox(height: isSmallScreen ? 8 : 12),
          Text(
            'أدخل بريدك الإلكتروني وسيُرسل لك كود تحقق لإعادة تعيين كلمة المرور.',
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontSize: bodyFontSize,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          SizedBox(height: isSmallScreen ? 28 : 40),
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
              prefixIcon: const Icon(Icons.email_outlined),
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
                borderSide:
                    const BorderSide(color: AppColors.gold, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Colors.red, width: 1),
              ),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 16),
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
          SizedBox(height: isSmallScreen ? 24 : 32),
          SizedBox(
            width: double.infinity,
            height: buttonHeight,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _sendOtp,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.black,
                foregroundColor: AppColors.white,
                disabledBackgroundColor:
                    AppColors.black.withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.white),
                    )
                  : Text(
                      'إرسال الكود',
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                          fontSize: buttonFontSize,
                          fontWeight: FontWeight.w600),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpStep({
    Key? key,
    required double scale,
    required double iconSize,
    required double titleFontSize,
    required double bodyFontSize,
    required double buttonHeight,
    required double buttonFontSize,
    required bool isSmallScreen,
  }) {
    return Column(
      key: key,
      children: [
        Container(
          width: iconSize,
          height: iconSize,
          decoration: BoxDecoration(
            color: AppColors.gold.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(iconSize * 0.28),
          ),
          child: Icon(
            Icons.mark_email_read_outlined,
            size: iconSize * 0.5,
            color: AppColors.gold,
          ),
        ),
        SizedBox(height: isSmallScreen ? 16 : 24),
        Text(
          'أدخل كود التحقق',
          textAlign: TextAlign.center,
          textDirection: TextDirection.rtl,
          style: TextStyle(
            fontSize: titleFontSize,
            fontWeight: FontWeight.bold,
            color: AppColors.gold,
          ),
        ),
        SizedBox(height: isSmallScreen ? 8 : 12),
        Text(
          'أدخل الكود المكون من 6 أرقام المرسل إلى',
          textAlign: TextAlign.center,
          textDirection: TextDirection.rtl,
          style: TextStyle(
            fontSize: bodyFontSize,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            _emailController.text.trim(),
            textDirection: TextDirection.ltr,
            style: TextStyle(
              fontSize: (15 * scale).clamp(13.0, 17.0),
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        SizedBox(height: isSmallScreen ? 24 : 32),
        _buildOtpSection(scale),
        SizedBox(height: isSmallScreen ? 24 : 32),
        SizedBox(
          width: double.infinity,
          height: buttonHeight,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _verifyOtp,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.black,
              foregroundColor: AppColors.white,
              disabledBackgroundColor:
                  AppColors.black.withValues(alpha: 0.4),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.white),
                  )
                : Text(
                    'تحقق',
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                        fontSize: buttonFontSize,
                        fontWeight: FontWeight.w600),
                  ),
          ),
        ),
        SizedBox(height: isSmallScreen ? 16 : 24),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'لم تستلم الكود؟',
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: bodyFontSize,
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
                    fontSize: bodyFontSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResetPasswordStep({
    Key? key,
    required double iconSize,
    required double titleFontSize,
    required double bodyFontSize,
    required double buttonHeight,
    required double buttonFontSize,
    required bool isSmallScreen,
  }) {
    return Form(
      key: _formKey,
      child: Column(
        key: key,
        children: [
          Container(
            width: iconSize,
            height: iconSize,
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(iconSize * 0.28),
            ),
            child: Icon(
              Icons.lock_reset,
              size: iconSize * 0.5,
              color: AppColors.gold,
            ),
          ),
          SizedBox(height: isSmallScreen ? 16 : 24),
          Text(
            'كلمة مرور جديدة',
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontSize: titleFontSize,
              fontWeight: FontWeight.bold,
              color: AppColors.gold,
            ),
          ),
          SizedBox(height: isSmallScreen ? 8 : 12),
          Text(
            'أدخل كلمة المرور الجديدة الخاصة بك.',
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontSize: bodyFontSize,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          SizedBox(height: isSmallScreen ? 28 : 40),
          TextFormField(
            controller: _newPasswordController,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              hintText: 'كلمة المرور الجديدة',
              hintTextDirection: TextDirection.rtl,
              hintStyle: const TextStyle(color: AppColors.textHint),
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(_obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
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
                borderSide:
                    const BorderSide(color: AppColors.gold, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Colors.red, width: 1),
              ),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 16),
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
          const SizedBox(height: 16),
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
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(_obscureConfirmPassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined),
                onPressed: () => setState(
                    () => _obscureConfirmPassword = !_obscureConfirmPassword),
              ),
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
                borderSide:
                    const BorderSide(color: AppColors.gold, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Colors.red, width: 1),
              ),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 16),
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
          SizedBox(height: isSmallScreen ? 24 : 32),
          SizedBox(
            width: double.infinity,
            height: buttonHeight,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _resetPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.black,
                foregroundColor: AppColors.white,
                disabledBackgroundColor:
                    AppColors.black.withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.white),
                    )
                  : Text(
                      'تأكيد',
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                          fontSize: buttonFontSize,
                          fontWeight: FontWeight.w600),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpSection(double scale) {
    return AnimatedBuilder(
      animation: _shakeController,
      builder: (context, child) {
        final progress = _shakeController.value;
        final shakeOffset = progress < 1.0
            ? 12.0 *
                (1.0 - progress) *
                ((progress * 8).remainder(2) < 1 ? 1.0 : -1.0)
            : 0.0;
        return Transform.translate(
          offset: Offset(shakeOffset, 0),
          child: child,
        );
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Directionality(
            textDirection: TextDirection.ltr,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final availableWidth = constraints.maxWidth;
                final gap = (8 * scale).clamp(6.0, 12.0);
                final totalGaps = 5 * gap;
                final boxWidth =
                    ((availableWidth - totalGaps) / 6).clamp(36.0, 56.0);
                final boxHeight = (boxWidth * 1.2).clamp(44.0, 67.0);

                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(6, (index) {
                    return Padding(
                      padding:
                          EdgeInsets.only(left: index > 0 ? gap : 0),
                      child:
                          _buildDigitBox(index, boxWidth, boxHeight),
                    );
                  }),
                );
              },
            ),
          ),
          Positioned.fill(
            child: Opacity(
              opacity: 0,
              child: TextField(
                controller: _otpController,
                focusNode: _otpFocusNode,
                keyboardType: TextInputType.number,
                maxLength: 6,
                enableSuggestions: false,
                autocorrect: false,
                showCursor: false,
                decoration: const InputDecoration(
                  counterText: '',
                  border: InputBorder.none,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                onChanged: (value) {
                  setState(() {});
                  if (value.length == 6) {
                    _verifyOtp();
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDigitBox(int index, double boxWidth, double boxHeight) {
    final text = _otpValue;
    final hasDigit = index < text.length;
    final digit = hasDigit ? text[index] : '';
    final isActive = index == text.length && _otpFocusNode.hasFocus;
    final digitFontSize = (boxWidth * 0.45).clamp(16.0, 24.0);
    final cursorHeight = (boxHeight * 0.4).clamp(16.0, 26.0);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: boxWidth,
      height: boxHeight,
      decoration: BoxDecoration(
        color: hasDigit
            ? AppColors.gold.withValues(alpha: 0.08)
            : AppColors.greyBackground,
        borderRadius:
            BorderRadius.circular((boxWidth * 0.25).clamp(8.0, 14.0)),
        border: Border.all(
          color: hasDigit
              ? AppColors.gold
              : isActive
                  ? AppColors.gold.withValues(alpha: 0.5)
                  : Colors.transparent,
          width: 1.5,
        ),
      ),
      alignment: Alignment.center,
      child: hasDigit
          ? Text(
              digit,
              style: TextStyle(
                fontSize: digitFontSize,
                fontWeight: FontWeight.w700,
                color: AppColors.black,
              ),
            )
          : isActive
              ? Container(
                  width: 2,
                  height: cursorHeight,
                  decoration: BoxDecoration(
                    color: AppColors.gold,
                    borderRadius: BorderRadius.circular(1),
                  ),
                )
              : const SizedBox.shrink(),
    );
  }
}
