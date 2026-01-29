import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:wedly/data/models/banner_model.dart';
import 'package:wedly/data/services/api_client.dart';
import 'package:wedly/data/services/api_constants.dart';
import 'package:wedly/data/services/api_exceptions.dart';

/// Repository for managing promotional banners
class BannerRepository {
  final ApiClient _apiClient;

  BannerRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Get all active banners
  Future<List<BannerModel>> getBanners() async {
    try {
      debugPrint('BannerRepository: Fetching banners from ${ApiConstants.banners}');
      final response = await _apiClient.get(ApiConstants.banners);

      if (response.data is Map) {
        final data = response.data['data'];
        if (data is Map && data['banners'] is List) {
          final bannersList = (data['banners'] as List)
              .map((json) => BannerModel.fromJson(json))
              .toList();
          debugPrint('BannerRepository: Parsed ${bannersList.length} banners');
          return bannersList;
        }
      }

      debugPrint('BannerRepository: Returning empty list');
      return [];
    } on ApiException {
      rethrow;
    } catch (e) {
      debugPrint('BannerRepository: Exception: $e');
      throw ApiException(message: 'فشل تحميل العروض: $e');
    }
  }

  /// Get all banners (admin only) - includes inactive banners
  Future<List<BannerModel>> getAllBanners() async {
    try {
      debugPrint('BannerRepository: Fetching ALL banners (admin) from ${ApiConstants.adminBanners}');
      final response = await _apiClient.get(ApiConstants.adminBanners);

      if (response.data is Map) {
        final data = response.data['data'];
        if (data is Map && data['banners'] is List) {
          return (data['banners'] as List)
              .map((json) => BannerModel.fromJson(json))
              .toList();
        } else if (data is List) {
          return data
              .map((json) => BannerModel.fromJson(json))
              .toList();
        }
      }

      return [];
    } on ApiException {
      rethrow;
    } catch (e) {
      debugPrint('BannerRepository: Admin endpoint exception: $e');
      throw ApiException(message: 'فشل تحميل جميع العروض: $e');
    }
  }

  /// Get banner by ID
  Future<BannerModel?> getBannerById(String bannerId) async {
    try {
      final response = await _apiClient.get(ApiConstants.bannerById(bannerId));

      final data = response.data is Map
          ? (response.data['data'] ?? response.data['banner'] ?? response.data)
          : response.data;

      if (data is Map<String, dynamic>) {
        return BannerModel.fromJson(data);
      }

      return null;
    } on NotFoundException {
      return null;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'فشل تحميل العرض: $e');
    }
  }

  /// Create new banner (admin only)
  Future<BannerModel> createBanner({
    required String imageUrl,
    String? link,
    bool isActive = true,
    DateTime? expirationDate,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.createBanner,
        data: {
          'image_url': imageUrl,
          if (link != null) 'link': link,
          'is_active': isActive,
          if (expirationDate != null) 'expiration_date': expirationDate.toIso8601String(),
        },
      );

      final data = response.data is Map
          ? (response.data['data'] ?? response.data['banner'] ?? response.data)
          : response.data;

      return BannerModel.fromJson(data);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'فشل إنشاء العرض: $e');
    }
  }

  /// Update existing banner (admin only)
  Future<BannerModel> updateBanner({
    required String bannerId,
    String? imageUrl,
    String? link,
    bool? isActive,
    DateTime? expirationDate,
  }) async {
    try {
      final response = await _apiClient.put(
        ApiConstants.updateBanner(bannerId),
        data: {
          if (imageUrl != null) 'image_url': imageUrl,
          if (link != null) 'link': link,
          if (isActive != null) 'is_active': isActive,
          if (expirationDate != null) 'expiration_date': expirationDate.toIso8601String(),
        },
      );

      final data = response.data is Map
          ? (response.data['data'] ?? response.data['banner'] ?? response.data)
          : response.data;

      return BannerModel.fromJson(data);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'فشل تحديث العرض: $e');
    }
  }

  /// Delete banner (admin only)
  Future<void> deleteBanner(String bannerId) async {
    try {
      await _apiClient.delete(ApiConstants.deleteBanner(bannerId));
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'فشل حذف العرض: $e');
    }
  }

  /// Update banner image (admin only)
  Future<BannerModel> updateBannerImage({
    required String bannerId,
    required FormData formData,
  }) async {
    try {
      final response = await _apiClient.put(
        ApiConstants.updateBannerImage(bannerId),
        data: formData,
      );

      final data = response.data is Map
          ? (response.data['data'] ?? response.data['banner'] ?? response.data)
          : response.data;

      return BannerModel.fromJson(data);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'فشل تحديث صورة العرض: $e');
    }
  }

  /// Toggle banner visibility (admin only)
  Future<BannerModel> toggleBannerVisibility(String bannerId) async {
    try {
      final response = await _apiClient.patch(
        ApiConstants.toggleBannerVisibility(bannerId),
      );

      final data = response.data is Map
          ? (response.data['data'] ?? response.data['banner'] ?? response.data)
          : response.data;

      return BannerModel.fromJson(data);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'فشل تبديل حالة العرض: $e');
    }
  }
}
