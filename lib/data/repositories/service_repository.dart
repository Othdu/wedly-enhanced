import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:wedly/data/models/service_model.dart';
import 'package:wedly/data/models/category_model.dart';
import 'package:wedly/data/models/countdown_model.dart';
import 'package:wedly/data/models/offer_model.dart';
import 'package:wedly/data/models/home_layout_model.dart';
import 'package:wedly/data/models/widget_config_model.dart';
import 'package:wedly/data/services/api_client.dart';
import 'package:wedly/data/services/api_constants.dart';

class ServiceRepository {
  final ApiClient? _apiClient;
  final bool useMockData;

  // Mock services data - used when useMockData is true
  // NOTE: Categories use IDs to match API format (not names)
  final List<ServiceModel> _mockServices = [
    const ServiceModel(
      id: '1',
      name: 'قاعة روزا - التجمع الخامس',
      description:
          'قاعة أفراح فاخرة بالتجمع الخامس، تتسع لـ 500 شخص مع خدمات متكاملة',
      imageUrl:
          'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=800',
      price: 10000.0,
      category: '2', // Venues category ID
      providerId: 'provider_1',
      rating: 4.8,
      reviewCount: 200,
      chairCount: 500,
      city: 'التجمع الخامس، القاهرة',
    ),
    const ServiceModel(
      id: '2',
      name: 'قاعة ليالي - الشيخ زايد',
      description: 'قاعة أفراح راقية في الشيخ زايد، تصميم عصري وإضاءة مميزة',
      imageUrl:
          'https://images.unsplash.com/photo-1464366400600-7168b8af9bc3?w=800',
      price: 15000.0,
      category: '2', // Venues category ID
      providerId: 'provider_2',
      rating: 4.6,
      reviewCount: 250,
      chairCount: 600,
      city: 'الشيخ زايد، الجيزة',
    ),
    const ServiceModel(
      id: '3',
      name: 'قاعة روتانا - 6 أكتوبر - القاهرة',
      description: 'قاعة أفراح فخمة في 6 أكتوبر مع ديكورات كلاسيكية وخدمة VIP',
      imageUrl:
          'https://images.unsplash.com/photo-1478146896981-b80fe463b330?w=800',
      price: 20000.0,
      category: '2', // Venues category ID
      providerId: 'provider_3',
      rating: 4.5,
      reviewCount: 300,
      chairCount: 700,
      city: '6 أكتوبر، الجيزة',
    ),
    const ServiceModel(
      id: '4',
      name: 'تصوير فوتوغرافي احترافي',
      description: 'تصوير احترافي لحفلات الزفاف مع فريق متخصص وأحدث المعدات',
      imageUrl:
          'https://images.unsplash.com/photo-1606216794074-735e91aa2c92?w=800',
      price: 3000.0,
      category: '1', // Photography category ID
      providerId: 'provider_4',
      rating: 4.9,
      reviewCount: 150,
      hasOffer: true,
      offerApproved: true,
      discountPercentage: 20.0,
    ),
    const ServiceModel(
      id: '5',
      name: 'ديكور وزينة الأفراح',
      description: 'تنسيق وديكور حفلات الزفاف بأحدث التصاميم والألوان',
      imageUrl:
          'https://images.unsplash.com/photo-1478146896981-b80fe463b330?w=800',
      price: 5000.0,
      category: '4', // Decoration category ID
      providerId: 'provider_5',
      rating: 4.7,
      reviewCount: 180,
    ),
    const ServiceModel(
      id: '6',
      name: 'كوافير وميكب للعروسة',
      description: 'خدمات تجميل وميكب احترافية للعروسة في يوم زفافها',
      imageUrl:
          'https://images.unsplash.com/photo-1487412947147-5cebf100ffc2?w=800',
      price: 2500.0,
      category: '5', // Beauty category ID
      providerId: 'provider_6',
      rating: 4.8,
      reviewCount: 120,
      hasOffer: true,
      offerApproved: true,
      discountPercentage: 15.0,
    ),
    const ServiceModel(
      id: '7',
      name: 'BMW 6 Series - سيارة زفاف فاخرة',
      description: 'سيارة BMW 6 Series فاخرة مع سائق محترف وتزيين خاص للزفاف',
      imageUrl:
          'https://images.unsplash.com/photo-1555215695-3004980ad54e?w=800',
      price: 1500.0,
      category: '3', // Cars category ID
      providerId: 'provider_7',
      rating: 4.6,
      reviewCount: 90,
      hasOffer: true,
      offerApproved: true,
      discountPercentage: 25.0,
    ),
    const ServiceModel(
      id: '8',
      name: 'فيديوغراف وتصوير سينمائي',
      description: 'تصوير فيديو احترافي بتقنية سينمائية لحفل زفافك',
      imageUrl:
          'https://images.unsplash.com/photo-1492691527719-9d1e07e534b4?w=800',
      price: 4000.0,
      category: '6', // Entertainment category ID
      providerId: 'provider_8',
      rating: 4.9,
      reviewCount: 160,
    ),
    // Additional Photography services
    const ServiceModel(
      id: '9',
      name: 'استوديو النور للتصوير',
      description: 'تصوير زفاف احترافي مع باقات متنوعة تناسب جميع الميزانيات',
      imageUrl:
          'https://images.unsplash.com/photo-1511285560929-80b456fea0bc?w=800',
      price: 2500.0,
      category: '1', // Photography category ID
      providerId: 'provider_9',
      rating: 4.7,
      reviewCount: 110,
    ),
    const ServiceModel(
      id: '10',
      name: 'عدسة الفن للتصوير',
      description: 'تصوير فني راقي مع فريق متميز وأحدث المعدات العالمية',
      imageUrl:
          'https://images.unsplash.com/photo-1519741497674-611481863552?w=800',
      price: 3500.0,
      category: '1', // Photography category ID
      providerId: 'provider_10',
      rating: 4.8,
      reviewCount: 95,
    ),
    // Additional Decoration services
    const ServiceModel(
      id: '11',
      name: 'ديكورات الأحلام',
      description: 'تصاميم ديكور عصرية وكلاسيكية لحفلات الزفاف الفاخرة',
      imageUrl:
          'https://images.unsplash.com/photo-1464366400600-7168b8af9bc3?w=800',
      price: 6000.0,
      category: '4', // Decoration category ID
      providerId: 'provider_11',
      rating: 4.6,
      reviewCount: 75,
    ),
    const ServiceModel(
      id: '12',
      name: 'زينة القصور',
      description: 'ديكورات فاخرة مع ورود طبيعية وإضاءة رومانسية',
      imageUrl:
          'https://images.unsplash.com/photo-1470229538611-16ba8c7ffbd7?w=800',
      price: 7500.0,
      category: '4', // Decoration category ID
      providerId: 'provider_12',
      rating: 4.9,
      reviewCount: 130,
      hasOffer: true,
      offerApproved: true,
      discountPercentage: 30.0,
    ),
    // Additional Beauty services
    const ServiceModel(
      id: '13',
      name: 'صالون الجمال الملكي',
      description: 'خدمات تجميل شاملة للعروسة مع أمهر المتخصصين',
      imageUrl:
          'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?w=800',
      price: 3000.0,
      category: '5', // Beauty category ID
      providerId: 'provider_13',
      rating: 4.8,
      reviewCount: 140,
    ),
    const ServiceModel(
      id: '14',
      name: 'بيوتي لاونج',
      description: 'ميكب عرائس فخم مع تسريحات شعر عصرية',
      imageUrl:
          'https://images.unsplash.com/photo-1516975080664-ed2fc6a32937?w=800',
      price: 2000.0,
      category: '5', // Beauty category ID
      providerId: 'provider_14',
      rating: 4.5,
      reviewCount: 88,
    ),
    // Additional Cars services
    const ServiceModel(
      id: '15',
      name: 'ليموزين VIP',
      description: 'سيارات ليموزين فاخرة للعرسان مع خدمة راقية',
      imageUrl:
          'https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?w=800',
      price: 2000.0,
      category: '3', // Cars category ID
      providerId: 'provider_15',
      rating: 4.7,
      reviewCount: 65,
    ),
    const ServiceModel(
      id: '16',
      name: 'مرسيدس S-Class - سيارة زفاف كلاسيك',
      description: 'سيارة مرسيدس S-Class كلاسيكية فاخرة مجهزة بالكامل للزفاف',
      imageUrl:
          'https://images.unsplash.com/photo-1618843479313-40f8afb4b4d8?w=800',
      price: 2500.0,
      category: '3', // Cars category ID
      providerId: 'provider_16',
      rating: 4.6,
      reviewCount: 72,
    ),
    // Additional Entertainment (Videography) services
    const ServiceModel(
      id: '17',
      name: 'سينما الأحلام',
      description: 'إنتاج فيديو سينمائي لحفل زفافك بجودة عالية',
      imageUrl:
          'https://images.unsplash.com/photo-1516321497487-e288fb19713f?w=800',
      price: 4500.0,
      category: '6', // Entertainment category ID
      providerId: 'provider_17',
      rating: 4.9,
      reviewCount: 105,
    ),
    const ServiceModel(
      id: '18',
      name: 'فيديو برودكشن',
      description: 'تصوير فيديو احترافي مع مونتاج ومؤثرات خاصة',
      imageUrl:
          'https://images.unsplash.com/photo-1574717024653-61fd2cf4d44d?w=800',
      price: 3500.0,
      category: '6', // Entertainment category ID
      providerId: 'provider_18',
      rating: 4.7,
      reviewCount: 92,
    ),
    // Wedding Organizers services
    const ServiceModel(
      id: '19',
      name: 'منظم أفراح محترف',
      description: 'تنظيم وتنسيق حفلات زفاف كاملة مع إدارة يوم الفرح بالكامل',
      imageUrl:
          'https://images.unsplash.com/photo-1511285560929-80b456fea0bc?w=800',
      price: 9000.0,
      category: '7', // Wedding Organizers category ID
      providerId: 'provider_19',
      rating: 4.9,
      reviewCount: 85,
    ),
    const ServiceModel(
      id: '20',
      name: 'وكالة أحلام الزفاف',
      description: 'تخطيط شامل لحفلات الزفاف مع تنسيق جميع الموردين والخدمات',
      imageUrl:
          'https://images.unsplash.com/photo-1519741497674-611481863552?w=800',
      price: 12000.0,
      category: '7', // Wedding Organizers category ID
      providerId: 'provider_20',
      rating: 5.0,
      reviewCount: 120,
    ),
    const ServiceModel(
      id: '21',
      name: 'استوديو إيفنت للتخطيط',
      description: 'خدمات تخطيط وتنظيم أفراح احترافية مع إشراف كامل على الحدث',
      imageUrl:
          'https://images.unsplash.com/photo-1464366400600-7168b8af9bc3?w=800',
      price: 10000.0,
      category: '7', // Wedding Organizers category ID
      providerId: 'provider_21',
      rating: 4.8,
      reviewCount: 95,
    ),
    // Wedding Dress services
    const ServiceModel(
      id: '23',
      name: 'فستان الخصر العالي',
      description: 'فستان زفاف فاخر بخصر عالي وتصميم عصري مع طرحة مطابقة',
      imageUrl:
          'https://images.unsplash.com/photo-1591604466107-ec97de577aff?w=800',
      price: 5000.0,
      category: '8', // Wedding Dresses category ID
      providerId: 'provider_22',
      rating: 4.9,
      reviewCount: 115,
    ),
    const ServiceModel(
      id: '22',
      name: 'فستان الأميرة الكلاسيكي',
      description:
          'فستان زفاف على طراز الأميرات مع تطريز يدوي فاخر وقصة منفوشة',
      imageUrl:
          'https://images.unsplash.com/photo-1606800052052-a08af7148866?w=800',
      price: 12000.0,
      category: '8', // Wedding Dresses category ID
      providerId: 'provider_23',
      rating: 5.0,
      reviewCount: 142,
    ),
    const ServiceModel(
      id: '24',
      name: 'فستان حورية البحر',
      description: 'فستان زفاف بقصة حورية البحر مع دانتيل فرنسي وتصميم أنيق',
      imageUrl:
          'https://images.unsplash.com/photo-1519741497674-611481863552?w=800',
      price: 8000.0,
      category: '8', // Wedding Dresses category ID
      providerId: 'provider_24',
      rating: 4.8,
      reviewCount: 98,
    ),
    const ServiceModel(
      id: '25',
      name: 'فستان البوهيمي المستقيم',
      description: 'فستان زفاف بستايل بوهيمي مريح مع تفاصيل رومانسية ناعمة',
      imageUrl:
          'https://images.unsplash.com/photo-1465495976277-4387d4b0b4c6?w=800',
      price: 6000.0,
      category: '8', // Wedding Dresses category ID
      providerId: 'provider_25',
      rating: 4.7,
      reviewCount: 87,
    ),
    const ServiceModel(
      id: '26',
      name: 'فستان القصير العصري',
      description: 'فستان زفاف قصير عصري مثالي لحفلات الزفاف الصغيرة والحديثة',
      imageUrl:
          'https://images.unsplash.com/photo-1542042161784-26ab9e041e89?w=800',
      price: 3500.0,
      category: '8', // Wedding Dresses category ID
      providerId: 'provider_26',
      rating: 4.6,
      reviewCount: 73,
    ),
    const ServiceModel(
      id: '27',
      name: 'فستان الفينتدج الكلاسيكي',
      description: 'فستان زفاف فينتدج بأكمام طويلة ودانتيل كلاسيكي أنيق',
      imageUrl:
          'https://images.unsplash.com/photo-1522673607200-164d1b6ce486?w=800',
      price: 7500.0,
      category: '8', // Wedding Dresses category ID
      providerId: 'provider_27',
      rating: 4.9,
      reviewCount: 105,
    ),
  ];

  ServiceRepository({ApiClient? apiClient, this.useMockData = true})
    : _apiClient = apiClient;

  /// Get all services
  Future<List<ServiceModel>> getServices() async {
    if (useMockData) {
      return _mockGetServices();
    } else {
      return _apiGetServices();
    }
  }

  /// Mock implementation: Get all services
  Future<List<ServiceModel>> _mockGetServices() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    return List.from(_mockServices);
  }

  /// API implementation: Get all services
  Future<List<ServiceModel>> _apiGetServices() async {
    try {
      final response = await _apiClient!.get(ApiConstants.services);

      // Validate response data structure
      if (response.data == null || response.data is! Map) {
        print('⚠️ Invalid API response structure for services');
        return _mockGetServices();
      }

      final responseData = response.data['data'] ?? response.data;

      // Ensure we have a valid services array
      dynamic servicesData = responseData['services'] ?? responseData;
      if (servicesData is! List) {
        print('⚠️ API response is not a list for services');
        return _mockGetServices();
      }

      final List<dynamic> data = servicesData;
      final services = data.map((json) {
        try {
          return ServiceModel.fromJson(json as Map<String, dynamic>);
        } catch (e) {
          print('⚠️ Error parsing service JSON: $e');
          return null;
        }
      }).whereType<ServiceModel>().toList(); // Filter out null values

      // Fallback to mock data if API returns empty results
      if (services.isEmpty) {
        print('⚠️ API returned empty services, falling back to mock data');
        return _mockGetServices();
      }

      return services;
    } catch (e) {
      print('! API Error in getServices: $e');
      print('📦 Falling back to mock data');
      return _mockGetServices();
    }
  }

  /// Get service by ID
  Future<ServiceModel?> getServiceById(String id) async {
    if (useMockData) {
      return _mockGetServiceById(id);
    } else {
      return _apiGetServiceById(id);
    }
  }

  /// Mock implementation: Get service by ID
  Future<ServiceModel?> _mockGetServiceById(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      return _mockServices.firstWhere((service) => service.id == id);
    } catch (e) {
      return null;
    }
  }

  /// API implementation: Get service by ID
  Future<ServiceModel?> _apiGetServiceById(String id) async {
    try {
      final response = await _apiClient!.get(
        ApiConstants.serviceById(id),
      );
      final responseData = response.data['data'] ?? response.data;
      return ServiceModel.fromJson(responseData['service'] ?? responseData);
    } catch (e) {
      return null;
    }
  }

  /// Get services by category with optional filters and pagination
  /// Returns a map with 'services', 'pagination', and 'hasMore'
  Future<Map<String, dynamic>> getServicesByCategoryWithFilters(
    String category, {
    String? city,
    double? minPrice,
    double? maxPrice,
    double? rating,
    bool? hasOffer,
    int page = 1,
    int limit = 10,
    String? sort,
  }) async {
    if (useMockData) {
      return _mockGetServicesByCategoryWithFilters(
        category,
        city: city,
        minPrice: minPrice,
        maxPrice: maxPrice,
        rating: rating,
        hasOffer: hasOffer,
        page: page,
        limit: limit,
      );
    } else {
      return _apiGetServicesByCategoryWithFilters(
        category,
        city: city,
        minPrice: minPrice,
        maxPrice: maxPrice,
        rating: rating,
        hasOffer: hasOffer,
        page: page,
        limit: limit,
        sort: sort,
      );
    }
  }

  /// Mock implementation: Get services by category with filters
  Future<Map<String, dynamic>> _mockGetServicesByCategoryWithFilters(
    String category, {
    String? city,
    double? minPrice,
    double? maxPrice,
    double? rating,
    bool? hasOffer,
    int page = 1,
    int limit = 10,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    // Start with category filter
    var filteredServices = _mockServices
        .where((service) => service.category == category)
        .toList();

    // Apply city filter
    if (city != null && city.isNotEmpty) {
      filteredServices = filteredServices
          .where((service) => service.city?.contains(city) ?? false)
          .toList();
    }

    // Apply price filters
    if (minPrice != null) {
      filteredServices = filteredServices
          .where((service) => (service.price ?? 0) >= minPrice)
          .toList();
    }
    if (maxPrice != null) {
      filteredServices = filteredServices
          .where((service) => (service.price ?? double.infinity) <= maxPrice)
          .toList();
    }

    // Apply rating filter
    if (rating != null) {
      filteredServices = filteredServices
          .where((service) => (service.rating ?? 0) >= rating)
          .toList();
    }

    // Apply has_offer filter
    if (hasOffer == true) {
      filteredServices = filteredServices
          .where((service) => service.hasOffer && service.offerApproved)
          .toList();
    }

    // Calculate pagination
    final totalItems = filteredServices.length;
    final totalPages = (totalItems / limit).ceil();
    final startIndex = (page - 1) * limit;
    final endIndex = startIndex + limit;

    // Get paginated results
    final paginatedServices = startIndex < filteredServices.length
        ? filteredServices.sublist(
            startIndex,
            endIndex > filteredServices.length ? filteredServices.length : endIndex,
          )
        : <ServiceModel>[];

    return {
      'services': paginatedServices,
      'pagination': {
        'current_page': page,
        'total_pages': totalPages,
        'total_items': totalItems,
        'items_per_page': limit,
      },
      'hasMore': page < totalPages,
    };
  }

  /// API implementation: Get services by category with filters
  Future<Map<String, dynamic>> _apiGetServicesByCategoryWithFilters(
    String category, {
    String? city,
    double? minPrice,
    double? maxPrice,
    double? rating,
    bool? hasOffer,
    int page = 1,
    int limit = 10,
    String? sort,
  }) async {
    try {
      final response = await _apiClient!.get(
        ApiConstants.servicesWithFilters(
          category: category,
          city: city,
          minPrice: minPrice,
          maxPrice: maxPrice,
          rating: rating,
          hasOffer: hasOffer,
          page: page,
          limit: limit,
          sort: sort,
        ),
      );

      // Validate response data structure
      if (response.data == null || response.data is! Map) {
        print('⚠️ Invalid API response structure for category $category');
        return _mockGetServicesByCategoryWithFilters(category, page: page, limit: limit);
      }

      final responseData = response.data['data'] ?? response.data;

      // Ensure we have a valid services array
      dynamic servicesData = responseData['services'] ?? responseData;
      if (servicesData is! List) {
        print('⚠️ API response is not a list for category $category');
        return _mockGetServicesByCategoryWithFilters(category, page: page, limit: limit);
      }

      final List<dynamic> data = servicesData;
      final services = data.map((json) {
        try {
          return ServiceModel.fromJson(json as Map<String, dynamic>);
        } catch (e) {
          print('⚠️ Error parsing service JSON: $e');
          return null;
        }
      }).whereType<ServiceModel>().toList();

      // Parse pagination info
      final paginationData = responseData['pagination'] as Map<String, dynamic>?;
      final currentPage = paginationData?['current_page'] ?? page;
      final totalPages = paginationData?['total_pages'] ?? 1;
      final totalItems = paginationData?['total_items'] ?? services.length;
      final itemsPerPage = paginationData?['items_per_page'] ?? limit;

      return {
        'services': services,
        'pagination': {
          'current_page': currentPage,
          'total_pages': totalPages,
          'total_items': totalItems,
          'items_per_page': itemsPerPage,
        },
        'hasMore': currentPage < totalPages,
      };
    } catch (e) {
      print('! API Error in getServicesByCategoryWithFilters($category): $e');
      print('📦 Falling back to mock data');
      return _mockGetServicesByCategoryWithFilters(category, page: page, limit: limit);
    }
  }

  /// Get services by category (legacy method for backward compatibility)
  Future<List<ServiceModel>> getServicesByCategory(String category) async {
    final result = await getServicesByCategoryWithFilters(category, limit: 100);
    return result['services'] as List<ServiceModel>;
  }

  /// Get all unique categories
  Future<List<String>> getCategories() async {
    if (useMockData) {
      return _mockGetCategories();
    } else {
      return _apiGetCategories();
    }
  }

  /// Mock implementation: Get categories
  Future<List<String>> _mockGetCategories() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockServices.map((service) => service.category).toSet().toList();
  }

  /// API implementation: Get categories
  Future<List<String>> _apiGetCategories() async {
    // Get all services and extract unique categories
    final services = await getServices();
    return services.map((service) => service.category).toSet().toList();
  }

  /// Get all available cities from the API
  Future<List<String>> getCities() async {
    if (useMockData) {
      return _mockGetCities();
    } else {
      return _apiGetCities();
    }
  }

  /// Mock implementation: Get cities (all 27 Egyptian governorates)
  Future<List<String>> _mockGetCities() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      'القاهرة',
      'الجيزة',
      'الإسكندرية',
      'بورسعيد',
      'السويس',
      'الإسماعيلية',
      'دمياط',
      'الدقهلية',
      'الشرقية',
      'القليوبية',
      'كفر الشيخ',
      'الغربية',
      'المنوفية',
      'البحيرة',
      'مطروح',
      'شمال سيناء',
      'جنوب سيناء',
      'البحر الأحمر',
      'الفيوم',
      'بني سويف',
      'المنيا',
      'أسيوط',
      'سوهاج',
      'قنا',
      'الأقصر',
      'أسوان',
      'الوادي الجديد',
    ];
  }

  /// API implementation: Get cities from addresses endpoint
  Future<List<String>> _apiGetCities() async {
    try {
      final response = await _apiClient!.get(ApiConstants.addressCities);
      final responseData = response.data['data'] ?? response.data;
      final cities = responseData['cities'] ?? responseData;

      if (cities is List) {
        return cities.cast<String>();
      }
      return _mockGetCities();
    } catch (e) {
      print('⚠️ API Error in getCities: $e');
      print('📦 Falling back to mock cities');
      return _mockGetCities();
    }
  }

  /// Get services for a specific provider
  Future<List<ServiceModel>> getProviderServices(String providerId) async {
    if (useMockData) {
      return _mockGetProviderServices(providerId);
    } else {
      return _apiGetProviderServices(providerId);
    }
  }

  /// Mock implementation: Get provider services
  Future<List<ServiceModel>> _mockGetProviderServices(String providerId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Filter services by providerId
    return _mockServices
        .where((service) => service.providerId == providerId)
        .toList();
  }

  /// API implementation: Get provider services
  Future<List<ServiceModel>> _apiGetProviderServices(String providerId) async {
    final response = await _apiClient!.get(
      ApiConstants.providerServices(providerId),
    );
    final responseData = response.data['data'] ?? response.data;
    final List<dynamic> data = responseData['services'] ?? responseData;
    return data.map((json) => ServiceModel.fromJson(json)).toList();
  }

  /// Add a new service (Provider only)
  Future<ServiceModel> addService(ServiceModel service) async {
    if (useMockData) {
      return _mockAddService(service);
    } else {
      return _apiAddService(service);
    }
  }

  /// Mock implementation: Add service
  Future<ServiceModel> _mockAddService(ServiceModel service) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final newService = service.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
    );
    _mockServices.add(newService);
    return newService;
  }

  /// API implementation: Add service with multipart/form-data
  Future<ServiceModel> _apiAddService(ServiceModel service) async {
    // Create FormData with all service fields
    final formData = FormData.fromMap({
      'name': service.name,
      'description': service.description,
      'category': service.category,

      // Add image file if provided
      if (service.imageFile != null)
        'image': await MultipartFile.fromFile(
          service.imageFile!.path,
          filename: service.imageFile!.path.split(Platform.pathSeparator).last,
        ),

      // Optional general price (for non-venue categories)
      if (service.price != null)
        'price': service.price.toString(),

      // Optional venue-specific fields
      if (service.chairCount != null)
        'chair_count': service.chairCount.toString(),
      if (service.city != null)
        'city': service.city,
      if (service.morningPrice != null)
        'morning_price': service.morningPrice.toString(),
      if (service.eveningPrice != null)
        'evening_price': service.eveningPrice.toString(),
      if (service.latitude != null)
        'latitude': service.latitude.toString(),
      if (service.longitude != null)
        'longitude': service.longitude.toString(),
      if (service.address != null)
        'address': service.address,

      'is_active': service.isActive.toString(),

      // Offer fields
      if (service.hasOffer)
        'discount_percentage': service.discountPercentage?.toString() ?? '0',
    });

    final response = await _apiClient!.post(
      ApiConstants.services,
      data: formData,
    );

    final responseData = response.data['data'] ?? response.data;
    return ServiceModel.fromJson(responseData['service'] ?? responseData);
  }

  /// Add dynamic section to a service (Provider only)
  /// Creates a section with options already included in the response
  Future<Map<String, dynamic>> addDynamicSection({
    required String serviceId,
    required String sectionName,
    required String description,
    required List<Map<String, dynamic>> options, // [{text: "...", price: "..."}]
    int? order,
  }) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      return {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'section_name': sectionName,
        'description': description,
        'options': options,
        'order': order ?? 0,
      };
    }

    final response = await _apiClient!.post(
      '/api/services/$serviceId/dynamic-sections',
      data: {
        'section_name': sectionName, // Changed from 'title' to match API
        'description': description,
        'options': options, // Include options in creation
        if (order != null) 'order': order,
      },
    );
    final responseData = response.data['data'] ?? response.data;
    return responseData['section'] ?? responseData;
  }

  /// Get all dynamic sections for a service
  /// Used for non-venue services to get customization options
  Future<List<Map<String, dynamic>>> getDynamicSections(String serviceId) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      // Return empty list in mock mode - real sections created when service is added
      return [];
    }

    try {
      final response = await _apiClient!.get(
        '/api/services/$serviceId/dynamic-sections',
      );
      final responseData = response.data['data'] ?? response.data;
      final sections = responseData['sections'] ?? responseData;

      if (sections is List) {
        return sections.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print('⚠️ Error fetching dynamic sections: $e');
      return [];
    }
  }

  /// Get pricing packages for photographer/videographer services
  Future<List<Map<String, dynamic>>> getServicePackages(String serviceId) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      // Return empty list in mock mode
      return [];
    }

    try {
      final response = await _apiClient!.get(
        '/api/services/$serviceId/packages',
      );
      final responseData = response.data['data'] ?? response.data;
      final packages = responseData['packages'] ?? responseData;

      if (packages is List) {
        return packages.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print('⚠️ Error fetching service packages: $e');
      return [];
    }
  }

  /// Add option to a dynamic section (Provider only)
  Future<Map<String, dynamic>> addDynamicSectionOption({
    required String serviceId,
    required String sectionId,
    required String text,
    required String price,
  }) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 200));
      return {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'text': text,
        'price': price,
      };
    }

    final response = await _apiClient!.post(
      ApiConstants.createSectionOption(serviceId, sectionId),
      data: {
        'text': text,
        'price': price,
      },
    );
    final responseData = response.data['data'] ?? response.data;
    return responseData['option'] ?? responseData;
  }

  /// Update a dynamic section (Provider only)
  Future<Map<String, dynamic>> updateDynamicSection({
    required String serviceId,
    required String sectionId,
    String? sectionName,
    String? description,
  }) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 200));
      return {
        'id': sectionId,
        'section_name': sectionName,
        'description': description,
      };
    }

    final response = await _apiClient!.put(
      ApiConstants.updateDynamicSection(serviceId, sectionId),
      data: {
        if (sectionName != null) 'section_name': sectionName,
        if (description != null) 'description': description,
      },
    );
    final responseData = response.data['data'] ?? response.data;
    return responseData['section'] ?? responseData;
  }

  /// Delete a dynamic section (Provider only)
  Future<void> deleteDynamicSection({
    required String serviceId,
    required String sectionId,
  }) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 200));
      return;
    }

    await _apiClient!.delete(
      ApiConstants.deleteDynamicSection(serviceId, sectionId),
    );
  }

  /// Update a section option (Provider only)
  Future<Map<String, dynamic>> updateSectionOption({
    required String serviceId,
    required String sectionId,
    required String optionId,
    String? text,
    String? price,
  }) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 200));
      return {
        'id': optionId,
        'text': text,
        'price': price,
      };
    }

    final response = await _apiClient!.put(
      ApiConstants.updateSectionOption(serviceId, sectionId, optionId),
      data: {
        if (text != null) 'text': text,
        if (price != null) 'price': price,
      },
    );
    final responseData = response.data['data'] ?? response.data;
    return responseData['option'] ?? responseData;
  }

  /// Delete a section option (Provider only)
  Future<void> deleteSectionOption({
    required String serviceId,
    required String sectionId,
    required String optionId,
  }) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 200));
      return;
    }

    await _apiClient!.delete(
      ApiConstants.deleteSectionOption(serviceId, sectionId, optionId),
    );
  }

  /// Update an existing service (Provider only)
  Future<ServiceModel> updateService(ServiceModel service) async {
    if (useMockData) {
      return _mockUpdateService(service);
    } else {
      return _apiUpdateService(service);
    }
  }

  /// Mock implementation: Update service
  Future<ServiceModel> _mockUpdateService(ServiceModel service) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final index = _mockServices.indexWhere((s) => s.id == service.id);
    if (index != -1) {
      _mockServices[index] = service;
      return service;
    }
    throw Exception('Service not found');
  }

  /// API implementation: Update service
  Future<ServiceModel> _apiUpdateService(ServiceModel service) async {
    // Build JSON with only fields the API accepts per PUT /api/services/{id} spec:
    // name, description, price, morning_price, evening_price, category, chair_count,
    // city, address, latitude, longitude, is_active
    final Map<String, dynamic> updateData = {
      'name': service.name,
      'description': service.description,
      'category': service.category,
      'is_active': service.isActive,
    };

    // Add general price for non-venue services
    if (service.price != null) {
      updateData['price'] = service.price;
    }

    // Add venue-specific pricing fields
    if (service.morningPrice != null) {
      updateData['morning_price'] = service.morningPrice;
    }
    if (service.eveningPrice != null) {
      updateData['evening_price'] = service.eveningPrice;
    }
    if (service.chairCount != null) {
      updateData['chair_count'] = service.chairCount;
    }
    if (service.city != null) {
      updateData['city'] = service.city;
    }
    if (service.address != null) {
      updateData['address'] = service.address;
    }
    if (service.latitude != null) {
      updateData['latitude'] = service.latitude;
    }
    if (service.longitude != null) {
      updateData['longitude'] = service.longitude;
    }

    // Debug: Log the update data being sent
    print('📍 Update service data: $updateData');
    print('📍 Price: ${service.price}, Latitude: ${service.latitude}, Longitude: ${service.longitude}');

    final response = await _apiClient!.put(
      ApiConstants.serviceById(service.id),
      data: updateData,
    );

    // Parse the response - API returns {success, message, data: {service: {...}}}
    // The backend doesn't return all fields, so we use the original service and update only what's returned
    try {
      final serviceData = response.data['data']?['service'];

      if (serviceData != null) {
        // Parse only the fields that the backend returns and merge with original service
        return service.copyWith(
          id: serviceData['id']?.toString() ?? service.id,
          name: serviceData['name'] as String? ?? service.name,
          description: serviceData['description'] as String? ?? service.description,
          imageUrl: serviceData['image_url'] as String? ?? service.imageUrl,
          price: serviceData['price'] != null
              ? (serviceData['price'] as num).toDouble()
              : service.price,
          category: serviceData['category'] as String? ?? service.category,
          isActive: serviceData['is_active'] as bool? ?? service.isActive,
          hasOffer: serviceData['has_offer'] as bool? ?? service.hasOffer,
          offerApproved: serviceData['offer_approved'] as bool? ?? service.offerApproved,
          discountPercentage: serviceData['discount_percentage'] != null
              ? (serviceData['discount_percentage'] as num).toDouble()
              : null,
          rating: serviceData['rating'] != null
              ? (serviceData['rating'] as num).toDouble()
              : service.rating,
          reviewCount: serviceData['review_count'] as int? ?? service.reviewCount,
          chairCount: serviceData['chair_count'] as int? ?? service.chairCount,
          city: serviceData['city'] as String? ?? service.city,
          // Preserve fields that backend doesn't return
          latitude: service.latitude,
          longitude: service.longitude,
          morningPrice: service.morningPrice,
          eveningPrice: service.eveningPrice,
          address: service.address,
          offerExpiryDate: service.offerExpiryDate,
        );
      }
    } catch (parseError) {
      print('⚠️ Error parsing update response: $parseError');
    }

    // Fallback: If parsing fails but API call succeeded, return the original service
    // The update was successful on the backend even if we couldn't parse the response
    return service;
  }

  /// Delete a service (Provider only)
  Future<void> deleteService(String serviceId) async {
    if (useMockData) {
      return _mockDeleteService(serviceId);
    } else {
      return _apiDeleteService(serviceId);
    }
  }

  /// Mock implementation: Delete service
  Future<void> _mockDeleteService(String serviceId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _mockServices.removeWhere((s) => s.id == serviceId);
  }

  /// API implementation: Delete service
  Future<void> _apiDeleteService(String serviceId) async {
    await _apiClient!.delete(ApiConstants.serviceById(serviceId));
  }

  /// Toggle service active status
  Future<ServiceModel> toggleServiceStatus(String serviceId) async {
    if (useMockData) {
      return _mockToggleServiceStatus(serviceId);
    } else {
      return _apiToggleServiceStatus(serviceId);
    }
  }

  /// Mock implementation: Toggle service status
  Future<ServiceModel> _mockToggleServiceStatus(String serviceId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _mockServices.indexWhere((s) => s.id == serviceId);
    if (index != -1) {
      final service = _mockServices[index];
      final updatedService = service.copyWith(isActive: !service.isActive);
      _mockServices[index] = updatedService;
      return updatedService;
    }
    throw Exception('Service not found');
  }

  /// API implementation: Toggle service status
  Future<ServiceModel> _apiToggleServiceStatus(String serviceId) async {
    final response = await _apiClient!.patch(
      ApiConstants.toggleServiceStatus(int.parse(serviceId)),
    );
    return ServiceModel.fromJson(response.data['service'] ?? response.data);
  }

  /// Get all categories with images and service counts
  Future<List<CategoryModel>> getCategoriesWithDetails() async {
    if (useMockData) {
      return _mockGetCategoriesWithDetails();
    } else {
      return _apiGetCategoriesWithDetails();
    }
  }

  /// Mock implementation: Get categories with details
  Future<List<CategoryModel>> _mockGetCategoriesWithDetails() async {
    await Future.delayed(const Duration(milliseconds: 300));

    // Create categories with images from mock data
    final List<CategoryModel> mockCategories = [
      const CategoryModel(
        id: '1',
        name: 'Photography',
        nameAr: 'مصورين',
        imageUrl:
            'https://images.unsplash.com/photo-1606216794074-735e91aa2c92?w=400',
        serviceCount: 1,
      ),
      const CategoryModel(
        id: '2',
        name: 'Venues',
        nameAr: 'قاعات الأفراح',
        imageUrl:
            'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=400',
        serviceCount: 1,
      ),
      const CategoryModel(
        id: '3',
        name: 'Cars',
        nameAr: 'سيارات الزفاف',
        imageUrl:
            'https://images.unsplash.com/photo-1555215695-3004980ad54e?w=400',
        serviceCount: 1,
      ),
      const CategoryModel(
        id: '4',
        name: 'Decoration',
        nameAr: 'ديكور و زينة',
        imageUrl:
            'https://images.unsplash.com/photo-1478146896981-b80fe463b330?w=400',
        serviceCount: 1,
      ),
      const CategoryModel(
        id: '5',
        name: 'Beauty',
        nameAr: 'كوافير وميكب',
        imageUrl:
            'https://images.unsplash.com/photo-1487412947147-5cebf100ffc2?w=400',
        serviceCount: 1,
      ),
      const CategoryModel(
        id: '6',
        name: 'Entertainment',
        nameAr: 'فيديوغراف',
        imageUrl:
            'https://images.unsplash.com/photo-1492691527719-9d1e07e534b4?w=400',
        serviceCount: 1,
      ),
      const CategoryModel(
        id: '7',
        name: 'Wedding Organizers',
        nameAr: 'منظمين الأفراح',
        imageUrl:
            'https://images.unsplash.com/photo-1511285560929-80b456fea0bc?w=400',
        serviceCount: 3,
      ),
      const CategoryModel(
        id: '8',
        name: 'Wedding Dresses',
        nameAr: 'فساتين الزفاف',
        imageUrl:
            'https://images.unsplash.com/photo-1591604466107-ec97de577aff?w=400',
        serviceCount: 6,
      ),
    ];

    return mockCategories;
  }

  /// API implementation: Get categories with details
  Future<List<CategoryModel>> _apiGetCategoriesWithDetails() async {
    try {
      final response = await _apiClient!.get(ApiConstants.categories);
      final responseData = response.data['data'] ?? response.data;
      final List<dynamic> data = responseData['categories'] ?? responseData;
      final categories = data.map((json) => CategoryModel.fromJson(json)).toList();

      // Fallback to mock data if API returns empty results
      if (categories.isEmpty) {
        print('⚠️ API returned empty categories, falling back to mock data');
        return _mockGetCategoriesWithDetails();
      }

      return categories;
    } catch (e) {
      print('⚠️ API Error in getCategoriesWithDetails: $e');
      print('📦 Falling back to mock data');
      return _mockGetCategoriesWithDetails();
    }
  }

  /// Get user's wedding countdown
  Future<CountdownModel?> getUserCountdown(String userId) async {
    if (useMockData) {
      return _mockGetUserCountdown(userId);
    } else {
      return _apiGetUserCountdown(userId);
    }
  }

  /// Mock implementation: Get user countdown
  Future<CountdownModel?> _mockGetUserCountdown(String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    // Return null by default - countdown only shows after user books a venue
    // The API will return the actual countdown when a venue is booked
    return null;
  }

  /// API implementation: Get user countdown
  Future<CountdownModel?> _apiGetUserCountdown(String userId) async {
    try {
      final response = await _apiClient!.get(
        ApiConstants.userCountdown(userId),
      );
      return CountdownModel.fromJson(
        response.data['countdown'] ?? response.data,
      );
    } catch (e) {
      print('⚠️ API Error in getUserCountdown: $e');
      print('📦 Falling back to no countdown (null)');
      return null;
    }
  }

  /// Get active offers
  Future<List<OfferModel>> getActiveOffers() async {
    if (useMockData) {
      return _mockGetActiveOffers();
    } else {
      return _apiGetActiveOffers();
    }
  }

  /// Mock implementation: Get active offers
  Future<List<OfferModel>> _mockGetActiveOffers() async {
    await Future.delayed(const Duration(milliseconds: 300));

    final List<OfferModel> mockOffers = [
      OfferModel(
        id: '1',
        title: '30% Discount on Wedding Venues',
        titleAr: 'خصم %30 على قاعات الأفراح',
        description:
            'احصل على خصم 30% على قاعات الأفراح تحتاجات واقعية بأسعار تناسبك',
        descriptionAr:
            'احصل على خصم 30% على قاعات الأفراح تحتاجات واقعية بأسعار تناسبك',
        imageUrl:
            'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=800',
        discount: 'خصم %30',
        expiryDate: DateTime.now().add(const Duration(days: 30)),
        serviceId: '5',
        providerId: 'provider_1',
        providerName: 'قصور الأفراح الذهبية',
        serviceType: 'venue',
        originalPrice: 50000.0,
        discountedPrice: 35000.0,
        rating: 4.7,
        reviewCount: 150,
      ),
      OfferModel(
        id: '2',
        title: 'Premium Photography Package',
        titleAr: 'باقة التصوير المميزة',
        description: 'باقة تصوير فوتوغرافي احترافية لحفل زفافك',
        descriptionAr: 'باقة تصوير فوتوغرافي احترافية لحفل زفافك',
        imageUrl:
            'https://images.unsplash.com/photo-1606216794074-735e91aa2c92?w=800',
        discount: 'عرض خاص',
        expiryDate: DateTime.now().add(const Duration(days: 45)),
        serviceId: '1',
        providerId: 'provider_2',
        providerName: 'استوديو النور الإبداعي',
        serviceType: 'photography',
        originalPrice: 8000.0,
        discountedPrice: 6000.0,
        rating: 4.9,
        reviewCount: 220,
      ),
      OfferModel(
        id: '3',
        title: 'Complete Wedding Package',
        titleAr: 'باقة زفاف متكاملة',
        description: 'باقة شاملة لجميع احتياجات حفل الزفاف',
        descriptionAr: 'باقة شاملة لجميع احتياجات حفل الزفاف',
        imageUrl:
            'https://images.unsplash.com/photo-1511285560929-80b456fea0bc?w=800',
        discount: 'عرض محدود',
        expiryDate: DateTime.now().add(const Duration(days: 60)),
        providerId: 'provider_3',
        providerName: 'منظمو الأحلام',
        serviceType: 'weddingplanner',
        originalPrice: 30000.0,
        discountedPrice: 22000.0,
        rating: 4.8,
        reviewCount: 180,
      ),
    ];

    return mockOffers;
  }

  /// API implementation: Get active offers
  Future<List<OfferModel>> _apiGetActiveOffers() async {
    final response = await _apiClient!.get(ApiConstants.offers);
    final List<dynamic> data = response.data['offers'] ?? response.data;
    return data.map((json) => OfferModel.fromJson(json)).toList();
  }

  /// Get home layout configuration
  Future<HomeLayoutModel> getHomeLayout({String screenName = 'home'}) async {
    if (useMockData) {
      return _mockGetHomeLayout(screenName);
    } else {
      return _apiGetHomeLayout(screenName);
    }
  }

  /// Mock implementation: Get home layout
  Future<HomeLayoutModel> _mockGetHomeLayout(String screenName) async {
    await Future.delayed(const Duration(milliseconds: 200));

    // Default home screen layout configuration
    return HomeLayoutModel(
      id: '1',
      screenName: screenName,
      widgets: [
        const WidgetConfigModel(
          id: 'countdown_1',
          type: WidgetType.countdown,
          titleAr: 'العد التنازلي للفرح',
          title: 'Wedding Countdown',
          isVisible: true,
          order: 1,
          settings: {
            'showWeeks': true,
            'showDays': true,
            'showHours': true,
            'showSeconds': true,
          },
        ),
        const WidgetConfigModel(
          id: 'offers_1',
          type: WidgetType.offers,
          titleAr: 'عروض الأسبوع',
          title: 'Weekly Offers',
          isVisible: true,
          order: 2,
          settings: {
            'autoplay': true,
            'autoplayDuration': 3000,
            'showIndicators': true,
          },
        ),
        const WidgetConfigModel(
          id: 'categories_1',
          type: WidgetType.categories,
          titleAr: 'الخدمات',
          title: 'Services',
          isVisible: true,
          order: 3,
          settings: {'columns': 2, 'aspectRatio': 1.2, 'spacing': 12.0},
        ),
        const WidgetConfigModel(
          id: 'services_1',
          type: WidgetType.services,
          titleAr: 'خدمات مقترحة',
          title: 'Recommended Services',
          isVisible: false, // Hidden by default
          order: 4,
          settings: {
            'limit': 6,
            'layout': 'grid', // 'grid' or 'list'
          },
        ),
      ],
      globalSettings: const {
        'backgroundColor': '#F5F5F5',
        'primaryColor': '#D4AF37',
        'enablePullToRefresh': true,
      },
    );
  }

  /// API implementation: Get home layout
  Future<HomeLayoutModel> _apiGetHomeLayout(String screenName) async {
    try {
      final response = await _apiClient!.get(ApiConstants.homeLayout(screenName));
      return HomeLayoutModel.fromJson(response.data['layout'] ?? response.data);
    } catch (e) {
      print('⚠️ API Error in getHomeLayout: $e');
      print('📦 Falling back to mock layout');
      return _mockGetHomeLayout(screenName);
    }
  }

  /// Get available and booked dates for a service
  /// [month] is required in YYYY-MM format
  /// [timeSlot] is optional ('morning' or 'evening') to filter by time slot
  /// Returns a map with 'available_dates' and 'booked_dates' arrays
  Future<Map<String, dynamic>> getServiceAvailableDates(
    String serviceId,
    String month, {
    String? timeSlot,
  }) async {
    if (useMockData) {
      return _mockGetServiceAvailableDates(serviceId, month, timeSlot: timeSlot);
    } else {
      return _apiGetServiceAvailableDates(serviceId, month, timeSlot: timeSlot);
    }
  }

  /// Mock implementation: Get service available dates
  Future<Map<String, dynamic>> _mockGetServiceAvailableDates(
    String serviceId,
    String month, {
    String? timeSlot,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // Parse month to generate mock booked dates for that month
    final parts = month.split('-');
    final year = int.parse(parts[0]);
    final monthNum = int.parse(parts[1]);

    // Generate some mock booked dates for the given month
    final bookedDates = <String>[];
    // Add a few booked dates in the month (5th, 12th, 18th, 25th)
    for (final day in [5, 12, 18, 25]) {
      final date = DateTime(year, monthNum, day);
      if (date.month == monthNum) {
        bookedDates.add('${year.toString().padLeft(4, '0')}-${monthNum.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}');
      }
    }

    return {
      'available_dates': [], // Empty means all dates except booked are available
      'booked_dates': bookedDates,
    };
  }

  /// API implementation: Get service available dates
  Future<Map<String, dynamic>> _apiGetServiceAvailableDates(
    String serviceId,
    String month, {
    String? timeSlot,
  }) async {
    try {
      final response = await _apiClient!.get(
        ApiConstants.getServiceAvailableDates(serviceId, month, timeSlot: timeSlot),
      );
      final responseData = response.data['data'] ?? response.data;
      return {
        'available_dates': responseData['available_dates'] ?? [],
        'booked_dates': responseData['booked_dates'] ?? [],
      };
    } catch (e) {
      print('⚠️ API Error in getServiceAvailableDates: $e');
      print('📦 Falling back to mock data');
      return _mockGetServiceAvailableDates(serviceId, month, timeSlot: timeSlot);
    }
  }
}
