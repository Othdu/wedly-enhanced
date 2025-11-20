import 'package:flutter/material.dart';
import 'package:wedly/core/constants/app_colors.dart';
import 'package:wedly/core/constants/app_strings.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  static const List<_TermsSection> _sections = [
    _TermsSection(
      title: 'الوصف العام:',
      description:
          'مرحباً بك في تطبيق Wedly. يرجى قراءة هذه الشروط والأحكام بعناية قبل استخدام خدماتنا، حيث إن استخدامك للتطبيق يعني موافقتك الكاملة عليها.',
    ),
    _TermsSection(
      title: '1. استخدام التطبيق',
      bullets: [
        'يهدف Wedly إلى تسهيل حجز وتنظيم خدمات حفلات الزفاف والمناسبات.',
        'يجب على المستخدم إدخال بيانات صحيحة أثناء إنشاء الحساب أو الحجز.',
        'يحتفظ التطبيق بالحق في رفض أو إلغاء أي حجز في حال وجود بيانات غير دقيقة.',
      ],
    ),
    _TermsSection(
      title: '2. الدفع والحجوزات',
      bullets: [
        'الأسعار المعروضة داخل التطبيق تقديرية وقابلة للتغيير من قبل مقدم الخدمة.',
        'قد يتطلب دفع رسوم لتأكيد الحجز.',
        'غير مسؤول عن أي تعاملات مالية تتم خارج التطبيق.',
      ],
    ),
    _TermsSection(
      title: '3. الخصوصية والأمان',
      bullets: [
        'يلتزم Wedly بالحفاظ على سرية بيانات المستخدمين وعدم مشاركتها مع أي طرف ثالث.',
        'يتم استخدام البيانات فقط لأغراض تحسين تجربة المستخدم داخل التطبيق.',
      ],
    ),
    _TermsSection(
      title: '4. الإلغاء والاسترجاع',
      bullets: [
        'تختلف سياسات الإلغاء من خدمة لأخرى.',
        'في حالة الإلغاء يرجى مراجعة مقدم الخدمة مباشرة لمعرفة سياسة الاسترجاع.',
      ],
    ),
    _TermsSection(
      title: '5. التعديلات',
      bullets: [
        'يحق لـ Wedly تعديل هذه الشروط في أي وقت.',
        'سيتم إخطار المستخدمين عند وجود تغييرات جوهرية.',
      ],
    ),
    _TermsSection(
      title: '6. التواصل معنا',
      bullets: [
        'في حال وجود أي استفسار، يمكنك التواصل مع فريق الدعم من صفحة "المساعدة والدعم" داخل التطبيق.',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greyBackground,

      // 🔥 AppBar مطابق 100% للشاشة السابقة
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
          child: AppBar(
            elevation: 0,
            backgroundColor: AppColors.gold,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Padding(
              padding: EdgeInsets.only(top: 6),
              child: Text(
                AppStrings.termsAndConditions,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),

      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final section in _sections) ...[
                _SectionWidget(section: section),
                if (section != _sections.last)
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 18),
                    height: 1,
                    color: AppColors.greyLight,
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionWidget extends StatelessWidget {
  const _SectionWidget({required this.section});

  final _TermsSection section;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          section.title,
          textDirection: TextDirection.rtl,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            height: 1.5,
          ),
        ),
        if (section.description != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              section.description!,
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.7,
              ),
            ),
          ),
        if (section.bullets.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Column(
              children: section.bullets
                  .map(
                    (bullet) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _BulletItem(text: bullet),
                    ),
                  )
                  .toList(),
            ),
          ),
      ],
    );
  }
}

class _BulletItem extends StatelessWidget {
  const _BulletItem({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      textDirection: TextDirection.rtl,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 6, left: 8),
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: AppColors.gold,
            shape: BoxShape.circle,
          ),
        ),
        Expanded(
          child: Text(
            text,
            textDirection: TextDirection.rtl,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.7,
            ),
          ),
        ),
      ],
    );
  }
}

class _TermsSection {
  const _TermsSection({
    required this.title,
    this.description,
    this.bullets = const [],
  });

  final String title;
  final String? description;
  final List<String> bullets;
}
