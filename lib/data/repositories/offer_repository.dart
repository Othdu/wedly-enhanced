import 'package:wedly/data/models/offer_model.dart';

/// Repository for managing offers data
/// TODO: API Integration - Replace mock data with real API calls
///
/// Required API Endpoints:
/// - GET /api/offers - Get all active offers
/// - GET /api/offers/:id - Get offer by ID
/// - GET /api/offers/provider/:providerId - Get offers by provider
///
/// Expected Response Format:
/// {
///   "success": true,
///   "data": [
///     {
///       "id": "1",
///       "title": "Wedding Hall Decoration",
///       "title_ar": "قاعة زفاف – التصميم الملكي",
///       "description": "Premium wedding hall decoration",
///       "description_ar": "تزيين فاخر لقاعة الزفاف بتصميم ملكي كامل",
///       "image_url": "https://example.com/image.jpg",
///       "discount": "-50%",
///       "expiry_date": "2025-12-31T23:59:59Z",
///       "service_id": "service_1",
///       "provider_id": "provider_1",
///       "provider_name": "استوديو الأحلام",
///       "service_type": "decoration",
///       "original_price": 14000.0,
///       "discounted_price": 7000.0,
///       "rating": 4.8,
///       "review_count": 200
///     }
///   ]
/// }
class OfferRepository {
  /// Simulated network delay
  static const _networkDelay = Duration(milliseconds: 800);

  /// Mock offers data
  /// TODO: Replace with API call: GET /api/offers
  final List<OfferModel> _mockOffers = [
    OfferModel(
      id: '1',
      title: 'Royal Wedding Hall Decoration',
      titleAr: 'قاعة زفاف – التصميم الملكي',
      description: 'Premium wedding hall decoration with royal design',
      descriptionAr: 'تزيين فاخر لقاعة الزفاف بتصميم ملكي كامل',
      imageUrl: 'https://images.unsplash.com/photo-1519225421980-715cb0215aed?w=800',
      discount: '-50%',
      expiryDate: DateTime.now().add(const Duration(days: 30)),
      providerId: 'provider_1',
      providerName: 'استوديو الأحلام',
      serviceType: 'decoration',
      originalPrice: 14000.0,
      discountedPrice: 7000.0,
      rating: 4.8,
      reviewCount: 200,
    ),
    OfferModel(
      id: '2',
      title: 'Professional Wedding Photography',
      titleAr: 'تصوير احترافي – باقة الذهبية',
      description: 'Premium photography package with golden package',
      descriptionAr: 'باقة التصوير الذهبية الشاملة مع فيديو سينمائي',
      imageUrl: 'https://images.unsplash.com/photo-1606216794074-735e91aa2c92?w=800',
      discount: '-30%',
      expiryDate: DateTime.now().add(const Duration(days: 45)),
      providerId: 'provider_2',
      providerName: 'عدسة الإبداع',
      serviceType: 'photography',
      originalPrice: 10000.0,
      discountedPrice: 7000.0,
      rating: 4.9,
      reviewCount: 350,
    ),
    OfferModel(
      id: '3',
      title: 'Bridal Makeup & Hair',
      titleAr: 'مكياج العروس – باقة كاملة',
      description: 'Complete bridal makeup package',
      descriptionAr: 'باقة مكياج وتسريحة العروس الشاملة مع البروفة',
      imageUrl: 'https://images.unsplash.com/photo-1487412947147-5cebf100ffc2?w=800',
      discount: '-40%',
      expiryDate: DateTime.now().add(const Duration(days: 60)),
      providerId: 'provider_3',
      providerName: 'صالون الجمال الراقي',
      serviceType: 'beauty',
      originalPrice: 5000.0,
      discountedPrice: 3000.0,
      rating: 4.7,
      reviewCount: 180,
    ),
    OfferModel(
      id: '4',
      title: 'Premium Wedding Dress',
      titleAr: 'فستان زفاف – تصميم أوروبي',
      description: 'European designer wedding dress',
      descriptionAr: 'فستان زفاف بتصميم أوروبي فاخر مع الإكسسوارات',
      imageUrl: 'https://images.unsplash.com/photo-1591604466107-ec97de577aff?w=800',
      discount: '-35%',
      expiryDate: DateTime.now().add(const Duration(days: 90)),
      providerId: 'provider_4',
      providerName: 'بوتيك الأميرات',
      serviceType: 'wedding_dress',
      originalPrice: 15000.0,
      discountedPrice: 9750.0,
      rating: 4.9,
      reviewCount: 240,
    ),
    OfferModel(
      id: '5',
      title: 'Wedding Planning Package',
      titleAr: 'تنظيم حفل زفاف – باقة شاملة',
      description: 'Complete wedding planning package',
      descriptionAr: 'تنظيم كامل لحفل الزفاف من الألف إلى الياء',
      imageUrl: 'https://images.unsplash.com/photo-1478146896981-b80fe463b330?w=800',
      discount: '-25%',
      expiryDate: DateTime.now().add(const Duration(days: 120)),
      providerId: 'provider_5',
      providerName: 'منظمو الأحلام',
      serviceType: 'weddingplanner',
      originalPrice: 20000.0,
      discountedPrice: 15000.0,
      rating: 4.8,
      reviewCount: 150,
    ),
    OfferModel(
      id: '6',
      title: 'Wedding Catering Package',
      titleAr: 'بوفيه زفاف – الباقة الملكية',
      description: 'Royal buffet package for weddings',
      descriptionAr: 'بوفيه مفتوح فاخر مع خدمة 5 نجوم',
      imageUrl: 'https://images.unsplash.com/photo-1555244162-803834f70033?w=800',
      discount: '-20%',
      expiryDate: DateTime.now().add(const Duration(days: 30)),
      providerId: 'provider_6',
      providerName: 'مطاعم الفخامة',
      serviceType: 'catering',
      originalPrice: 25000.0,
      discountedPrice: 20000.0,
      rating: 4.6,
      reviewCount: 120,
    ),
  ];

  /// Get all active offers
  /// TODO: Replace with API call: GET /api/offers
  Future<List<OfferModel>> getOffers() async {
    await Future.delayed(_networkDelay);

    // Filter only valid offers
    return _mockOffers.where((offer) => offer.isValid).toList();
  }

  /// Get offer by ID
  /// TODO: Replace with API call: GET /api/offers/:id
  Future<OfferModel?> getOfferById(String offerId) async {
    await Future.delayed(_networkDelay);

    try {
      return _mockOffers.firstWhere((offer) => offer.id == offerId);
    } catch (e) {
      return null;
    }
  }

  /// Get offers by provider
  /// TODO: Replace with API call: GET /api/offers/provider/:providerId
  Future<List<OfferModel>> getOffersByProvider(String providerId) async {
    await Future.delayed(_networkDelay);

    return _mockOffers
        .where((offer) => offer.providerId == providerId && offer.isValid)
        .toList();
  }

  /// Get offers by service type
  /// TODO: Replace with API call: GET /api/offers?service_type=:serviceType
  Future<List<OfferModel>> getOffersByServiceType(String serviceType) async {
    await Future.delayed(_networkDelay);

    return _mockOffers
        .where((offer) => offer.serviceType == serviceType && offer.isValid)
        .toList();
  }
}
