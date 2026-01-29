import 'dart:io';
import 'package:dio/dio.dart';
import 'package:wedly/data/models/service_model.dart';
import 'package:wedly/data/models/category_model.dart';
import 'package:wedly/data/models/countdown_model.dart';
import 'package:wedly/data/models/offer_model.dart';
import 'package:wedly/data/models/home_layout_model.dart';
import 'package:wedly/data/services/api_client.dart';
import 'package:wedly/data/services/api_constants.dart';

class ServiceRepository {
  final ApiClient _apiClient;

  ServiceRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  // MOCK DATA REMOVED - API ONLY
  // Original mock services data was here (350+ lines removed)

  /// Get all services
  Future<List<ServiceModel>> getServices() async {
    final response = await _apiClient.get(ApiConstants.services);

    if (response.data == null || response.data is! Map) {
      throw Exception('Invalid API response structure for services');
    }

    final responseData = response.data['data'] ?? response.data;
    dynamic servicesData = responseData['services'] ?? responseData;

    if (servicesData is! List) {
      throw Exception('API response is not a list for services');
    }

    return (servicesData as List).map((json) {
      return ServiceModel.fromJson(json as Map<String, dynamic>);
    }).toList();
  }

  /// Get service by ID
  Future<ServiceModel?> getServiceById(String id) async {
    final response = await _apiClient.get(ApiConstants.serviceById(id));
    final responseData = response.data['data'] ?? response.data;
    return ServiceModel.fromJson(responseData['service'] ?? responseData);
  }

  /// Get services by category with filters and pagination
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
    final response = await _apiClient.get(
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

    if (response.data == null || response.data is! Map) {
      throw Exception('Invalid API response structure for category $category');
    }

    final responseData = response.data['data'] ?? response.data;
    dynamic servicesData = responseData['services'] ?? responseData;

    if (servicesData is! List) {
      throw Exception('API response is not a list for category $category');
    }

    final services = (servicesData as List).map((json) {
      return ServiceModel.fromJson(json as Map<String, dynamic>);
    }).toList();

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
  }

  /// Get services by category (legacy method)
  Future<List<ServiceModel>> getServicesByCategory(String category) async {
    final result = await getServicesByCategoryWithFilters(category, limit: 100);
    return result['services'] as List<ServiceModel>;
  }

  /// Get all unique categories
  Future<List<String>> getCategories() async {
    final response = await _apiClient.get(ApiConstants.categories);
    final responseData = response.data['data'] ?? response.data;
    final categories = responseData['categories'] ?? responseData;
    if (categories is List) {
      return categories.map((c) => c['name']?.toString() ?? c.toString()).toList();
    }
    throw Exception('Invalid categories response');
  }

  /// Get all cities
  Future<List<String>> getCities() async {
    final response = await _apiClient.get(ApiConstants.addressCities);
    final responseData = response.data['data'] ?? response.data;
    final cities = responseData['cities'] ?? responseData;
    if (cities is List) {
      return cities.cast<String>();
    }
    throw Exception('Invalid cities response from API');
  }

  /// Get services for a specific provider
  Future<List<ServiceModel>> getProviderServices(String providerId) async {
    final response = await _apiClient.get(ApiConstants.providerServices(providerId));
    final responseData = response.data['data'] ?? response.data;
    final servicesList = responseData['services'] ?? responseData;

    if (servicesList is! List) {
      return [];
    }

    return servicesList.map((json) => ServiceModel.fromJson(json)).toList();
  }

  /// Add a new service (provider only)
  Future<ServiceModel> addService(ServiceModel service) async {
    final response = await _apiClient.post(
      ApiConstants.createService,
      data: service.toJson(),
    );
    final responseData = response.data['data'] ?? response.data;
    return ServiceModel.fromJson(responseData['service'] ?? responseData);
  }

  /// Update an existing service
  Future<ServiceModel> updateService(ServiceModel service) async {
    final response = await _apiClient.put(
      ApiConstants.updateService(service.id),
      data: service.toJson(),
    );
    final responseData = response.data['data'] ?? response.data;
    return ServiceModel.fromJson(responseData['service'] ?? responseData);
  }

  /// Delete a service
  Future<bool> deleteService(String serviceId) async {
    await _apiClient.delete(ApiConstants.serviceById(serviceId));
    return true;
  }

  /// Toggle service active status
  Future<ServiceModel> toggleServiceStatus(String serviceId) async {
    final response = await _apiClient.post(ApiConstants.toggleServiceStatus(serviceId));
    final responseData = response.data['data'] ?? response.data;
    return ServiceModel.fromJson(responseData['service'] ?? responseData);
  }

  /// Get categories with full details
  Future<List<CategoryModel>> getCategoriesWithDetails() async {
    final response = await _apiClient.get(ApiConstants.categories);
    final responseData = response.data['data'] ?? response.data;
    final List<dynamic> data = responseData['categories'] ?? responseData;
    return data.map((json) => CategoryModel.fromJson(json)).toList();
  }

  /// Get user's wedding countdown
  Future<CountdownModel?> getUserCountdown(String userId) async {
    final response = await _apiClient.get(ApiConstants.userCountdown(userId));
    final responseData = response.data['data'] ?? response.data;
    if (responseData != null) {
      return CountdownModel.fromJson(responseData);
    }
    return null;
  }

  /// Get active offers
  Future<List<OfferModel>> getActiveOffers() async {
    final response = await _apiClient.get(ApiConstants.offers);
    final responseData = response.data['data'] ?? response.data;
    final offersList = responseData['offers'] ?? responseData;

    if (offersList is! List) {
      return [];
    }

    return offersList
        .map((json) => OfferModel.fromJson(json))
        .where((offer) => offer.isValid)
        .toList();
  }

  /// Get home layout configuration
  Future<HomeLayoutModel> getHomeLayout(String screenName) async {
    final response = await _apiClient.get(ApiConstants.homeLayout(screenName));
    final responseData = response.data['data'] ?? response.data;
    return HomeLayoutModel.fromJson(responseData);
  }

  /// Get available dates for a service
  /// [month] should be in 'YYYY-MM' format (e.g., '2024-03')
  Future<Map<String, dynamic>> getServiceAvailableDates(
    String serviceId,
    String month, {
    String? timeSlot,
  }) async {
    final response = await _apiClient.get(
      ApiConstants.getServiceAvailableDates(serviceId, month, timeSlot: timeSlot),
    );
    final responseData = response.data['data'] ?? response.data;
    return {
      'availableDates': (responseData['available_dates'] as List?)
              ?.map((d) => DateTime.parse(d.toString()))
              .toList() ??
          [],
      'bookedDates': (responseData['booked_dates'] as List?)
              ?.map((d) => DateTime.parse(d.toString()))
              .toList() ??
          [],
      'morningBookedDates': (responseData['morning_booked_dates'] as List?)
              ?.map((d) => DateTime.parse(d.toString()))
              .toList() ??
          [],
      'eveningBookedDates': (responseData['evening_booked_dates'] as List?)
              ?.map((d) => DateTime.parse(d.toString()))
              .toList() ??
          [],
    };
  }

  /// Create service with images (multipart)
  Future<ServiceModel> createServiceWithImages({
    required ServiceModel service,
    required List<File> images,
  }) async {
    final formData = FormData.fromMap({
      ...service.toJson(),
      'images': await Future.wait(
        images.map((file) => MultipartFile.fromFile(file.path)),
      ),
    });

    final response = await _apiClient.post(
      ApiConstants.createService,
      data: formData,
    );
    final responseData = response.data['data'] ?? response.data;
    return ServiceModel.fromJson(responseData['service'] ?? responseData);
  }

  /// Update service with images
  Future<ServiceModel> updateServiceWithImages({
    required ServiceModel service,
    List<File>? newImages,
    List<String>? deletedImageUrls,
  }) async {
    final Map<String, dynamic> data = service.toJson();

    if (deletedImageUrls != null && deletedImageUrls.isNotEmpty) {
      data['deleted_images'] = deletedImageUrls;
    }

    if (newImages != null && newImages.isNotEmpty) {
      final formData = FormData.fromMap({
        ...data,
        'new_images': await Future.wait(
          newImages.map((file) => MultipartFile.fromFile(file.path)),
        ),
      });

      final response = await _apiClient.put(
        ApiConstants.updateService(service.id),
        data: formData,
      );
      final responseData = response.data['data'] ?? response.data;
      return ServiceModel.fromJson(responseData['service'] ?? responseData);
    } else {
      final response = await _apiClient.put(
        ApiConstants.updateService(service.id),
        data: data,
      );
      final responseData = response.data['data'] ?? response.data;
      return ServiceModel.fromJson(responseData['service'] ?? responseData);
    }
  }

  /// Get service packages
  Future<List<Map<String, dynamic>>> getServicePackages(String serviceId) async {
    final response = await _apiClient.get(ApiConstants.getServicePackages(serviceId));
    final responseData = response.data['data'] ?? response.data;
    final packages = responseData['packages'] ?? responseData;
    if (packages is List) {
      return packages.cast<Map<String, dynamic>>();
    }
    return [];
  }

  /// Get service dynamic sections
  Future<List<Map<String, dynamic>>> getServiceDynamicSections(String serviceId) async {
    final response = await _apiClient.get(ApiConstants.getServiceDynamicSections(serviceId));
    final responseData = response.data['data'] ?? response.data;
    final sections = responseData['sections'] ?? responseData;
    if (sections is List) {
      return sections.cast<Map<String, dynamic>>();
    }
    return [];
  }

  /// Create dynamic section
  Future<Map<String, dynamic>> createDynamicSection(
    String serviceId,
    Map<String, dynamic> sectionData,
  ) async {
    final response = await _apiClient.post(
      ApiConstants.createDynamicSection(serviceId),
      data: sectionData,
    );
    return response.data['data'] ?? response.data;
  }

  /// Delete dynamic section
  Future<bool> deleteDynamicSection({
    required String serviceId,
    required String sectionId,
  }) async {
    await _apiClient.delete(ApiConstants.updateDynamicSection(serviceId, sectionId));
    return true;
  }

  /// Alias for getServiceDynamicSections (for backward compatibility)
  Future<List<Map<String, dynamic>>> getDynamicSections(String serviceId) async {
    return getServiceDynamicSections(serviceId);
  }

  /// Add a dynamic section to a service
  Future<Map<String, dynamic>> addDynamicSection({
    required String serviceId,
    required String sectionName,
    String? description,
    List<Map<String, dynamic>>? options,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.createDynamicSection(serviceId),
      data: {
        'section_name': sectionName,
        'description': description ?? '',
        'options': options ?? [],
      },
    );
    return response.data['data'] ?? response.data;
  }

  /// Add option to a dynamic section
  Future<Map<String, dynamic>> addDynamicSectionOption({
    required String serviceId,
    required String sectionId,
    required String text,
    required double price,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.createSectionOption(serviceId, sectionId),
      data: {
        'text': text,
        'price': price,
      },
    );
    return response.data['data'] ?? response.data;
  }

  /// Update option in a dynamic section
  Future<Map<String, dynamic>> updateSectionOption({
    required String serviceId,
    required String sectionId,
    required String optionId,
    required String text,
    required double price,
  }) async {
    final response = await _apiClient.put(
      ApiConstants.updateSectionOption(serviceId, sectionId, optionId),
      data: {
        'text': text,
        'price': price,
      },
    );
    return response.data['data'] ?? response.data;
  }

  /// Delete option from a dynamic section
  Future<bool> deleteSectionOption({
    required String serviceId,
    required String sectionId,
    required String optionId,
  }) async {
    await _apiClient.delete(
      ApiConstants.deleteSectionOption(serviceId, sectionId, optionId),
    );
    return true;
  }

  /// Update dynamic section
  Future<Map<String, dynamic>> updateDynamicSection({
    required String serviceId,
    required String sectionId,
    String? sectionName,
    String? description,
  }) async {
    final response = await _apiClient.put(
      ApiConstants.updateDynamicSection(serviceId, sectionId),
      data: {
        if (sectionName != null) 'section_name': sectionName,
        if (description != null) 'description': description,
      },
    );
    return response.data['data'] ?? response.data;
  }

  /// Submit an offer for a service
  Future<ServiceModel?> submitServiceOffer({
    required String serviceId,
    required double discountPercentage,
    required DateTime offerExpiryDate,
  }) async {
    final response = await _apiClient.patch(
      ApiConstants.submitServiceOffer(serviceId),
      data: {
        'discount_percentage': discountPercentage,
        'offer_expiry_date': offerExpiryDate.toIso8601String(),
      },
    );
    final responseData = response.data['data'] ?? response.data;
    final serviceData = responseData['service'] ?? responseData;
    return ServiceModel.fromJson(serviceData as Map<String, dynamic>);
  }
}
