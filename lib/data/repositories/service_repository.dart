import 'dart:async';
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
  final List<ServiceModel> _mockServices = [
    const ServiceModel(
      id: '1',
      name: 'Wedding Photography',
      description: 'Professional wedding photography services to capture your special day',
      imageUrl: 'https://images.unsplash.com/photo-1519741497674-611481863552?w=400',
      price: 1500.0,
      category: 'Photography',
      providerId: 'provider_1',
      rating: 4.8,
      reviewCount: 24,
    ),
    const ServiceModel(
      id: '2',
      name: 'Catering Services',
      description: 'Delicious catering options for your wedding reception',
      imageUrl: 'https://images.unsplash.com/photo-1556910103-1c02745aae4d?w=400',
      price: 2500.0,
      category: 'Catering',
      providerId: 'provider_1',
      rating: 4.9,
      reviewCount: 35,
    ),
    const ServiceModel(
      id: '3',
      name: 'Floral Arrangements',
      description: 'Beautiful floral decorations and bouquets',
      imageUrl: 'https://images.unsplash.com/photo-1462275646964-a0e3386b89fa?w=400',
      price: 800.0,
      category: 'Decoration',
      providerId: 'provider_2',
      rating: 4.7,
      reviewCount: 18,
    ),
    const ServiceModel(
      id: '4',
      name: 'DJ & Music',
      description: 'Professional DJ services for your wedding party',
      imageUrl: 'https://images.unsplash.com/photo-1470229722913-7c0f2dbbafb3?w=400',
      price: 1200.0,
      category: 'Entertainment',
      providerId: 'provider_2',
      rating: 4.6,
      reviewCount: 12,
    ),
    const ServiceModel(
      id: '5',
      name: 'Venue Booking',
      description: 'Premium wedding venues for your celebration',
      imageUrl: 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=400',
      price: 5000.0,
      category: 'Venue',
      providerId: 'provider_3',
      rating: 4.9,
      reviewCount: 42,
    ),
    const ServiceModel(
      id: '6',
      name: 'Makeup & Styling',
      description: 'Professional makeup and hair styling services',
      imageUrl: 'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?w=400',
      price: 600.0,
      category: 'Beauty',
      providerId: 'provider_3',
      rating: 4.8,
      reviewCount: 29,
    ),
  ];

  ServiceRepository({
    ApiClient? apiClient,
    this.useMockData = true,
  }) : _apiClient = apiClient;

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
    final response = await _apiClient!.get(ApiConstants.services);
    final List<dynamic> data = response.data['services'] ?? response.data;
    return data.map((json) => ServiceModel.fromJson(json)).toList();
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
      final response = await _apiClient!.get(ApiConstants.serviceById(int.parse(id)));
      return ServiceModel.fromJson(response.data['service'] ?? response.data);
    } catch (e) {
      return null;
    }
  }

  /// Get services by category
  Future<List<ServiceModel>> getServicesByCategory(String category) async {
    if (useMockData) {
      return _mockGetServicesByCategory(category);
    } else {
      return _apiGetServicesByCategory(category);
    }
  }

  /// Mock implementation: Get services by category
  Future<List<ServiceModel>> _mockGetServicesByCategory(String category) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockServices
        .where((service) => service.category == category)
        .toList();
  }

  /// API implementation: Get services by category
  Future<List<ServiceModel>> _apiGetServicesByCategory(String category) async {
    final response = await _apiClient!.get(ApiConstants.servicesByCategory(category));
    final List<dynamic> data = response.data['services'] ?? response.data;
    return data.map((json) => ServiceModel.fromJson(json)).toList();
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
    final response = await _apiClient!.get(ApiConstants.providerServices(providerId));
    final List<dynamic> data = response.data['services'] ?? response.data;
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

  /// API implementation: Add service
  Future<ServiceModel> _apiAddService(ServiceModel service) async {
    final response = await _apiClient!.post(
      ApiConstants.services,
      data: service.toJson(),
    );
    return ServiceModel.fromJson(response.data['service'] ?? response.data);
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
    final response = await _apiClient!.put(
      ApiConstants.serviceById(int.parse(service.id)),
      data: service.toJson(),
    );
    return ServiceModel.fromJson(response.data['service'] ?? response.data);
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
    await _apiClient!.delete(ApiConstants.serviceById(int.parse(serviceId)));
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
        imageUrl: 'https://images.unsplash.com/photo-1606216794074-735e91aa2c92?w=400',
        serviceCount: 1,
      ),
      const CategoryModel(
        id: '2',
        name: 'Venues',
        nameAr: 'قاعات الأفراح',
        imageUrl: 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=400',
        serviceCount: 1,
      ),
      const CategoryModel(
        id: '3',
        name: 'Catering',
        nameAr: 'سيارات الزفاف',
        imageUrl: 'https://images.unsplash.com/photo-1583394838336-acd977736f90?w=400',
        serviceCount: 1,
      ),
      const CategoryModel(
        id: '4',
        name: 'Decoration',
        nameAr: 'ديكور و زينة',
        imageUrl: 'https://images.unsplash.com/photo-1478146896981-b80fe463b330?w=400',
        serviceCount: 1,
      ),
      const CategoryModel(
        id: '5',
        name: 'Beauty',
        nameAr: 'كوافير وميكب',
        imageUrl: 'https://images.unsplash.com/photo-1487412947147-5cebf100ffc2?w=400',
        serviceCount: 1,
      ),
      const CategoryModel(
        id: '6',
        name: 'Entertainment',
        nameAr: 'فيديوغراف',
        imageUrl: 'https://images.unsplash.com/photo-1492691527719-9d1e07e534b4?w=400',
        serviceCount: 1,
      ),
      const CategoryModel(
        id: '7',
        name: 'Wedding Organizers',
        nameAr: 'منظمين الأفراح',
        imageUrl: 'https://images.unsplash.com/photo-1511285560929-80b456fea0bc?w=400',
        serviceCount: 0,
      ),
      const CategoryModel(
        id: '8',
        name: 'Wedding Dresses',
        nameAr: 'فساتين الزفاف',
        imageUrl: 'https://images.unsplash.com/photo-1594552072238-122d05fe1882?w=400',
        serviceCount: 0,
      ),
    ];

    return mockCategories;
  }

  /// API implementation: Get categories with details
  Future<List<CategoryModel>> _apiGetCategoriesWithDetails() async {
    final response = await _apiClient!.get(ApiConstants.categories);
    final List<dynamic> data = response.data['categories'] ?? response.data;
    return data.map((json) => CategoryModel.fromJson(json)).toList();
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

    // Return a mock countdown (6 months from now)
    return CountdownModel(
      userId: userId,
      weddingDate: DateTime.now().add(const Duration(days: 175)),
      titleAr: 'العد التنازلي للفرح',
      title: 'Wedding Countdown',
    );
  }

  /// API implementation: Get user countdown
  Future<CountdownModel?> _apiGetUserCountdown(String userId) async {
    try {
      final response = await _apiClient!.get(ApiConstants.userCountdown(userId));
      return CountdownModel.fromJson(response.data['countdown'] ?? response.data);
    } catch (e) {
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
        description: 'احصل على خصم 30% على قاعات الأفراح تحتاجات واقعية بأسعار تناسبك',
        descriptionAr: 'احصل على خصم 30% على قاعات الأفراح تحتاجات واقعية بأسعار تناسبك',
        imageUrl: 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=800',
        discount: 'خصم %30',
        expiryDate: DateTime.now().add(const Duration(days: 30)),
        serviceId: '5',
      ),
      OfferModel(
        id: '2',
        title: 'Premium Photography Package',
        titleAr: 'باقة التصوير المميزة',
        description: 'باقة تصوير فوتوغرافي احترافية لحفل زفافك',
        descriptionAr: 'باقة تصوير فوتوغرافي احترافية لحفل زفافك',
        imageUrl: 'https://images.unsplash.com/photo-1606216794074-735e91aa2c92?w=800',
        discount: 'عرض خاص',
        expiryDate: DateTime.now().add(const Duration(days: 45)),
        serviceId: '1',
      ),
      OfferModel(
        id: '3',
        title: 'Complete Wedding Package',
        titleAr: 'باقة زفاف متكاملة',
        description: 'باقة شاملة لجميع احتياجات حفل الزفاف',
        descriptionAr: 'باقة شاملة لجميع احتياجات حفل الزفاف',
        imageUrl: 'https://images.unsplash.com/photo-1511285560929-80b456fea0bc?w=800',
        discount: 'عرض محدود',
        expiryDate: DateTime.now().add(const Duration(days: 60)),
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
          settings: {
            'columns': 2,
            'aspectRatio': 1.2,
            'spacing': 12.0,
          },
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
    final response = await _apiClient!.get(ApiConstants.homeLayout(screenName));
    return HomeLayoutModel.fromJson(response.data['layout'] ?? response.data);
  }
}

