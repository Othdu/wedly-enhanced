import 'dart:io';
import 'package:dio/dio.dart';
import 'api_client.dart';

/// Service for uploading profile images to the server
/// Note: Service images are handled differently - they are uploaded as part of
/// the service creation request (POST /api/services with multipart/form-data)
class ImageUploadService {
  final ApiClient _apiClient;

  ImageUploadService(this._apiClient);

  /// Upload a profile image and return the URL
  /// Endpoint: POST /api/users/profile/image
  /// This is specifically for user/provider profile pictures
  Future<String> uploadProfileImage(File imageFile) async {
    try {
      // Get file name and extension
      final fileName = imageFile.path.split(Platform.pathSeparator).last;

      // Create FormData with the image
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });

      // Upload to profile image endpoint
      final response = await _apiClient.post(
        '/api/users/profile/image',
        data: formData,
      );

      // Extract image URL from response
      final imageUrl = response.data['image_url'] ??
                       response.data['data']?['image_url'] ??
                       response.data['url'];

      if (imageUrl == null || imageUrl.isEmpty) {
        throw Exception('Server did not return image URL');
      }

      return imageUrl;
    } catch (e) {
      throw Exception('Failed to upload profile image: ${e.toString()}');
    }
  }

  /// Upload multiple profile images and return list of URLs
  /// Note: This is for profile pictures only
  Future<List<String>> uploadMultipleProfileImages(List<File> imageFiles) async {
    final List<String> uploadedUrls = [];

    for (final imageFile in imageFiles) {
      final url = await uploadProfileImage(imageFile);
      uploadedUrls.add(url);
    }

    return uploadedUrls;
  }
}
