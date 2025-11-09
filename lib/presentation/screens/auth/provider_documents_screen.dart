import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:wedly/core/constants/app_colors.dart';
import 'package:wedly/presentation/screens/auth/login_screen.dart';

class ProviderDocumentsScreen extends StatefulWidget {
  const ProviderDocumentsScreen({super.key});

  @override
  State<ProviderDocumentsScreen> createState() =>
      _ProviderDocumentsScreenState();
}

class _ProviderDocumentsScreenState extends State<ProviderDocumentsScreen> {
  final ImagePicker _picker = ImagePicker();
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  // Track which documents have been uploaded
  final Map<String, bool> _uploadedDocs = {
    'personalId': false,
    'licensePhoto': false,
    'commercialRecord': false,
    'taxCard': false,
  };

  // Store selected image paths
  final Map<String, String?> _imagePaths = {
    'personalId': null,
    'licensePhoto': null,
    'commercialRecord': null,
    'taxCard': null,
  };

  // Only require the first two documents (personalId and licensePhoto)
  bool get _allDocsUploaded =>
      _uploadedDocs['personalId']! && _uploadedDocs['licensePhoto']!;

  Future<void> _requestLocationPermission() async {
    try {
      // Check location service
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'الرجاء تفعيل خدمة الموقع',
              textDirection: TextDirection.rtl,
            ),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Check and request permission
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              'إذن الموقع مطلوب',
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
            ),
            content: Text(
              'يرجى منح إذن الوصول إلى الموقع من إعدادات التطبيق',
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('إلغاء', textDirection: TextDirection.rtl),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  openAppSettings();
                },
                child: Text('فتح الإعدادات', textDirection: TextDirection.rtl),
              ),
            ],
          ),
        );
        return;
      }

      if (permission == LocationPermission.denied) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'يرجى منح إذن الوصول إلى الموقع',
              textDirection: TextDirection.rtl,
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Get current location
      _currentPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تم تحديد موقعك بنجاح',
            textDirection: TextDirection.rtl,
          ),
          backgroundColor: AppColors.gold,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'حدث خطأ في تحديد الموقع',
            textDirection: TextDirection.rtl,
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _uploadDocument(String docType) async {
    try {
      // Check and request permission first
      PermissionStatus status = await Permission.photos.status;

      if (status.isDenied) {
        // Request permission
        status = await Permission.photos.request();
      }

      if (status.isPermanentlyDenied) {
        if (!mounted) return;
        // Show dialog to open settings
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              'إذن مطلوب',
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
            ),
            content: Text(
              'يرجى منح إذن الوصول إلى الصور من إعدادات التطبيق',
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('إلغاء', textDirection: TextDirection.rtl),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  openAppSettings();
                },
                child: Text('فتح الإعدادات', textDirection: TextDirection.rtl),
              ),
            ],
          ),
        );
        return;
      }

      if (status.isDenied) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'يرجى منح إذن الوصول إلى الصور',
              textDirection: TextDirection.rtl,
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Pick image from gallery
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
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
            'حدث خطأ أثناء رفع المستند',
            textDirection: TextDirection.rtl,
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _completeRegistration() {
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

    // Show success dialog
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
                'تم إرسال طلبك للمراجعة بنجاح',
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
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => const LoginScreen(),
                      ),
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
                    // Personal ID
                    _buildUploadBox(
                      title: 'صورة البطاقة الشخصية (الهوية)',
                      docType: 'personalId',
                      isUploaded: _uploadedDocs['personalId']!,
                    ),
                    const SizedBox(height: 16),
                    // License Photo
                    _buildUploadBox(
                      title: 'صورة البطاقة الشخصية (الهوية)',
                      docType: 'licensePhoto',
                      isUploaded: _uploadedDocs['licensePhoto']!,
                    ),
                    const SizedBox(height: 16),
                    // Commercial Record
                    _buildUploadBox(
                      title: 'السجل التجاري (اختياري)',
                      docType: 'commercialRecord',
                      isUploaded: _uploadedDocs['commercialRecord']!,
                    ),
                    const SizedBox(height: 16),
                    // Tax Card
                    _buildUploadBox(
                      title: 'البطاقة الضريبية (اختياري)',
                      docType: 'taxCard',
                      isUploaded: _uploadedDocs['taxCard']!,
                    ),
                    const SizedBox(height: 32),
                    // Complete Registration Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _completeRegistration,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.gold,
                          foregroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
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
                color: isUploaded ? AppColors.gold.withOpacity(0.2) : AppColors.white,
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
