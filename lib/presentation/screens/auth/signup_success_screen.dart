import 'package:flutter/material.dart';
import 'package:wedly/core/constants/app_colors.dart';
import 'package:wedly/core/utils/enums.dart';
import 'package:wedly/presentation/screens/auth/provider_documents_screen.dart';
import 'package:wedly/routes/app_router.dart';

class SignupSuccessScreen extends StatelessWidget {
  final UserRole userRole;

  const SignupSuccessScreen({
    super.key,
    required this.userRole,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Success icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.gold,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: AppColors.white,
                  size: 70,
                ),
              ),
              const SizedBox(height: 40),
              // Title
              Text(
                userRole == UserRole.provider
                    ? 'مبروك! تم تفعيل حسابك بنجاح.'
                    : 'مبروك! تم تفعيل حسابك بنجاح.',
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 16),
              // Subtitle
              Text(
                userRole == UserRole.provider
                    ? 'يرجى رفع المستندات المطلوبة لإكمال التسجيل كمزود خدمة.'
                    : 'دلوقتي تقدر تبدأ في استكشاف أجمل قاعات الأفراح وحجز قاعتك المثالية بسهولة.',
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 60),
              // Continue button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    if (userRole == UserRole.provider) {
                      // Provider: Navigate to documents upload screen
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => const ProviderDocumentsScreen(),
                        ),
                      );
                    } else {
                      // User: Navigate directly to user home
                      AppRouter.goToUserHome(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'ابدأ الآن',
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
    );
  }
}
