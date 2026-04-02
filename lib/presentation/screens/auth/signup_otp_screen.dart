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

class _SignupOtpScreenState extends State<SignupOtpScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _otpFocusNode = FocusNode();
  bool _isResendDisabled = true;
  int _resendCountdown = 60;
  Timer? _timer;
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _startCountdownTimer(60);
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _otpFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    _otpFocusNode.dispose();
    _timer?.cancel();
    _shakeController.dispose();
    super.dispose();
  }

  String get _otpValue => _otpController.text;
  bool get _isOtpComplete => _otpValue.length == 6;

  void _handleOtpSubmit() {
    if (!_isOtpComplete) {
      _shakeController.forward(from: 0);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'الرجاء إدخال الكود كاملاً (6 أرقام)',
            textDirection: TextDirection.rtl,
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    FocusScope.of(context).unfocus();
    context.read<AuthBloc>().add(
      AuthOtpVerificationRequested(
        email: widget.phoneOrEmail,
        otp: _otpValue,
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
      _resendCountdown = 60;
    });

    context.read<AuthBloc>().add(
      AuthResendOtpRequested(email: widget.phoneOrEmail),
    );
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;
    final scale = (screenWidth / 375).clamp(0.8, 1.4);
    final vScale = (screenHeight / 812).clamp(0.7, 1.3);

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthOtpVerificationSuccess) {
          Navigator.of(context).pushReplacementNamed(
            AppRouter.signupSuccess,
            arguments: {'userRole': widget.userRole},
          );
        } else if (state is AuthResendOtpSuccess) {
          _startCountdownTimer(60);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message, textDirection: TextDirection.rtl),
              backgroundColor: AppColors.gold,
            ),
          );
        } else if (state is AuthError) {
          final waitTime = _parseWaitTimeFromMessage(state.message);
          if (state.message.contains('wait') ||
              state.message.contains('انتظار') ||
              state.message.contains('Please wait')) {
            _startCountdownTimer(waitTime);
          }
          _shakeController.forward(from: 0);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text(state.message, textDirection: TextDirection.rtl),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          final iconSize = (72 * scale).clamp(56.0, 80.0);
          final titleFontSize = (24 * scale).clamp(20.0, 28.0);
          final bodyFontSize = (14 * scale).clamp(12.0, 16.0);
          final emailFontSize = (15 * scale).clamp(13.0, 17.0);
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
                    onTap: () => _otpFocusNode.requestFocus(),
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
                                onPressed: () =>
                                    Navigator.of(context).pop(),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            padding: EdgeInsets.symmetric(
                                horizontal: outerPaddingH),
                            child: Column(
                              children: [
                                SizedBox(
                                    height: isSmallScreen ? 4 : 8),
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: cardPaddingH,
                                    vertical: cardPaddingV,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius:
                                        BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.black
                                            .withValues(alpha: 0.08),
                                        blurRadius: 20,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        width: iconSize,
                                        height: iconSize,
                                        decoration: BoxDecoration(
                                          color: AppColors.gold
                                              .withValues(alpha: 0.12),
                                          borderRadius:
                                              BorderRadius.circular(
                                                  iconSize * 0.28),
                                        ),
                                        child: Icon(
                                          Icons
                                              .mark_email_read_outlined,
                                          size: iconSize * 0.5,
                                          color: AppColors.gold,
                                        ),
                                      ),
                                      SizedBox(
                                          height: isSmallScreen
                                              ? 16
                                              : 24),
                                      Text(
                                        'تأكيد الحساب',
                                        textAlign: TextAlign.center,
                                        textDirection:
                                            TextDirection.rtl,
                                        style: TextStyle(
                                          fontSize: titleFontSize,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.gold,
                                        ),
                                      ),
                                      SizedBox(
                                          height: isSmallScreen
                                              ? 8
                                              : 12),
                                      Text(
                                        'أدخل الكود المكون من 6 أرقام المرسل إلى',
                                        textAlign: TextAlign.center,
                                        textDirection:
                                            TextDirection.rtl,
                                        style: TextStyle(
                                          fontSize: bodyFontSize,
                                          color:
                                              AppColors.textSecondary,
                                          height: 1.5,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          widget.phoneOrEmail,
                                          textDirection:
                                              TextDirection.ltr,
                                          style: TextStyle(
                                            fontSize: emailFontSize,
                                            fontWeight: FontWeight.w600,
                                            color:
                                                AppColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                          height: isSmallScreen
                                              ? 24
                                              : 32),
                                      _buildOtpSection(scale),
                                      SizedBox(
                                          height: isSmallScreen
                                              ? 24
                                              : 32),
                                      SizedBox(
                                        width: double.infinity,
                                        height: buttonHeight,
                                        child: ElevatedButton(
                                          onPressed: isLoading
                                              ? null
                                              : _handleOtpSubmit,
                                          style:
                                              ElevatedButton.styleFrom(
                                            backgroundColor:
                                                AppColors.black,
                                            foregroundColor:
                                                AppColors.white,
                                            disabledBackgroundColor:
                                                AppColors.black
                                                    .withValues(
                                                        alpha: 0.4),
                                            shape:
                                                RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      16),
                                            ),
                                            elevation: 0,
                                          ),
                                          child: isLoading
                                              ? const SizedBox(
                                                  height: 20,
                                                  width: 20,
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    color:
                                                        AppColors.white,
                                                  ),
                                                )
                                              : Text(
                                                  'تأكيد',
                                                  textDirection:
                                                      TextDirection.rtl,
                                                  style: TextStyle(
                                                    fontSize:
                                                        buttonFontSize,
                                                    fontWeight:
                                                        FontWeight.w600,
                                                  ),
                                                ),
                                        ),
                                      ),
                                      SizedBox(
                                          height: isSmallScreen
                                              ? 16
                                              : 24),
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'لم تستلم الكود؟',
                                              textDirection:
                                                  TextDirection.rtl,
                                              style: TextStyle(
                                                color: AppColors
                                                    .textSecondary,
                                                fontSize: bodyFontSize,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            GestureDetector(
                                              onTap: _isResendDisabled
                                                  ? null
                                                  : _resendOtp,
                                              child: Text(
                                                _isResendDisabled
                                                    ? 'أعد الإرسال ($_resendCountdown)'
                                                    : 'أعد الإرسال',
                                                style: TextStyle(
                                                  color:
                                                      _isResendDisabled
                                                          ? AppColors
                                                              .textSecondary
                                                          : AppColors
                                                              .gold,
                                                  fontSize:
                                                      bodyFontSize,
                                                  fontWeight:
                                                      FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                    height: isSmallScreen ? 20 : 40),
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
        },
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
                    _handleOtpSubmit();
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
        borderRadius: BorderRadius.circular((boxWidth * 0.25).clamp(8.0, 14.0)),
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
