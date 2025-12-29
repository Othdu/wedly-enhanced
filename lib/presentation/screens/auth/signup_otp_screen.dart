import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wedly/core/constants/app_colors.dart';
import 'package:wedly/core/utils/enums.dart';
import 'package:wedly/logic/blocs/auth/auth_bloc.dart';
import 'package:wedly/logic/blocs/auth/auth_event.dart';
import 'package:wedly/logic/blocs/auth/auth_state.dart';
import 'package:wedly/routes/app_router.dart';

class SignupOtpScreen extends StatefulWidget {
  final String phoneOrEmail;
  final UserRole userRole;
  final String? name;
  final String? password;
  final String? phone;

  const SignupOtpScreen({
    super.key,
    required this.phoneOrEmail,
    required this.userRole,
    this.name,
    this.password,
    this.phone,
  });

  @override
  State<SignupOtpScreen> createState() => _SignupOtpScreenState();
}

class _SignupOtpScreenState extends State<SignupOtpScreen> {
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isResendDisabled = true; // Start disabled
  int _resendCountdown = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Start countdown immediately when OTP screen loads
    // User just received the first OTP from registration
    _startCountdownTimer(60);
  }

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

  void _handleOtpSubmit() {
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

    // Trigger OTP verification via BLoC with all registration data
    debugPrint('🔍 OTP Screen - Submitting with data:');
    debugPrint('   Email: ${widget.phoneOrEmail}');
    debugPrint('   OTP: $otp');
    debugPrint('   Name: ${widget.name}');
    debugPrint('   Phone: ${widget.phone}');
    debugPrint('   Role: ${widget.userRole}');
    debugPrint('   Password: ${widget.password != null ? "[PROVIDED]" : "[NULL]"}');

    context.read<AuthBloc>().add(
      AuthOtpVerificationRequested(
        email: widget.phoneOrEmail,
        otp: otp,
        name: widget.name,
        password: widget.password,
        phone: widget.phone,
        role: widget.userRole,
      ),
    );
  }

  void _resendOtp() {
    if (_isResendDisabled) return;

    setState(() {
      _isResendDisabled = true;
      _resendCountdown = 60; // Default, will be updated by backend response
    });

    // Trigger resend OTP via BLoC
    context.read<AuthBloc>().add(
      AuthResendOtpRequested(email: widget.phoneOrEmail),
    );
  }

  void _startCountdownTimer(int seconds) {
    setState(() {
      _isResendDisabled = true;
      _resendCountdown = seconds;
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

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthOtpVerificationSuccess) {
          // Navigate to success screen which will handle the next step
          // For providers: success screen -> documents screen
          // For users: success screen -> user home
          Navigator.of(context).pushReplacementNamed(
            AppRouter.signupSuccess,
            arguments: {
              'userRole': widget.userRole,
            },
          );
        } else if (state is AuthResendOtpSuccess) {
          // Success - start 60 second countdown
          _startCountdownTimer(60);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message,
                textDirection: TextDirection.rtl,
              ),
              backgroundColor: AppColors.gold,
            ),
          );
        } else if (state is AuthError) {
          // Check if it's a rate limit error
          final waitTime = _parseWaitTimeFromMessage(state.message);
          if (state.message.contains('wait') || state.message.contains('انتظار') || state.message.contains('Please wait')) {
            // Rate limit error - start countdown with the time from backend
            _startCountdownTimer(waitTime);
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message,
                textDirection: TextDirection.rtl,
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return Scaffold(
            backgroundColor: AppColors.greyBackground,
            appBar: AppBar(
        backgroundColor: AppColors.greyBackground,
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.white,
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
                textDirection: TextDirection.ltr,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final double availableWidth = constraints.maxWidth;
                    // Calculate spacing: 6 boxes with gaps between them (5 gaps) + side padding
                    final double totalSpacing = (5 * 8) + (2 * 4); // 5 gaps of 8px + 4px padding on each side
                    final double boxWidth = ((availableWidth - totalSpacing) / 6).clamp(40.0, 60.0);

                    return Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      children: List.generate(6, (index) {
                        return _buildOtpBox(index, boxWidth); // LTR order for OTP codes
                      }),
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),
              // Submit button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _handleOtpSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: isLoading
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
            );
          },
        ),
      );
  }

  Widget _buildOtpBox(int index, double boxWidth) {
    final bool hasFocus = _focusNodes[index].hasFocus;
    final bool hasValue = _otpControllers[index].text.isNotEmpty;
    final double boxHeight = boxWidth * 1.3; // Maintain aspect ratio - slightly taller

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
            fontSize: boxWidth * 0.5, // Responsive font size
            fontWeight: FontWeight.w600,
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
