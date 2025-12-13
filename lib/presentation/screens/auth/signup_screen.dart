import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wedly/core/constants/app_colors.dart';
import 'package:wedly/core/utils/enums.dart';
import 'package:wedly/core/di/injection_container.dart';
import 'package:wedly/data/repositories/auth_repository.dart';
import 'package:wedly/logic/blocs/auth/auth_bloc.dart';
import 'package:wedly/logic/blocs/auth/auth_event.dart';
import 'package:wedly/logic/blocs/auth/auth_state.dart';
import 'package:wedly/routes/app_router.dart';
import 'package:wedly/presentation/screens/auth/login_screen.dart';


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
  bool _isLoading = false;
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

  void _handleSocialSignUp(BuildContext context, String provider) {
    print('🔍 SIGNUP UI: User clicked $provider signup');
    context.read<AuthBloc>().add(
          AuthSocialLoginRequested(provider: provider),
        );
  }

  Future<void> _handleSignUp(BuildContext context) async {
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

      // Set loading state
      setState(() {
        _isLoading = true;
      });

      try {
        // Call register API
        final authRepository = getIt<AuthRepository>();
        final result = await authRepository.register(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          phone: _phoneController.text.trim(),
          role: _selectedRole!,
        );

        setState(() {
          _isLoading = false;
        });

        if (result['success'] == true) {
          // Show success message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  result['message'] ?? 'تم إرسال كود التحقق إلى بريدك الإلكتروني',
                  textDirection: TextDirection.rtl,
                ),
                backgroundColor: AppColors.gold,
              ),
            );

            // Navigate to OTP verification screen with email
            Navigator.of(context).pushNamed(
              AppRouter.signupOtp,
              arguments: {
                'phoneOrEmail': _emailController.text.trim(),
                'userRole': _selectedRole!,
              },
            );
          }
        } else {
          // Show error message
          if (mounted) {
            _showErrorDialog(result['message'] ?? 'حدث خطأ أثناء التسجيل');
          }
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });

        if (mounted) {
          String errorMessage = 'حدث خطأ أثناء التسجيل. الرجاء المحاولة مرة أخرى';

          // Extract error message from ApiException or other exceptions
          final errorString = e.toString();

          if (errorString.contains('No internet')) {
            errorMessage = 'لا يوجد اتصال بالإنترنت. يرجى التحقق من الشبكة';
          } else if (errorString.contains('timeout') || errorString.contains('Request timeout')) {
            errorMessage = 'انتهت مهلة الطلب. يرجى المحاولة مرة أخرى';
          } else if (errorString.contains('Server error')) {
            errorMessage = 'خطأ في الخادم. يرجى المحاولة لاحقاً';
          } else if (errorString.contains('ApiException:')) {
            // Extract message after "ApiException: "
            final parts = errorString.split('ApiException: ');
            if (parts.length > 1) {
              errorMessage = parts[1].split(' (Status:')[0];
            }
          }

          debugPrint('Registration error: $e');
          _showErrorDialog(errorMessage);
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
          final isLoading = _isLoading;

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
                                  prefixIcon: const Icon(Icons.person_outline),
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
  controller: _phoneController,
  decoration: InputDecoration(
    hintText: 'رقم الهاتف',
    hintTextDirection: TextDirection.rtl,
    hintStyle: TextStyle(
      color: AppColors.textHint,
    ),
    prefixIcon: const Icon(Icons.phone_outlined),
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
  enabled: !isLoading,
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'الرجاء إدخال رقم الهاتف';
    }
    if (value.length < 10) {
      return 'رقم الهاتف يجب أن يكون 10 أرقام على الأقل';
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
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
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
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  
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
                                          isLoading ? 'تحميل...' : 'متابعة',
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
                                    imagePath: 'assets/images/facebook.png',
                                    onPressed: _isLoading
                                        ? null
                                        : () => _handleSocialSignUp(context, 'facebook'),
                                  ),
                                  const SizedBox(width: 16),
                                  // Apple Button - Only show on iOS
                                  if (Platform.isIOS) ...[
                                    _SocialLoginButton(
                                      imagePath: 'assets/images/apple.png',
                                      onPressed: () {
                                        // TODO: Implement Apple signup (requires apple_sign_in package)
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'تسجيل الدخول بواسطة Apple قريباً',
                                              textDirection: TextDirection.rtl,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(width: 16),
                                  ],
                                  // Google Button
                                  _SocialLoginButton(
                                    imagePath: 'assets/images/google.png',
                                    onPressed: _isLoading
                                        ? null
                                        : () => _handleSocialSignUp(context, 'google'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              // Login Link
Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    Text(
      'لديك حساب ؟',
      textDirection: TextDirection.rtl,
      style: TextStyle(
        color: AppColors.textSecondary,
        fontSize: 14,
      ),
    ),
    const SizedBox(width: 4),
    GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      },
      child: Text(
        'تسجيل الدخول',
        style: TextStyle(
          color: AppColors.gold,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  ],
)

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
  final String imagePath;
  final VoidCallback? onPressed;

  const _SocialLoginButton({
    required this.imagePath,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Opacity(
        opacity: onPressed == null ? 0.5 : 1.0,
        child: Container(
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
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
