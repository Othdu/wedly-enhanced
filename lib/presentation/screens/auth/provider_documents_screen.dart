import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wedly/core/constants/app_colors.dart';
import 'package:wedly/core/di/injection_container.dart';
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

  // Track which documents have been uploaded
  // API field names: id_front, id_back, commercial_register, tax_card
  final Map<String, bool> _uploadedDocs = {
    'id_front': false,
    'id_back': false,
    'commercial_register': false,
    'tax_card': false,
  };

  // Store selected image paths
  final Map<String, String?> _imagePaths = {
    'id_front': null,
    'id_back': null,
    'commercial_register': null,
    'tax_card': null,
  };

  // Only require the first two documents (id_front and id_back)
  bool get _allDocsUploaded =>
      _uploadedDocs['id_front']! && _uploadedDocs['id_back']!;

  Future<void> _uploadDocument(String docType) async {
    // Prevent multiple simultaneous calls
    if (_isPickingImage) return;

    setState(() {
      _isPickingImage = true;
    });

    try {
      // Request photos permission using the helper
      if (!mounted) return;
      final hasPermission = await permission.PermissionHelper.requestStoragePermission(context);
      if (!hasPermission || !mounted) return;

      // Pick image from gallery
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null && mounted) {
        setState(() {
          _uploadedDocs[docType] = true;
          _imagePaths[docType] = image.path;
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم رفع المستند بنجاح',
              textDirection: TextDirection.rtl,
            ),
            backgroundColor: AppColors.gold,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'حدث خطأ أثناء رفع المستند: $e',
            textDirection: TextDirection.rtl,
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isPickingImage = false;
        });
      }
    }
  }

  Future<void> _completeRegistration() async {
    // Validate required documents
    if (!_allDocsUploaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'الرجاء رفع جميع المستندات المطلوبة',
            textDirection: TextDirection.rtl,
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Set loading state
    setState(() {
      _isSubmitting = true;
    });

    try {
      // Call API to register provider with documents
      final authRepository = getIt<AuthRepository>();
      final result = await authRepository.registerProvider(
        email: widget.email,
        password: widget.password,
        name: widget.name,
        phone: widget.phone,
        city: widget.city,
        idFrontPath: _imagePaths['id_front']!,
        idBackPath: _imagePaths['id_back']!,
        commercialRegisterPath: _imagePaths['commercial_register'],
        taxCardPath: _imagePaths['tax_card'],
      );

      setState(() {
        _isSubmitting = false;
      });

      if (result['success'] == true) {
        // Show success dialog
        if (!mounted) return;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.gold,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: AppColors.white,
                      size: 50,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    result['message'] ?? 'تم إرسال طلبك للمراجعة بنجاح',
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'جاري مراجعة المستندات والتحقق منها، خلال 24 - 48 ساعة',
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close dialog
                        // Navigate to login screen
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          AppRouter.login,
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'تم',
                        textDirection: TextDirection.rtl,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      } else {
        // Show error message
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message'] ?? 'حدث خطأ أثناء إرسال المستندات',
              textDirection: TextDirection.rtl,
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'حدث خطأ أثناء إرسال المستندات: $e',
            textDirection: TextDirection.rtl,
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gold,
      body: SafeArea(
        child: Column(
          children: [
            // Top section - Golden background with title
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_ios, color: AppColors.black),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'صورة البطاقة الشخصية (الهوية)',
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Bottom section - White card with upload boxes
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    const SizedBox(height: 16),
                    // ID Front (صورة البطاقة الشخصية - الوجه)
                    _buildUploadBox(
                      title: 'صورة البطاقة الشخصية (الوجه)',
                      docType: 'id_front',
                      isUploaded: _uploadedDocs['id_front']!,
                    ),
                    const SizedBox(height: 16),
                    // ID Back (صورة البطاقة الشخصية - الظهر)
                    _buildUploadBox(
                      title: 'صورة البطاقة الشخصية (الظهر)',
                      docType: 'id_back',
                      isUploaded: _uploadedDocs['id_back']!,
                    ),
                    const SizedBox(height: 16),
                    // Commercial Register (السجل التجاري - اختياري)
                    _buildUploadBox(
                      title: 'السجل التجاري (اختياري)',
                      docType: 'commercial_register',
                      isUploaded: _uploadedDocs['commercial_register']!,
                    ),
                    const SizedBox(height: 16),
                    // Tax Card (البطاقة الضريبية - اختياري)
                    _buildUploadBox(
                      title: 'البطاقة الضريبية (اختياري)',
                      docType: 'tax_card',
                      isUploaded: _uploadedDocs['tax_card']!,
                    ),
                    const SizedBox(height: 32),
                    // Complete Registration Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _completeRegistration,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.gold,
                          foregroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.white,
                                ),
                              )
                            : Text(
                                'اكتمال التسجيل',
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
          ],
        ),
      ),
    );
  }

  Widget _buildUploadBox({
    required String title,
    required String docType,
    required bool isUploaded,
  }) {
    return GestureDetector(
      onTap: () => _uploadDocument(docType),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: AppColors.greyBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUploaded ? AppColors.gold : AppColors.greyLight,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isUploaded ? AppColors.gold.withValues(alpha: 0.2) : AppColors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isUploaded ? Icons.check_circle : Icons.add_photo_alternate_outlined,
                color: isUploaded ? AppColors.gold : AppColors.grey,
                size: 32,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isUploaded ? 'تم الرفع' : title,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontSize: 13,
                color: isUploaded ? AppColors.gold : AppColors.textSecondary,
                fontWeight: isUploaded ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
