import 'package:wedly/data/models/banner_model.dart';

/// Repository for managing promotional banners
/// TODO: API Integration - Replace mock data with real API calls
///
/// Required API Endpoints:
/// - GET /api/banners - Get all active banners (ordered by 'order' field)
/// - GET /api/banners/:id - Get banner by ID
/// - POST /api/admin/banners - Create new banner (admin only)
/// - PUT /api/admin/banners/:id - Update banner (admin only)
/// - DELETE /api/admin/banners/:id - Delete banner (admin only)
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
  /// Simulated network delay
  static const _networkDelay = Duration(milliseconds: 600);

  /// Mock banners data
  /// TODO: Replace with API call: GET /api/banners
  /// NOTE: These are placeholder links - admin will provide real links via dashboard
  final List<BannerModel> _mockBanners = [
    BannerModel(
      id: '1',
      imageUrl: 'https://images.unsplash.com/photo-1519225421980-715cb0215aed?w=1200&h=400&fit=crop',
      link: null, // Admin will add real link
      titleAr: 'عروض حفلات الشتاء',
      title: 'Winter Wedding Packages',
      order: 1,
      isActive: true,
    ),
    BannerModel(
      id: '2',
      imageUrl: 'https://images.unsplash.com/photo-1606216794074-735e91aa2c92?w=1200&h=400&fit=crop',
      link: 'https://youtu.be/iFKXqPz3rCY?si=GScmOi81UuCN9l32', // Admin will add real link
      titleAr: 'خصم 40% على التصوير',
      title: '40% Off Photography',
      order: 2,
      isActive: true,
    ),
    BannerModel(
      id: '3',
      imageUrl: 'https://images.unsplash.com/photo-1591604466107-ec97de577aff?w=1200&h=400&fit=crop',
      link: "https://www.instagram.com/", // No link - just promotional image
      titleAr: 'أحدث تصاميم فساتين الزفاف',
      title: 'New Wedding Dress Collection',
      order: 3,
      isActive: true,
    ),
    BannerModel(
      id: '4',
      imageUrl: 'https://images.unsplash.com/photo-1478146896981-b80fe463b330?w=1200&h=400&fit=crop',
      link: null, // Admin will add real link
      titleAr: 'احجز القاعة واحصل على خصم 20%',
      title: 'Book Venue & Get 20% Off',
      order: 4,
      isActive: true,
    ),
  ];

  /// Get all active banners, sorted by order
  /// TODO: Replace with API call: GET /api/banners
  Future<List<BannerModel>> getBanners() async {
    await Future.delayed(_networkDelay);

    // Filter only active banners and sort by order
    final activeBanners = _mockBanners
        .where((banner) => banner.isActive)
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));

    return activeBanners;
  }

  /// Get banner by ID
  /// TODO: Replace with API call: GET /api/banners/:id
  Future<BannerModel?> getBannerById(String bannerId) async {
    await Future.delayed(_networkDelay);

    try {
      return _mockBanners.firstWhere((banner) => banner.id == bannerId);
    } catch (e) {
      return null;
    }
  }

  /// Create new banner (admin only)
  /// TODO: Replace with API call: POST /api/admin/banners
  Future<bool> createBanner(BannerModel banner) async {
    await Future.delayed(_networkDelay);

    // Mock implementation - just add to list
    _mockBanners.add(banner);
    return true;
  }

  /// Update existing banner (admin only)
  /// TODO: Replace with API call: PUT /api/admin/banners/:id
  Future<bool> updateBanner(BannerModel banner) async {
    await Future.delayed(_networkDelay);

    // Mock implementation - find and replace
    final index = _mockBanners.indexWhere((b) => b.id == banner.id);
    if (index != -1) {
      _mockBanners[index] = banner;
      return true;
    }
    return false;
  }

  /// Delete banner (admin only)
  /// TODO: Replace with API call: DELETE /api/admin/banners/:id
  Future<bool> deleteBanner(String bannerId) async {
    await Future.delayed(_networkDelay);

    // Mock implementation - remove from list
    _mockBanners.removeWhere((banner) => banner.id == bannerId);
    return true;
  }
}
