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
  final _cityController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  UserRole? _selectedRole;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSocialSignUp(BuildContext context, String provider) {
    context.read<AuthBloc>().add(AuthSocialLoginRequested(provider: provider));
  }

  Future<void> _handleSignUp(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء اختيار نوع الحساب',
              textDirection: TextDirection.rtl),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Providers — go directly to documents screen, no pre-registration
    if (_selectedRole == UserRole.provider) {
      if (mounted) {
        Navigator.of(context).pushNamed(
          AppRouter.providerDocuments,
          arguments: {
            'name': _nameController.text.trim(),
            'email': _emailController.text.trim(),
            'password': _passwordController.text,
            'phone': _phoneController.text.trim(),
            'city': _cityController.text.trim(),
          },
        );
      }
      return;
    }

    // Regular users — OTP flow
    setState(() => _isLoading = true);

    try {
      final authRepository = getIt<AuthRepository>();
      final result = await authRepository.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        phone: _phoneController.text.trim(),
        city: _cityController.text.trim(),
        role: _selectedRole!,
      );

      setState(() => _isLoading = false);

      if (result['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                result['message'] ??
                    'تم إرسال كود التحقق إلى بريدك الإلكتروني',
                textDirection: TextDirection.rtl,
              ),
              backgroundColor: AppColors.gold,
            ),
          );
          Navigator.of(context).pushNamed(
            AppRouter.signupOtp,
            arguments: {
              'phoneOrEmail': _emailController.text.trim(),
              'userRole': _selectedRole!,
              'name': _nameController.text.trim(),
              'password': _passwordController.text,
              'phone': _phoneController.text.trim(),
              'city': _cityController.text.trim(),
            },
          );
        }
      } else {
        if (mounted) {
          _showErrorDialog(result['message'] ?? 'حدث خطأ أثناء التسجيل');
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) _showErrorDialog(_extractErrorMessage(e));
    }
  }

  String _extractErrorMessage(dynamic e) {
    final errorString = e.toString();
    if (errorString.contains('No internet')) {
      return 'لا يوجد اتصال بالإنترنت. يرجى التحقق من الشبكة';
    } else if (errorString.contains('timeout')) {
      return 'انتهت مهلة الطلب. يرجى المحاولة مرة أخرى';
    } else if (errorString.contains('Server error')) {
      return 'خطأ في الخادم. يرجى المحاولة لاحقاً';
    } else if (errorString.contains('already')) {
      return 'البريد الإلكتروني مسجل مسبقاً. جرب تسجيل الدخول';
    } else if (errorString.contains('ApiException:')) {
      final parts = errorString.split('ApiException: ');
      if (parts.length > 1) return parts[1].split(' (Status:')[0];
    }
    return 'حدث خطأ أثناء التسجيل. الرجاء المحاولة مرة أخرى';
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'خطأ',
          textDirection: TextDirection.rtl,
          style:
              TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold),
        ),
        content: Text(
          message,
          textDirection: TextDirection.rtl,
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'حسناً',
              style: TextStyle(
                  color: AppColors.gold, fontWeight: FontWeight.w600),
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
        onTap: isEnabled ? () => setState(() => _selectedRole = role) : null,
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
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.w500,
                color:
                    isSelected ? AppColors.white : AppColors.textPrimary,
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
        listenWhen: (previous, current) {
          // Don't react to AuthAuthenticated that follows OTP verification —
          // the OTP / success screens handle their own navigation.
          if (current is AuthAuthenticated && previous is AuthOtpVerificationSuccess) {
            return false;
          }
          return true;
        },
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            if (state.user.role == UserRole.provider) {
              AppRouter.goToProviderHome(context);
            } else {
              AppRouter.goToUserHome(context);
            }
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message,
                    textDirection: TextDirection.rtl),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = _isLoading || state is AuthLoading;

          return Stack(
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
                  onTap: () => FocusScope.of(context).unfocus(),
                  behavior: HitTestBehavior.opaque,
                  child: SingleChildScrollView(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 40),
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
                                    style: TextStyle(
                                        color: AppColors.black)),
                                TextSpan(
                                    text: 'dly',
                                    style: TextStyle(
                                        color: AppColors.gold)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 60),
                        Container(
                          padding: const EdgeInsets.all(24),
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
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.stretch,
                              children: [
                                const Text(
                                  'تسجيل حساب جديد',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.gold,
                                  ),
                                  textAlign: TextAlign.center,
                                  textDirection: TextDirection.rtl,
                                ),
                                const SizedBox(height: 12),
                                const Text(
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
                                _buildTextField(
                                  controller: _nameController,
                                  hint: 'الاسم بالكامل',
                                  icon: Icons.person_outline,
                                  enabled: !isLoading,
                                  validator: (v) =>
                                      v == null || v.isEmpty
                                          ? 'الرجاء إدخال الاسم بالكامل'
                                          : null,
                                ),
                                const SizedBox(height: 16),
                                _buildTextField(
                                  controller: _emailController,
                                  hint: 'البريد الالكتروني',
                                  icon: Icons.email_outlined,
                                  enabled: !isLoading,
                                  keyboardType:
                                      TextInputType.emailAddress,
                                  validator: (v) {
                                    if (v == null || v.isEmpty) {
                                      return 'الرجاء إدخال البريد الإلكتروني';
                                    }
                                    if (!v.contains('@')) {
                                      return 'البريد الإلكتروني غير صحيح';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                _buildTextField(
                                  controller: _phoneController,
                                  hint: 'رقم الهاتف',
                                  icon: Icons.phone_outlined,
                                  enabled: !isLoading,
                                  keyboardType: TextInputType.phone,
                                  validator: (v) {
                                    if (v == null || v.isEmpty) {
                                      return 'الرجاء إدخال رقم الهاتف';
                                    }
                                    if (v.length < 10) {
                                      return 'رقم الهاتف يجب أن يكون 10 أرقام على الأقل';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                _buildTextField(
                                  controller: _cityController,
                                  hint: 'المدينة',
                                  icon: Icons.location_city_outlined,
                                  enabled: !isLoading,
                                  validator: (v) =>
                                      v == null || v.isEmpty
                                          ? 'الرجاء إدخال المدينة'
                                          : null,
                                ),
                                const SizedBox(height: 16),
                                _buildTextField(
                                  controller: _passwordController,
                                  hint: 'كلمة المرور',
                                  icon: Icons.lock_outline,
                                  enabled: !isLoading,
                                  obscure: _obscurePassword,
                                  suffixIcon: IconButton(
                                    icon: Icon(_obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined),
                                    onPressed: () => setState(() =>
                                        _obscurePassword =
                                            !_obscurePassword),
                                  ),
                                  validator: (v) {
                                    if (v == null || v.isEmpty) {
                                      return 'الرجاء إدخال كلمة المرور';
                                    }
                                    if (v.length < 6) {
                                      return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                _buildTextField(
                                  controller:
                                      _confirmPasswordController,
                                  hint: 'تأكيد كلمة المرور',
                                  icon: Icons.lock_outline,
                                  enabled: !isLoading,
                                  obscure: _obscureConfirmPassword,
                                  suffixIcon: IconButton(
                                    icon: Icon(_obscureConfirmPassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined),
                                    onPressed: () => setState(() =>
                                        _obscureConfirmPassword =
                                            !_obscureConfirmPassword),
                                  ),
                                  validator: (v) {
                                    if (v == null || v.isEmpty) {
                                      return 'الرجاء تأكيد كلمة المرور';
                                    }
                                    if (v != _passwordController.text) {
                                      return 'كلمات المرور غير متطابقة';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  children: [
                                    _buildRoleButton(
                                      label: 'عميل',
                                      role: UserRole.user,
                                      isSelected:
                                          _selectedRole == UserRole.user,
                                      isEnabled: !isLoading,
                                    ),
                                    const SizedBox(width: 12),
                                    _buildRoleButton(
                                      label: 'مزود خدمة',
                                      role: UserRole.provider,
                                      isSelected: _selectedRole ==
                                          UserRole.provider,
                                      isEnabled: !isLoading,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                GestureDetector(
                                  onTap: () => Navigator.of(context).pushNamed(AppRouter.termsAndConditions),
                                  child: Text.rich(
                                    TextSpan(
                                      text: 'بإنشاء حساب، أنت توافق على ',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                      children: const [
                                        TextSpan(
                                          text: 'الشروط والأحكام وسياسة الخصوصية',
                                          style: TextStyle(
                                            color: AppColors.gold,
                                            fontWeight: FontWeight.w600,
                                            decoration: TextDecoration.underline,
                                          ),
                                        ),
                                      ],
                                    ),
                                    textAlign: TextAlign.center,
                                    textDirection: TextDirection.rtl,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  height: 56,
                                  child: ElevatedButton(
                                    onPressed: isLoading
                                        ? null
                                        : () => _handleSignUp(context),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.black,
                                      foregroundColor: AppColors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16),
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
                                              color: AppColors.white,
                                            ),
                                          )
                                        : const Text(
                                            'متابعة',
                                            textDirection:
                                                TextDirection.rtl,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                const Text(
                                  'سجّل الدخول باستخدام',
                                  textAlign: TextAlign.center,
                                  textDirection: TextDirection.rtl,
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    if (Platform.isIOS) ...[
                                      _SocialLoginButton(
                                        imagePath:
                                            'assets/images/apple.png',
                                        onPressed: isLoading
                                            ? null
                                            : () => _handleSocialSignUp(
                                                context, 'apple'),
                                      ),
                                      const SizedBox(width: 16),
                                    ],
                                    _SocialLoginButton(
                                      imagePath:
                                          'assets/images/google.png',
                                      onPressed: isLoading
                                          ? null
                                          : () => _handleSocialSignUp(
                                              context, 'google'),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
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
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const LoginScreen()),
                                      ),
                                      child: const Text(
                                        'تسجيل الدخول',
                                        style: TextStyle(
                                          color: AppColors.gold,
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
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool enabled,
    TextInputType? keyboardType,
    bool obscure = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      textInputAction: TextInputAction.next,
      obscureText: obscure,
      keyboardType: keyboardType,
      enabled: enabled,
      textDirection: TextDirection.rtl,
      style: const TextStyle(fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintTextDirection: TextDirection.rtl,
        hintStyle: TextStyle(color: AppColors.textHint),
        prefixIcon: Icon(icon),
        suffixIcon: suffixIcon,
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
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 16),
      ),
      validator: validator,
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
            border: Border.all(color: AppColors.greyLight, width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Image.asset(imagePath, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }
}