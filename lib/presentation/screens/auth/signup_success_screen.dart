import 'package:flutter/material.dart';
import 'package:wedly/core/constants/app_colors.dart';
import 'package:wedly/core/utils/enums.dart';
import 'package:wedly/routes/app_router.dart';

class SignupSuccessScreen extends StatelessWidget {
  final UserRole userRole;

  const SignupSuccessScreen({
    super.key,
    required this.userRole,
  });

  @override
  Widget build(BuildContext context) {
    final isProvider = userRole == UserRole.provider;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - 64),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  color: AppColors.gold,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: AppColors.white, size: 70),
              ),
              const SizedBox(height: 40),

              Text(
                isProvider
                    ? 'تم إنشاء حسابك بنجاح!'
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

              Text(
                isProvider
                    ? 'يمكنك الآن إضافة خدماتك والبدء في استقبال الحجوزات. إذا رفعت مستندات التحقق سيتم مراجعتها خلال 24-48 ساعة.'
                    : 'يمكنك الآن استكشاف أجمل قاعات الأفراح وحجز قاعتك المثالية بسهولة.',
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),

              if (isProvider) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.gold.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      const Icon(Icons.info_outline,
                          color: AppColors.gold, size: 20),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'تم تفعيل حسابك بنجاح. مستندات التحقق اختيارية وتساعد على زيادة ثقة العملاء.',
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF8B6914),
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 60),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    if (isProvider) {
                      AppRouter.goToProviderHome(context);
                    } else {
                      AppRouter.goToUserHome(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text(
                    'ابدأ الآن',
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
          },
        ),
      ),
    );
  }
}