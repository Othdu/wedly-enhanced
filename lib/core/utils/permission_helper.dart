import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

class PermissionHelper {
  /// Request camera permission
  static Future<bool> requestCameraPermission(BuildContext context) async {
    // On iOS, image_picker handles permissions natively
    if (Platform.isIOS) return true;

    final status = await Permission.camera.request();

    if (status.isGranted || status.isLimited) {
      return true;
    } else if (status.isPermanentlyDenied) {
      _showSettingsDialog(
        context,
        'إذن الكاميرا',
        'تم رفض إذن الكاميرا بشكل دائم. يرجى تفعيله من إعدادات التطبيق.',
      );
      return false;
    } else {
      _showPermissionDialog(
        context,
        'إذن الكاميرا مطلوب',
        'يرجى السماح بالوصول إلى الكاميرا لالتقاط الصور.',
      );
      return false;
    }
  }

  /// Request photos/storage permission
  static Future<bool> requestStoragePermission(BuildContext context) async {
    // On iOS, image_picker handles permissions natively
    if (Platform.isIOS) return true;

    // On Android, use photos for API 33+ or storage for older
    PermissionStatus status = await Permission.photos.request();
    if (status.isPermanentlyDenied) {
      // Fallback: try storage permission for older Android
      status = await Permission.storage.request();
    }

    if (status.isGranted || status.isLimited) {
      return true;
    } else if (status.isPermanentlyDenied) {
      _showSettingsDialog(
        context,
        'إذن الصور',
        'تم رفض إذن الوصول إلى الصور بشكل دائم. يرجى تفعيله من إعدادات التطبيق.',
      );
      return false;
    } else {
      _showPermissionDialog(
        context,
        'إذن الصور مطلوب',
        'يرجى السماح بالوصول إلى الصور لاختيار صورة من المعرض.',
      );
      return false;
    }
  }

  /// Request location permission
  static Future<bool> requestLocationPermission(BuildContext context) async {
    final status = await Permission.location.request();

    if (status.isGranted || status.isLimited) {
      return true;
    } else if (status.isPermanentlyDenied) {
      _showSettingsDialog(
        context,
        'إذن الموقع',
        'تم رفض إذن الموقع بشكل دائم. يرجى تفعيله من إعدادات التطبيق.',
      );
      return false;
    } else {
      _showPermissionDialog(
        context,
        'إذن الموقع مطلوب',
        'يرجى السماح بالوصول إلى الموقع للعثور على مقدمي خدمات الأفراح القريبين.',
      );
      return false;
    }
  }

  /// Show permission denied dialog
  static void _showPermissionDialog(
    BuildContext context,
    String title,
    String message,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, textDirection: TextDirection.rtl, textAlign: TextAlign.right),
        content: Text(message, textDirection: TextDirection.rtl, textAlign: TextAlign.right),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }

  /// Show settings dialog for permanently denied permissions
  static void _showSettingsDialog(
    BuildContext context,
    String title,
    String message,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, textDirection: TextDirection.rtl, textAlign: TextAlign.right),
        content: Text(message, textDirection: TextDirection.rtl, textAlign: TextAlign.right),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('فتح الإعدادات'),
          ),
        ],
      ),
    );
  }

  /// Show image source selection (Camera or Gallery)
  static Future<ImageSource?> showImageSourceDialog(BuildContext context) async {
    return showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('اختر مصدر الصورة', textDirection: TextDirection.rtl, textAlign: TextAlign.right),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('الكاميرا', textDirection: TextDirection.rtl),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('المعرض', textDirection: TextDirection.rtl),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }
}

enum ImageSource {
  camera,
  gallery,
}
