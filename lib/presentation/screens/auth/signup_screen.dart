import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wedly/core/constants/app_colors.dart';
import 'package:wedly/core/utils/enums.dart';
import 'package:wedly/logic/blocs/auth/auth_bloc.dart';
import 'package:wedly/logic/blocs/auth/auth_state.dart';
import 'package:wedly/presentation/screens/auth/login_screen.dart';
import 'package:wedly/presentation/screens/auth/signup_otp_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  UserRole? _selectedRole;
  Gender? _selectedGender;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSignUp(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      if (_selectedRole == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'الرجاء اختيار نوع الحساب',
              textDirection: TextDirection.rtl,
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      if (_selectedGender == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'الرجاء اختيار الجنس',
              textDirection: TextDirection.rtl,
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Navigate to OTP verification
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => SignupOtpScreen(
            phoneOrEmail: _phoneController.text.isNotEmpty
                ? _phoneController.text
                : _emailController.text,
            userRole: _selectedRole!,
          ),
        ),
      );
    }
  }

  Widget _buildRoleButton({
    required String label,
    required UserRole role,
    required bool isSelected,
    required bool isEnabled,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: isEnabled
            ? () {
                setState(() {
                  _selectedRole = role;
                });
              }
            : null,
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.gold : AppColors.greyBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.gold : Colors.transparent,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              label,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppColors.white : AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGenderButton({
    required String label,
    required Gender gender,
    required bool isSelected,
    required bool isEnabled,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: isEnabled
            ? () {
                setState(() {
                  _selectedGender = gender;
                });
              }
            : null,
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.gold : AppColors.greyBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.gold : Colors.transparent,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              label,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppColors.white : AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
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
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return Stack(
            children: [
              // Decorative circle at top left
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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 40),
                      // Logo
                      Center(
                        child: RichText(
                          text: const TextSpan(
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                            children: [
                              TextSpan(
                                text: 'We',
                                style: TextStyle(color: AppColors.black),
                              ),
                              TextSpan(
                                text: 'dly',
                                style: TextStyle(color: AppColors.gold),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 60),
                      // White card container
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.black.withValues(alpha: 0.08),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Title
                              Text(
                                'تسجيل حساب جديد',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.gold,
                                ),
                                textAlign: TextAlign.center,
                                textDirection: TextDirection.rtl,
                              ),
                              const SizedBox(height: 12),
                              // Subtitle
                              Text(
                                'أنشئ حسابك واكتشف أجمل قاعات الأفراح. قارن الأسعار واحجز بكل سهولة في دقائق.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
                                textDirection: TextDirection.rtl,
                              ),
                              const SizedBox(height: 32),
                              // Full Name Field
                              TextFormField(
                                controller: _nameController,
                                decoration: InputDecoration(
                                  hintText: 'الأسم بالكامل',
                                  hintTextDirection: TextDirection.rtl,
                                  hintStyle: TextStyle(
                                    color: AppColors.textHint,
                                  ),
                                  suffixIcon: const Icon(Icons.person_outline),
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
                                enabled: !isLoading,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'الرجاء إدخال الاسم بالكامل';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              // Email Field
                              TextFormField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                  hintText: 'البريد الالكتروني',
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
                                enabled: !isLoading,
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
                              const SizedBox(height: 16),
                              // Phone Field
                              TextFormField(
  controller: _phoneController, // غيّر الاسم هنا (اختياري)
  decoration: InputDecoration(
    hintText: 'اسم المستخدم',
    hintTextDirection: TextDirection.rtl,
    hintStyle: TextStyle(
      color: AppColors.textHint,
    ),
    suffixIcon: const Icon(Icons.person_outline), // 👈 بدل أيقونة الهاتف
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
  keyboardType: TextInputType.text, // 👈 هذا أهم تغيير
  enabled: !isLoading,
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'الرجاء إدخال اسم المستخدم';
    }
    return null;
  },
),

                              const SizedBox(height: 16),
                              // Password Field
                              TextFormField(
                                controller: _passwordController,
                                decoration: InputDecoration(
                                  hintText: 'كلمة المرور',
                                  hintTextDirection: TextDirection.rtl,
                                  hintStyle: TextStyle(
                                    color: AppColors.textHint,
                                  ),
                                  suffixIcon: const Icon(Icons.lock_outline),
                                  prefixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
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
                                obscureText: _obscurePassword,
                                textDirection: TextDirection.rtl,
                                enabled: !isLoading,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'الرجاء إدخال كلمة المرور';
                                  }
                                  if (value.length < 6) {
                                    return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              // Confirm Password Field
                              TextFormField(
                                controller: _confirmPasswordController,
                                decoration: InputDecoration(
                                  hintText: 'تأكيد كلمة المرور',
                                  hintTextDirection: TextDirection.rtl,
                                  hintStyle: TextStyle(
                                    color: AppColors.textHint,
                                  ),
                                  suffixIcon: const Icon(Icons.lock_outline),
                                  prefixIcon: IconButton(
                                    icon: Icon(
                                      _obscureConfirmPassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscureConfirmPassword = !_obscureConfirmPassword;
                                      });
                                    },
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
                                obscureText: _obscureConfirmPassword,
                                textDirection: TextDirection.rtl,
                                enabled: !isLoading,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'الرجاء تأكيد كلمة المرور';
                                  }
                                  if (value != _passwordController.text) {
                                    return 'كلمات المرور غير متطابقة';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),
                              // Role Selection
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildRoleButton(
                                    label: 'عميل',
                                    role: UserRole.user,
                                    isSelected: _selectedRole == UserRole.user,
                                    isEnabled: !isLoading,
                                  ),
                                  const SizedBox(width: 12),
                                  _buildRoleButton(
                                    label: 'مزود خدمة',
                                    role: UserRole.provider,
                                    isSelected: _selectedRole == UserRole.provider,
                                    isEnabled: !isLoading,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Gender Selection
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildGenderButton(
                                    label: 'ذكر',
                                    gender: Gender.male,
                                    isSelected: _selectedGender == Gender.male,
                                    isEnabled: !isLoading,
                                  ),
                                  const SizedBox(width: 12),
                                  _buildGenderButton(
                                    label: 'أنثى',
                                    gender: Gender.female,
                                    isSelected: _selectedGender == Gender.female,
                                    isEnabled: !isLoading,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),
                              // Sign Up Button
                              SizedBox(
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: isLoading ? null : () => _handleSignUp(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.black,
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
                                          'متابعة',
                                          textDirection: TextDirection.rtl,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              // Social Login
                              Text(
                                'سجّل الدخول بأستخدام',
                                textAlign: TextAlign.center,
                                textDirection: TextDirection.rtl,
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Social Login Buttons
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Facebook Button
                                  _SocialLoginButton(
                                    icon: Icons.facebook,
                                    color: const Color(0xFF1877F2),
                                    onPressed: () {
                                      // TODO: Implement Facebook signup
                                    },
                                  ),
                                  const SizedBox(width: 16),
                                  // Apple Button - Only show on iOS
                                  if (Platform.isIOS) ...[
                                    _SocialLoginButton(
                                      icon: Icons.apple,
                                      color: AppColors.black,
                                      onPressed: () {
                                        // TODO: Implement Apple signup
                                      },
                                    ),
                                    const SizedBox(width: 16),
                                  ],
                                  // Google Button
                                  _SocialLoginButton(
                                    icon: Icons.g_mobiledata,
                                    color: const Color(0xFFDB4437),
                                    onPressed: () {
                                      // TODO: Implement Google signup
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              // Login Link
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(
                                          builder: (_) => const LoginScreen(),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      'لديك حساب ؟',
                                    textDirection: TextDirection.rtl,
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                   'تسجيل الدخول',
                                      style: const TextStyle(
                                        color: AppColors.gold,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SocialLoginButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _SocialLoginButton({
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.greyLight,
          width: 1,
        ),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: color,
          size: 28,
        ),
      ),
    );
  }
}
