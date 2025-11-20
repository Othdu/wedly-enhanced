import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wedly/core/constants/app_colors.dart';
import 'package:wedly/core/constants/app_strings.dart';

class HelpAndSupportScreen extends StatelessWidget {
  const HelpAndSupportScreen({super.key});

  static const List<_SupportSection> _sections = [
    _SupportSection(
      title: 'الوصف العام',
      description:
          'نحن هنا لمساعدتك في أي وقت فريق Wedly Support جاهز للرد على جميع استفساراتك ومساعدتك في حل أي مشكلة تواجهها أثناء استخدام التطبيق.',
    ),
    _SupportSection(
      title: '1. المشكلات الشائعة',
      bullets: [
        'لم أستطع تسجيل الدخول',
        'لم يتم تأكيد الحجز',
        'لم يصلني إشعار بالدفع',
        'أريد تعديل أو إلغاء حجز',
      ],
    ),
    _SupportSection(
      title: '2. طرق التواصل معنا',
      bullets: [
        'البريد الإلكتروني : Wedly@wedlyinfo.com',
        'رقم الدعم : +20 103 380 8046',
      ],
    ),
    _SupportSection(
      title: '3. ساعات العمل',
      bullets: ['يوميًا من 9 صباحا إلى 10 مساءً', 'ما عدا الجمعة'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greyBackground,

      // 🔥 نفس AppBar المستخدم في الشاشات السابقة
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
                AppStrings.helpAndSupport,
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
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            padding: const EdgeInsets.all(20),
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
      ),
    );
  }
}

// SECTION WIDGET
class _SectionWidget extends StatelessWidget {
  const _SectionWidget({required this.section});

  final _SupportSection section;

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
            color: AppColors.gold,
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

// BULLET ITEM (Clickable)
class _BulletItem extends StatelessWidget {
  const _BulletItem({required this.text});

  final String text;

  bool get isEmail => text.contains('@');
  bool get isPhone => text.contains('+20');

  String? get _label {
    if (isEmail || isPhone) {
      final parts = text.split(':');
      if (parts.length > 1) {
        return parts.first.trim();
      }
    }
    return null;
  }

  String? get _value {
    if (isEmail || isPhone) {
      final parts = text.split(':');
      if (parts.length > 1) {
        return parts.last.trim();
      }
    }
    return null;
  }

  Future<void> _handleTap(BuildContext context) async {
    if (isEmail && _value != null) {
      // Open email app
      await _launchEmail(context, _value!);
    } else if (isPhone && _value != null) {
      // Show dialog to choose between Call or WhatsApp
      _showPhoneOptionsDialog(context);
    }
  }

  Future<void> _launchEmail(BuildContext context, String email) async {
    try {
      final uri = Uri(scheme: 'mailto', path: email);
      final launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
      if (!launched) {
        _showCopyOption(context, email, 'البريد الإلكتروني');
      }
    } catch (e) {
      debugPrint('Error launching email: $e');
      _showCopyOption(context, email, 'البريد الإلكتروني');
    }
  }

  void _showPhoneOptionsDialog(BuildContext context) {
    final phone = _value!.replaceAll(' ', '');
    final phoneWithoutPlus = phone.replaceFirst('+', '');

    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('اختر طريقة التواصل'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.phone, color: AppColors.gold),
                title: const Text('اتصال'),
                onTap: () {
                  Navigator.pop(context);
                  _makePhoneCall(context, phone);
                },
              ),
              ListTile(
                leading: Image.asset(
                  'assets/images/WhatsApp.svg.webp',
                  width: 24,
                  height: 24,
                ),
                title: const Text('واتساب'),
                onTap: () {
                  Navigator.pop(context);
                  _openWhatsApp(context, phoneWithoutPlus);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _makePhoneCall(BuildContext context, String phone) async {
    try {
      final uri = Uri(scheme: 'tel', path: phone);
      final launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
      if (!launched) {
        _showCopyOption(context, phone, 'رقم الهاتف');
      }
    } catch (e) {
      debugPrint('Error making phone call: $e');
      _showCopyOption(context, phone, 'رقم الهاتف');
    }
  }

  Future<void> _openWhatsApp(BuildContext context, String phone) async {
    try {
      // WhatsApp URL format: https://wa.me/[country code][phone number]
      final uri = Uri.parse('https://wa.me/$phone');
      final launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
      if (!launched) {
        _showCopyOption(context, phone, 'رقم الواتساب');
      }
    } catch (e) {
      debugPrint('Error opening WhatsApp: $e');
      _showCopyOption(context, phone, 'رقم الواتساب');
    }
  }

  void _showCopyOption(BuildContext context, String value, String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Directionality(
          textDirection: TextDirection.rtl,
          child: Row(
            children: [
              Expanded(child: Text('تعذر فتح $label. اضغط للنسخ')),
              TextButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: value));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Directionality(
                        textDirection: TextDirection.rtl,
                        child: Text('تم نسخ $label'),
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: const Text('نسخ'),
              ),
            ],
          ),
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasClickableValue = (isEmail || isPhone) && _value != null;

    return Row(
      textDirection: TextDirection.rtl,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 6, left: 8),
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
        ),

        // Text
        Expanded(
          child: hasClickableValue
              ? Row(
                  textDirection: TextDirection.rtl,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Label part (not clickable)
                    Text(
                      '${_label} : ',
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.7,
                      ),
                    ),
                    // Value part (clickable)
                    Flexible(
                      child: GestureDetector(
                        onTap: () => _handleTap(context),
                        child: Directionality(
                          textDirection: isPhone
                              ? TextDirection.ltr
                              : TextDirection.rtl,
                          child: Text(
                            _value!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.gold,
                              height: 1.7,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : Text(
                  text.trim(),
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

// SECTION MODEL
class _SupportSection {
  const _SupportSection({
    required this.title,
    this.description,
    this.bullets = const [],
  });

  final String title;
  final String? description;
  final List<String> bullets;
}
