import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:wedly/data/models/banner_model.dart';
import 'package:wedly/data/services/api_client.dart';
import 'package:wedly/data/services/api_constants.dart';
import 'package:wedly/data/services/api_exceptions.dart';

/// Repository for managing promotional banners
///
/// API Endpoints:
/// - GET /api/banners - Get all active banners (ordered by 'order' field)
/// - GET /api/banners/admin - Get all banners (admin only)
/// - GET /api/banners/:id - Get banner by ID
/// - POST /api/banners - Create new banner (admin only)
/// - PUT /api/banners/:id - Update banner (admin only)
/// - DELETE /api/banners/:id - Delete banner (admin only)
/// - PUT /api/banners/:id/image - Update banner image (admin only)
/// - PATCH /api/banners/:id/toggle-visibility - Toggle banner visibility (admin only)
///
/// Expected Response Format:
/// {
///   "success": true,
///   "data": [
///     {
///       "id": "1",
///       "image_url": "https://example.com/banner1.jpg",
///       "link": "https://example.com/promo", // Optional
///       "title": "Summer Sale",
///       "title_ar": "عروض الصيف",
///       "order": 1,
///       "is_active": true
///     }
///   ]
/// }
class BannerRepository {
  final ApiClient? _apiClient;
  final bool useMockData;

  BannerRepository({ApiClient? apiClient, this.useMockData = true})
      : _apiClient = apiClient;

  /// Mock implementation: Get all active banners
  Future<List<BannerModel>> _mockGetBanners() async {
    await Future.delayed(const Duration(milliseconds: 300));

    final now = DateTime.now();
    return [
      BannerModel(
        id: '1',
        imageUrl: 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=800',
        link: null,
        isActive: true,
        expirationDate: now.add(const Duration(days: 30)),
      ),
      BannerModel(
        id: '2',
        imageUrl: 'https://images.unsplash.com/photo-1606216794074-735e91aa2c92?w=800',
        link: null,
        isActive: true,
        expirationDate: now.add(const Duration(days: 45)),
      ),
      BannerModel(
        id: '3',
        imageUrl: 'https://images.unsplash.com/photo-1511285560929-80b456fea0bc?w=800',
        link: null,
        isActive: true,
        expirationDate: now.add(const Duration(days: 60)),
      ),
    ];
  }

  /// Get all active banners
  /// Public endpoint - no authentication required
  /// Returns only active, non-expired banners
  Future<List<BannerModel>> getBanners() async {
    if (useMockData) {
      return _mockGetBanners();
    }

    try {
      debugPrint('🌐 BannerRepository: Fetching banners from ${ApiConstants.banners}');
      final response = await _apiClient!.get(ApiConstants.banners);

      debugPrint('📦 BannerRepository: Response received');
      debugPrint('📦 Response type: ${response.data.runtimeType}');
      debugPrint('📦 Response data: ${response.data}');

      // API Response format: { "success": true, "message": "...", "data": { "banners": [...] } }
      if (response.data is Map) {
        final data = response.data['data'];
        debugPrint('📦 Data field type: ${data.runtimeType}');
        debugPrint('📦 Data content: $data');

        if (data is Map && data['banners'] is List) {
          final bannersList = (data['banners'] as List)
              .map((json) => BannerModel.fromJson(json))
              .toList();
          debugPrint('✅ BannerRepository: Parsed ${bannersList.length} banners');
          return bannersList;
        } else {
          debugPrint('⚠️ BannerRepository: Data does not contain banners array');
          debugPrint('⚠️ Data keys: ${data is Map ? data.keys : "Not a map"}');
        }
      } else {
        debugPrint('⚠️ BannerRepository: Response is not a Map');
      }

      debugPrint('⚠️ BannerRepository: Returning empty list');
      return [];
    } on ApiException {
      rethrow;
    } catch (e) {
      debugPrint('❌ BannerRepository: Exception: $e');
      throw ApiException(message: 'فشل تحميل العروض: $e');
    }
  }

  /// Get all banners (admin only) - includes inactive banners
  Future<List<BannerModel>> getAllBanners() async {
    if (useMockData) {
      return _mockGetBanners(); // Return same mock data for simplicity
    }

    try {
      debugPrint('🔐 BannerRepository: Fetching ALL banners (admin) from ${ApiConstants.adminBanners}');
      final response = await _apiClient!.get(ApiConstants.adminBanners);

      debugPrint('📦 Admin response: ${response.data}');
      debugPrint('📦 Admin response type: ${response.data.runtimeType}');

      // Same parsing logic as getBanners - might have nested structure
      if (response.data is Map) {
        final data = response.data['data'];
        debugPrint('📦 Admin data field: $data');
        debugPrint('📦 Admin data type: ${data.runtimeType}');

        if (data is Map && data['banners'] is List) {
          final bannersList = (data['banners'] as List)
              .map((json) => BannerModel.fromJson(json))
              .toList();
          debugPrint('✅ Admin endpoint: Found ${bannersList.length} total banners');
          for (var banner in bannersList) {
            debugPrint('  - ID: ${banner.id}, Active: ${banner.isActive}, Expires: ${banner.expirationDate}, Image: ${banner.imageUrl}');
          }
          return bannersList;
        } else if (data is List) {
          // Fallback: data might be directly a list
          final bannersList = data
              .map((json) => BannerModel.fromJson(json))
              .toList();
          debugPrint('✅ Admin endpoint (direct list): Found ${bannersList.length} total banners');
          for (var banner in bannersList) {
            debugPrint('  - ID: ${banner.id}, Active: ${banner.isActive}, Expires: ${banner.expirationDate}, Image: ${banner.imageUrl}');
          }
          return bannersList;
        }
      }

      debugPrint('⚠️ Admin endpoint: Could not parse response, returning empty list');
      return [];
    } on ApiException {
      rethrow;
    } catch (e) {
      debugPrint('❌ Admin endpoint exception: $e');
      throw ApiException(message: 'فشل تحميل جميع العروض: $e');
    }
  }

  /// Get banner by ID
  Future<BannerModel?> getBannerById(String bannerId) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 200));
      final banners = await _mockGetBanners();
      try {
        return banners.firstWhere((b) => b.id == bannerId);
      } catch (e) {
        return null;
      }
    }

    try {
      final response = await _apiClient!.get(ApiConstants.bannerById(bannerId));

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
  /// Returns the created banner
  Future<BannerModel> createBanner({
    required String imageUrl,
    String? link,
    bool isActive = true,
    DateTime? expirationDate,
  }) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      return BannerModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        imageUrl: imageUrl,
        link: link,
        isActive: isActive,
        expirationDate: expirationDate,
      );
    }

    try {
      final response = await _apiClient!.post(
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
  /// Returns the updated banner
  Future<BannerModel> updateBanner({
    required String bannerId,
    String? imageUrl,
    String? link,
    bool? isActive,
    DateTime? expirationDate,
  }) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      final banners = await _mockGetBanners();
      try {
        final existing = banners.firstWhere((b) => b.id == bannerId);
        return existing.copyWith(
          imageUrl: imageUrl,
          link: link,
          isActive: isActive,
          expirationDate: expirationDate,
        );
      } catch (e) {
        throw ApiException(message: 'Banner not found');
      }
    }

    try {
      final response = await _apiClient!.put(
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
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 200));
      return; // Mock deletion
    }

    try {
      await _apiClient!.delete(ApiConstants.deleteBanner(bannerId));
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'فشل حذف العرض: $e');
    }
  }

  /// Update banner image (admin only)
  /// Accepts FormData with image file
  Future<BannerModel> updateBannerImage({
    required String bannerId,
    required FormData formData,
  }) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      final banners = await _mockGetBanners();
      try {
        return banners.firstWhere((b) => b.id == bannerId);
      } catch (e) {
        throw ApiException(message: 'Banner not found');
      }
    }

    try {
      final response = await _apiClient!.put(
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
  /// Switches between active and inactive
  Future<BannerModel> toggleBannerVisibility(String bannerId) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      final banners = await _mockGetBanners();
      try {
        final existing = banners.firstWhere((b) => b.id == bannerId);
        return existing.copyWith(isActive: !existing.isActive);
      } catch (e) {
        throw ApiException(message: 'Banner not found');
      }
    }

    try {
      final response = await _apiClient!.patch(
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
