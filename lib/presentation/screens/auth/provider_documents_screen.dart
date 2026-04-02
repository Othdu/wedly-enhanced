import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wedly/core/constants/app_colors.dart';
import 'package:wedly/core/di/injection_container.dart';
import 'package:wedly/core/utils/enums.dart';
import 'package:wedly/core/utils/permission_helper.dart' as permission;
import 'package:wedly/data/repositories/auth_repository.dart';
import 'package:wedly/routes/app_router.dart';

class ProviderDocumentsScreen extends StatefulWidget {
  final String name;
  final String email;
  final String password;
  final String phone;
  final String city;

  const ProviderDocumentsScreen({
    super.key,
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
    required this.city,
  });

  @override
  State<ProviderDocumentsScreen> createState() =>
      _ProviderDocumentsScreenState();
}

class _ProviderDocumentsScreenState extends State<ProviderDocumentsScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isPickingImage = false;
  bool _isSubmitting = false;

  final Map<String, bool> _uploadedDocs = {
    'id_front': false,
    'id_back': false,
    'commercial_register': false,
    'tax_card': false,
  };

  final Map<String, String?> _imagePaths = {
    'id_front': null,
    'id_back': null,
    'commercial_register': null,
    'tax_card': null,
  };

  Future<void> _uploadDocument(String docType) async {
    if (_isPickingImage) return;
    setState(() => _isPickingImage = true);

    try {
      if (!mounted) return;
      final hasPermission =
          await permission.PermissionHelper.requestStoragePermission(context);
      if (!hasPermission || !mounted) return;

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null && mounted) {
        setState(() {
          _uploadedDocs[docType] = true;
          _imagePaths[docType] = image.path;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'تم رفع المستند بنجاح',
              textDirection: TextDirection.rtl,
            ),
            backgroundColor: AppColors.gold,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'حدث خطأ أثناء رفع المستند',
            textDirection: TextDirection.rtl,
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isPickingImage = false);
    }
  }

  Future<void> _completeRegistration() async {
    setState(() => _isSubmitting = true);

    try {
      final authRepository = getIt<AuthRepository>();
      final result = await authRepository.registerProvider(
        email: widget.email,
        password: widget.password,
        name: widget.name,
        phone: widget.phone,
        city: widget.city,
        idFrontPath: _imagePaths['id_front'],
        idBackPath: _imagePaths['id_back'],
        commercialRegisterPath: _imagePaths['commercial_register'],
        taxCardPath: _imagePaths['tax_card'],
      );

      setState(() => _isSubmitting = false);

      if (result['success'] == true) {
        if (!mounted) return;
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
            'phoneOrEmail': widget.email,
            'userRole': UserRole.provider,
            'name': widget.name,
            'password': widget.password,
            'phone': widget.phone,
          },
        );
      } else {
        if (!mounted) return;
        _showErrorDialog(result['message'] ?? 'حدث خطأ أثناء إنشاء الحساب');
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (!mounted) return;

      String errorMsg = e.toString();
      if (errorMsg.contains('ApiException:')) {
        final parts = errorMsg.split('ApiException: ');
        if (parts.length > 1) errorMsg = parts[1].split(' (Status:')[0];
      }

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'خطأ في التسجيل',
            textDirection: TextDirection.rtl,
            style: TextStyle(
                color: AppColors.gold, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Text(errorMsg, textDirection: TextDirection.rtl),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'حسناً',
                style: TextStyle(color: AppColors.gold),
              ),
            ),
          ],
        ),
      );
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'خطأ',
          textDirection: TextDirection.rtl,
          style: TextStyle(
              color: AppColors.gold, fontWeight: FontWeight.bold),
        ),
        content: Text(message, textDirection: TextDirection.rtl),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'حسناً',
              style: TextStyle(color: AppColors.gold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;
    final scale = (screenWidth / 375).clamp(0.8, 1.4);
    final vScale = (screenHeight / 812).clamp(0.7, 1.3);

    final iconSize = (72 * scale).clamp(56.0, 80.0);
    final titleFontSize = (24 * scale).clamp(20.0, 28.0);
    final bodyFontSize = (14 * scale).clamp(12.0, 16.0);
    final buttonHeight = (56 * vScale).clamp(46.0, 60.0);
    final buttonFontSize = (16 * scale).clamp(14.0, 18.0);
    final cardPaddingH = (24 * scale).clamp(16.0, 28.0);
    final cardPaddingV = (28 * vScale).clamp(18.0, 32.0);
    final outerPaddingH = (24 * scale).clamp(16.0, 28.0);
    final uploadBoxHeight = (100 * vScale).clamp(80.0, 120.0);
    final sectionLabelSize = (16 * scale).clamp(14.0, 18.0);
    final bannerFontSize = (13 * scale).clamp(11.0, 15.0);
    final uploadIconSize = (28 * scale).clamp(22.0, 34.0);
    final uploadTextSize = (13 * scale).clamp(11.0, 15.0);

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
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding:
                        EdgeInsets.symmetric(horizontal: outerPaddingH),
                    child: Column(
                      children: [
                        SizedBox(height: isSmallScreen ? 4 : 8),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            horizontal: cardPaddingH,
                            vertical: cardPaddingV,
                          ),
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
                          child: Column(
                            children: [
                              Container(
                                width: iconSize,
                                height: iconSize,
                                decoration: BoxDecoration(
                                  color: AppColors.gold
                                      .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(
                                      iconSize * 0.28),
                                ),
                                child: Icon(
                                  Icons.description_outlined,
                                  size: iconSize * 0.5,
                                  color: AppColors.gold,
                                ),
                              ),
                              SizedBox(
                                  height: isSmallScreen ? 16 : 24),
                              Text(
                                'إكمال التسجيل',
                                textAlign: TextAlign.center,
                                textDirection: TextDirection.rtl,
                                style: TextStyle(
                                  fontSize: titleFontSize,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.gold,
                                ),
                              ),
                              SizedBox(
                                  height: isSmallScreen ? 12 : 16),

                              // Info banner
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(
                                    (14 * scale).clamp(10.0, 18.0)),
                                decoration: BoxDecoration(
                                  color: AppColors.gold
                                      .withValues(alpha: 0.08),
                                  borderRadius:
                                      BorderRadius.circular(12),
                                ),
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'رفع المستندات اختياري ويمكن إضافتها لاحقاً عند نشر أول خدمة.',
                                        textDirection:
                                            TextDirection.rtl,
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                          fontSize: bannerFontSize,
                                          color:
                                              const Color(0xFF8B6914),
                                          height: 1.5,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                        width:
                                            isSmallScreen ? 8 : 10),
                                    Icon(
                                      Icons.info_outline,
                                      size: (18 * scale)
                                          .clamp(14.0, 22.0),
                                      color: AppColors.gold,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                  height: isSmallScreen ? 16 : 24),

                              // Section label
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  'مستندات التحقق (اختيارية)',
                                  textDirection: TextDirection.rtl,
                                  style: TextStyle(
                                    fontSize: sectionLabelSize,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              SizedBox(
                                  height: isSmallScreen ? 12 : 16),

                              // Upload boxes in 2x2 grid
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  final gridGap =
                                      (12 * scale).clamp(8.0, 16.0);

                                  return Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _buildUploadBox(
                                              title:
                                                  'صورة الهوية (الوجه)',
                                              docType: 'id_front',
                                              isUploaded:
                                                  _uploadedDocs[
                                                      'id_front']!,
                                              height: uploadBoxHeight,
                                              iconSize: uploadIconSize,
                                              textSize: uploadTextSize,
                                            ),
                                          ),
                                          SizedBox(width: gridGap),
                                          Expanded(
                                            child: _buildUploadBox(
                                              title:
                                                  'صورة الهوية (الظهر)',
                                              docType: 'id_back',
                                              isUploaded:
                                                  _uploadedDocs[
                                                      'id_back']!,
                                              height: uploadBoxHeight,
                                              iconSize: uploadIconSize,
                                              textSize: uploadTextSize,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: gridGap),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _buildUploadBox(
                                              title: 'السجل التجاري',
                                              docType:
                                                  'commercial_register',
                                              isUploaded: _uploadedDocs[
                                                  'commercial_register']!,
                                              height: uploadBoxHeight,
                                              iconSize: uploadIconSize,
                                              textSize: uploadTextSize,
                                            ),
                                          ),
                                          SizedBox(width: gridGap),
                                          Expanded(
                                            child: _buildUploadBox(
                                              title:
                                                  'البطاقة الضريبية',
                                              docType: 'tax_card',
                                              isUploaded:
                                                  _uploadedDocs[
                                                      'tax_card']!,
                                              height: uploadBoxHeight,
                                              iconSize: uploadIconSize,
                                              textSize: uploadTextSize,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                },
                              ),
                              SizedBox(
                                  height: isSmallScreen ? 24 : 32),

                              // Submit button
                              SizedBox(
                                width: double.infinity,
                                height: buttonHeight,
                                child: ElevatedButton(
                                  onPressed: _isSubmitting
                                      ? null
                                      : _completeRegistration,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.black,
                                    foregroundColor: AppColors.white,
                                    disabledBackgroundColor: AppColors
                                        .black
                                        .withValues(alpha: 0.4),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16)),
                                    elevation: 0,
                                  ),
                                  child: _isSubmitting
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child:
                                              CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: AppColors.white,
                                          ),
                                        )
                                      : Text(
                                          'إكمال التسجيل',
                                          textDirection:
                                              TextDirection.rtl,
                                          style: TextStyle(
                                            fontSize: buttonFontSize,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                              ),
                              SizedBox(
                                  height: isSmallScreen ? 8 : 12),

                              // Skip button
                              TextButton(
                                onPressed: _isSubmitting
                                    ? null
                                    : _completeRegistration,
                                child: Text(
                                  'تخطي ورفع المستندات لاحقاً',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: bodyFontSize,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 20 : 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadBox({
    required String title,
    required String docType,
    required bool isUploaded,
    required double height,
    required double iconSize,
    required double textSize,
  }) {
    return GestureDetector(
      onTap: () => _uploadDocument(docType),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: height,
        decoration: BoxDecoration(
          color: isUploaded
              ? AppColors.gold.withValues(alpha: 0.08)
              : AppColors.greyBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isUploaded ? AppColors.gold : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(iconSize * 0.4),
              decoration: BoxDecoration(
                color: isUploaded
                    ? AppColors.gold.withValues(alpha: 0.15)
                    : AppColors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isUploaded
                    ? Icons.check_circle
                    : Icons.add_photo_alternate_outlined,
                color: isUploaded ? AppColors.gold : AppColors.grey,
                size: iconSize,
              ),
            ),
            SizedBox(height: height * 0.06),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  isUploaded ? 'تم الرفع' : title,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontSize: textSize,
                    color: isUploaded
                        ? AppColors.gold
                        : AppColors.textSecondary,
                    fontWeight:
                        isUploaded ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
