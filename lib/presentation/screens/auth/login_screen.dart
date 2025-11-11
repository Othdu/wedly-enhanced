import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wedly/core/constants/app_colors.dart';
import 'package:wedly/core/utils/enums.dart';
import 'package:wedly/logic/blocs/auth/auth_bloc.dart';
import 'package:wedly/logic/blocs/auth/auth_event.dart';
import 'package:wedly/logic/blocs/auth/auth_state.dart';
import 'package:wedly/routes/app_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  UserRole? _selectedRole;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin(BuildContext context) {
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

      context.read<AuthBloc>().add(
            AuthLoginRequested(
              email: _usernameController.text.trim(),
              password: _passwordController.text,
              role: _selectedRole!,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            final user = state.user;
            if (user.role == UserRole.user) {
              AppRouter.goToUserHome(context);
            } else {
              AppRouter.goToProviderHome(context);
            }
          } else if (state is AuthError) {
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
                                'تسجيل الدخول',
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
                                'سجّل دخولك وأكمل خطتك لحفلتك بخطوات بسيطة وسريعة.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
                                textDirection: TextDirection.rtl,
                              ),
                              const SizedBox(height: 32),
                              // Username Field
                              TextFormField(
                                controller: _usernameController,
                                decoration: InputDecoration(
                                  hintText: 'اسم المستخدم او البريد الالكتروني',
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
                                    return 'الرجاء إدخال اسم المستخدم أو البريد الإلكتروني';
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
                              const SizedBox(height: 12),
                              // Forgot Password
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pushNamed(AppRouter.forgotPassword);
                                  },
                                  child: Text(
                                    'هل نسيت كلمة المرور ؟',
                                    textDirection: TextDirection.rtl,
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
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
                              const SizedBox(height: 24),
                              // Login Button
                              SizedBox(
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: isLoading ? null : () => _handleLogin(context),
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
                                          'الدخول',
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
                                    onPressed: () {
                                      // TODO: Implement Facebook login
                                    },
                                  ),
                                  const SizedBox(width: 16),
                                  // Apple Button - Only show on iOS
                                  if (Platform.isIOS) ...[
                                    _SocialLoginButton(
                                      imagePath: 'assets/images/apple.png',
                                      onPressed: () {
                                        // TODO: Implement Apple login
                                      },
                                    ),
                                    const SizedBox(width: 16),
                                  ],
                                  // Google Button
                                  _SocialLoginButton(
                                    imagePath: 'assets/images/google.png',
                                    onPressed: () {
                                      // TODO: Implement Google login
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              // Sign Up Link
                              Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    Text(
      'ليس لديك حساب ؟',
      textDirection: TextDirection.rtl,
      style: TextStyle(
        color: AppColors.textSecondary,
        fontSize: 14,
      ),
    ),
    const SizedBox(width: 4),
    GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(AppRouter.signup);
      },
      child: Text(
        'أنشئ حساب جديد',
        style: const TextStyle(
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
  final VoidCallback onPressed;

  const _SocialLoginButton({
    required this.imagePath,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
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
    );
  }
}
