import 'package:wedly/data/models/offer_model.dart';
import 'package:wedly/data/services/api_client.dart';
import 'package:wedly/data/services/api_constants.dart';

/// Repository for managing offers data
///
/// Supports both mock data and real API integration
/// Switch between modes using useMockData flag
class OfferRepository {
  final ApiClient? apiClient;
  final bool useMockData;

  OfferRepository({this.apiClient, this.useMockData = true});

  // ==================== PUBLIC METHODS ====================

  /// Get all active offers
  Future<List<OfferModel>> getOffers() async {
    if (useMockData || apiClient == null) {
      return _mockGetOffers();
    }
    return _apiGetOffers();
  }

  /// Get offer by ID
  Future<OfferModel?> getOfferById(String offerId) async {
    if (useMockData || apiClient == null) {
      return _mockGetOfferById(offerId);
    }
    return _apiGetOfferById(offerId);
  }

  /// Get offers by provider
  Future<List<OfferModel>> getOffersByProvider(String providerId) async {
    if (useMockData || apiClient == null) {
      return _mockGetOffersByProvider(providerId);
    }
    return _apiGetOffersByProvider(providerId);
  }

  /// Get offers by service type
  Future<List<OfferModel>> getOffersByServiceType(String serviceType) async {
    if (useMockData || apiClient == null) {
      return _mockGetOffersByServiceType(serviceType);
    }
    // For API mode, get all offers and filter client-side
    final offers = await _apiGetOffers();
    return offers
        .where((offer) => offer.serviceType == serviceType && offer.isValid)
        .toList();
  }

  // ==================== API METHODS ====================

  /// API: Get all active offers
  Future<List<OfferModel>> _apiGetOffers() async {
    try {
      final response = await apiClient!.get(ApiConstants.offers);
      final responseData = response.data['data'] ?? response.data;
      final offersList = responseData['offers'] ?? responseData;

      final offers = (offersList as List)
          .map((json) => OfferModel.fromJson(json))
          .where((offer) => offer.isValid)
          .toList();

      // Fallback to mock data if API returns empty results
      if (offers.isEmpty) {
        print('⚠️ API returned empty offers, falling back to mock data');
        return _mockGetOffers();
      }

      return offers;
    } catch (e) {
      print('⚠️ API Error in getOffers: $e');
      print('📦 Falling back to mock data');
      return _mockGetOffers();
    }
  }

  /// API: Get offer by ID
  Future<OfferModel?> _apiGetOfferById(String offerId) async {
    try {
      final response = await apiClient!.get(ApiConstants.offerById(offerId));
      final responseData = response.data['data'] ?? response.data;
      final offerData = responseData['offer'] ?? responseData;
      return OfferModel.fromJson(offerData);
    } catch (e) {
      return null;
    }
  }

  /// API: Get offers by provider
  Future<List<OfferModel>> _apiGetOffersByProvider(String providerId) async {
    final response = await apiClient!.get(
      ApiConstants.getProviderOffers(providerId),
    );
    final responseData = response.data['data'] ?? response.data;
    final offersList = responseData['offers'] ?? responseData;

    return (offersList as List)
        .map((json) => OfferModel.fromJson(json))
        .where((offer) => offer.isValid)
        .toList();
  }

  // ==================== MOCK METHODS ====================

  /// Mock: Get all active offers
  Future<List<OfferModel>> _mockGetOffers() async {
    await Future.delayed(const Duration(milliseconds: 800));

    // Filter only valid offers
    return _mockOffers.where((offer) => offer.isValid).toList();
  }

  /// Mock: Get offer by ID
  Future<OfferModel?> _mockGetOfferById(String offerId) async {
    await Future.delayed(const Duration(milliseconds: 800));

    try {
      return _mockOffers.firstWhere((offer) => offer.id == offerId);
    } catch (e) {
      return null;
    }
  }

  /// Mock: Get offers by provider
  Future<List<OfferModel>> _mockGetOffersByProvider(String providerId) async {
    await Future.delayed(const Duration(milliseconds: 800));

    return _mockOffers
        .where((offer) => offer.providerId == providerId && offer.isValid)
        .toList();
  }

  /// Mock: Get offers by service type
  Future<List<OfferModel>> _mockGetOffersByServiceType(
    String serviceType,
  ) async {
    await Future.delayed(const Duration(milliseconds: 800));

    return _mockOffers
        .where((offer) => offer.serviceType == serviceType && offer.isValid)
        .toList();
  }

  // ==================== MOCK DATA ====================

  /// Mock offers data
  final List<OfferModel> _mockOffers = [
    OfferModel(
      id: '1',
      title: 'Royal Wedding Hall Decoration',
      titleAr: 'قاعة زفاف – التصميم الملكي',
      description: 'Premium wedding hall decoration with royal design',
      descriptionAr: 'تزيين فاخر لقاعة الزفاف بتصميم ملكي كامل',
      imageUrl:
          'https://images.unsplash.com/photo-1519225421980-715cb0215aed?w=800',
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
      imageUrl:
          'https://images.unsplash.com/photo-1606216794074-735e91aa2c92?w=800',
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
      imageUrl:
          'https://images.unsplash.com/photo-1487412947147-5cebf100ffc2?w=800',
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
      imageUrl:
          'https://images.unsplash.com/photo-1591604466107-ec97de577aff?w=800',
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
      imageUrl:
          'https://images.unsplash.com/photo-1478146896981-b80fe463b330?w=800',
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
      imageUrl:
          'https://images.unsplash.com/photo-1555244162-803834f70033?w=800',
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
}
