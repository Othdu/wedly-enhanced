import 'dart:async';
import 'package:wedly/data/models/service_model.dart';
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
    ),
    const ServiceModel(
      id: '2',
      name: 'Catering Services',
      description: 'Delicious catering options for your wedding reception',
      imageUrl: 'https://images.unsplash.com/photo-1556910103-1c02745aae4d?w=400',
      price: 2500.0,
      category: 'Catering',
    ),
    const ServiceModel(
      id: '3',
      name: 'Floral Arrangements',
      description: 'Beautiful floral decorations and bouquets',
      imageUrl: 'https://images.unsplash.com/photo-1462275646964-a0e3386b89fa?w=400',
      price: 800.0,
      category: 'Decoration',
    ),
    const ServiceModel(
      id: '4',
      name: 'DJ & Music',
      description: 'Professional DJ services for your wedding party',
      imageUrl: 'https://images.unsplash.com/photo-1470229722913-7c0f2dbbafb3?w=400',
      price: 1200.0,
      category: 'Entertainment',
    ),
    const ServiceModel(
      id: '5',
      name: 'Venue Booking',
      description: 'Premium wedding venues for your celebration',
      imageUrl: 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=400',
      price: 5000.0,
      category: 'Venue',
    ),
    const ServiceModel(
      id: '6',
      name: 'Makeup & Styling',
      description: 'Professional makeup and hair styling services',
      imageUrl: 'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?w=400',
      price: 600.0,
      category: 'Beauty',
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
    // For mock, return all services. In real implementation, filter by providerId
    return List.from(_mockServices);
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
}

