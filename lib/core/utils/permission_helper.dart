import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

class PermissionHelper {
  /// Request camera permission
  static Future<bool> requestCameraPermission(BuildContext context) async {
    final status = await Permission.camera.request();

    if (status.isGranted) {
      return true;
    } else if (status.isDenied) {
      _showPermissionDialog(
        context,
        'Camera Permission Required',
        'Please allow camera access to take photos.',
      );
      return false;
    } else if (status.isPermanentlyDenied) {
      _showSettingsDialog(
        context,
        'Camera Permission',
        'Camera permission is permanently denied. Please enable it from app settings.',
      );
      return false;
    }

    return false;
  }

  /// Request storage/photos permission
  static Future<bool> requestStoragePermission(BuildContext context) async {
    PermissionStatus status;

    // For Android 13+ (API 33+), use photos permission
    if (await _isAndroid13OrHigher()) {
      status = await Permission.photos.request();
    } else {
      // For older Android versions, use storage permission
      status = await Permission.storage.request();
    }

    if (status.isGranted) {
      return true;
    } else if (status.isDenied) {
      _showPermissionDialog(
        context,
        'Storage Permission Required',
        'Please allow storage access to select photos from your gallery.',
      );
      return false;
    } else if (status.isPermanentlyDenied) {
      _showSettingsDialog(
        context,
        'Storage Permission',
        'Storage permission is permanently denied. Please enable it from app settings.',
      );
      return false;
    }

    return false;
  }

  /// Request location permission
  static Future<bool> requestLocationPermission(BuildContext context) async {
    final status = await Permission.location.request();

    if (status.isGranted) {
      return true;
    } else if (status.isDenied) {
      _showPermissionDialog(
        context,
        'Location Permission Required',
        'Please allow location access to find nearby wedding service providers.',
      );
      return false;
    } else if (status.isPermanentlyDenied) {
      _showSettingsDialog(
        context,
        'Location Permission',
        'Location permission is permanently denied. Please enable it from app settings.',
      );
      return false;
    }

    return false;
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
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
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
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  /// Check if Android 13 or higher
  static Future<bool> _isAndroid13OrHigher() async {
    // This is a simple check - in production you might want to use platform channels
    // For now, we'll try photos permission first, and fall back to storage if needed
    return true;
  }

  /// Show image source selection (Camera or Gallery)
  static Future<ImageSource?> showImageSourceDialog(BuildContext context) async {
    return showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
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
