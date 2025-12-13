import 'dart:async';
import 'package:wedly/data/models/address_model.dart';
import 'package:wedly/data/services/api_client.dart';
import 'package:wedly/data/services/api_constants.dart';

class AddressRepository {
  final ApiClient? _apiClient;
  final bool useMockData;

  AddressRepository({
    ApiClient? apiClient,
    this.useMockData = true,
  }) : _apiClient = apiClient;

  // API Endpoints:
  // Address is part of user profile, not separate endpoints
  // - GET /api/users/profile - Get user profile (includes city, district, building_number)
  // - PUT /api/users/profile - Update user profile (includes address fields)
  // Note: Cities and districts lists are hardcoded in the app (no API endpoint)

  // Mock Egyptian cities
  final List<String> _mockCities = [
    'القاهرة',
    'الجيزة',
    'الإسكندرية',
    'الشرقية',
    'الدقهلية',
    'البحيرة',
    'الفيوم',
    'الغربية',
    'الإسماعيلية',
    'المنوفية',
    'المنيا',
    'القليوبية',
    'الوادي الجديد',
    'السويس',
    'أسوان',
    'أسيوط',
    'بني سويف',
    'بورسعيد',
    'دمياط',
    'الأقصر',
    'قنا',
    'سوهاج',
    'جنوب سيناء',
    'كفر الشيخ',
    'مطروح',
    'الأقصر',
    'البحر الأحمر',
  ];

  // Mock districts by city (selected major cities)
  final Map<String, List<String>> _mockDistricts = {
    'القاهرة': [
      'المعادي',
      'مدينة نصر',
      'الزمالك',
      'التجمع الخامس',
      'الرحاب',
      'مصر الجديدة',
      'المقطم',
      'حدائق القبة',
      'الدقي',
      'المهندسين',
      'عين شمس',
      'حلوان',
      'مدينة السلام',
      'الشروق',
      'بدر',
    ],
    'الجيزة': [
      'المهندسين',
      'الدقي',
      'العجوزة',
      'الهرم',
      'فيصل',
      '6 أكتوبر',
      'الشيخ زايد',
      'أكتوبر',
      'حدائق الأهرام',
      'العمرانية',
      'البراجيل',
    ],
    'الإسكندرية': [
      'سموحة',
      'المنتزة',
      'سيدي بشر',
      'ميامي',
      'رشدي',
      'سان استيفانو',
      'لوران',
      'كامب شيزار',
      'جليم',
      'محرم بك',
      'سيدي جابر',
      'العصافرة',
    ],
    'الشرقية': [
      'الزقازيق',
      'العاشر من رمضان',
      'بلبيس',
      'فاقوس',
      'منيا القمح',
      'القرين',
      'أبو حماد',
      'أبو كبير',
      'ههيا',
      'ديرب نجم',
    ],
    'الدقهلية': [
      'المنصورة',
      'طلخا',
      'ميت غمر',
      'دكرنس',
      'أجا',
      'منية النصر',
      'السنبلاوين',
      'الجمالية',
      'بني عبيد',
    ],
  };

  // Simulate network delay
  Future<void> _simulateNetworkDelay() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  /// Get list of all Egyptian cities
  Future<List<String>> getCities() async {
    if (useMockData) {
      return _mockGetCities();
    } else {
      return _apiGetCities();
    }
  }

  /// Mock implementation - Get cities
  Future<List<String>> _mockGetCities() async {
    await _simulateNetworkDelay();
    return List.from(_mockCities);
  }

  /// API implementation - Get cities
  /// Note: Cities are hardcoded in the app, no API endpoint
  Future<List<String>> _apiGetCities() async {
    // Cities list is hardcoded, same as mock
    return List.from(_mockCities);
  }

  /// Get districts for a specific city
  Future<List<String>> getDistricts(String city) async {
    if (useMockData) {
      return _mockGetDistricts(city);
    } else {
      return _apiGetDistricts(city);
    }
  }

  /// Mock implementation - Get districts
  Future<List<String>> _mockGetDistricts(String city) async {
    await _simulateNetworkDelay();

    // Return districts for the city if available, otherwise return default list
    if (_mockDistricts.containsKey(city)) {
      return List.from(_mockDistricts[city]!);
    }

    // Default districts if city not in mock data
    return [
      'المنطقة الأولى',
      'المنطقة الثانية',
      'المنطقة الثالثة',
      'المنطقة الرابعة',
      'المنطقة الخامسة',
    ];
  }

  /// API implementation - Get districts
  /// Note: Districts are hardcoded in the app, no API endpoint
  Future<List<String>> _apiGetDistricts(String city) async {
    // Districts list is hardcoded, same as mock
    if (_mockDistricts.containsKey(city)) {
      return List.from(_mockDistricts[city]!);
    }

    // Default districts if city not in mock data
    return [
      'المنطقة الأولى',
      'المنطقة الثانية',
      'المنطقة الثالثة',
      'المنطقة الرابعة',
      'المنطقة الخامسة',
    ];
  }

  /// Get user's saved address
  Future<AddressModel?> getUserAddress(String userId) async {
    if (useMockData) {
      return _mockGetUserAddress(userId);
    } else {
      return _apiGetUserAddress(userId);
    }
  }

  /// Mock implementation - Get user address
  Future<AddressModel?> _mockGetUserAddress(String userId) async {
    await _simulateNetworkDelay();

    // Return mock saved address
    return const AddressModel(
      id: 'address_1',
      city: 'القاهرة',
      district: 'التجمع الخامس',
      buildingNumber: 'عمارة 12 - الدور الثالث',
      isDefault: true,
    );
  }

  /// API implementation - Get user address from profile
  Future<AddressModel?> _apiGetUserAddress(String userId) async {
    try {
      final response = await _apiClient!.get(ApiConstants.userProfile);

      // Handle case where user has no profile data
      if (response.data == null) {
        return null;
      }

      // Extract user data from response
      final userData = response.data['data']?['user'] ??
                      response.data['user'] ??
                      response.data['data'];

      if (userData == null) {
        return null;
      }

      // Check if user has address fields
      final city = userData['city'];
      final district = userData['district'];
      final buildingNumber = userData['building_number'];

      // If no address fields, return null
      if (city == null || district == null || buildingNumber == null) {
        return null;
      }

      // Create AddressModel from profile data
      return AddressModel(
        id: null, // Address doesn't have separate ID in profile
        city: city.toString(),
        district: district.toString(),
        buildingNumber: buildingNumber.toString(),
        isDefault: true,
      );
    } catch (e) {
      // If profile doesn't exist (404), return null instead of throwing
      if (e.toString().contains('404') || e.toString().contains('not found')) {
        return null;
      }
      rethrow;
    }
  }

  /// Save user's address
  Future<AddressModel> saveAddress(String userId, AddressModel address) async {
    if (useMockData) {
      return _mockSaveAddress(userId, address);
    } else {
      return _apiSaveAddress(userId, address);
    }
  }

  /// Mock implementation - Save address
  Future<AddressModel> _mockSaveAddress(String userId, AddressModel address) async {
    await _simulateNetworkDelay();

    // Simulate saving address and returning it with an ID
    final savedAddress = address.copyWith(
      id: 'address_${DateTime.now().millisecondsSinceEpoch}',
      isDefault: true,
    );

    return savedAddress;
  }

  /// API implementation - Save address (update profile)
  Future<AddressModel> _apiSaveAddress(String userId, AddressModel address) async {
    final response = await _apiClient!.put(
      ApiConstants.updateUserProfile,
      data: {
        'city': address.city,
        'district': address.district,
        'building_number': address.buildingNumber,
      },
    );

    // Extract updated user data
    final userData = response.data['data']?['user'] ??
                    response.data['user'] ??
                    response.data['data'];

    // Return the saved address
    return AddressModel(
      id: null,
      city: userData['city']?.toString() ?? address.city,
      district: userData['district']?.toString() ?? address.district,
      buildingNumber: userData['building_number']?.toString() ?? address.buildingNumber,
      isDefault: true,
    );
  }

  /// Update existing address
  Future<AddressModel> updateAddress(String userId, AddressModel address) async {
    if (useMockData) {
      return _mockUpdateAddress(userId, address);
    } else {
      return _apiUpdateAddress(userId, address);
    }
  }

  /// Mock implementation - Update address
  Future<AddressModel> _mockUpdateAddress(String userId, AddressModel address) async {
    await _simulateNetworkDelay();
    return address;
  }

  /// API implementation - Update address (same as save, updates profile)
  Future<AddressModel> _apiUpdateAddress(String userId, AddressModel address) async {
    // Update is the same as save - both use PUT /api/users/profile
    return _apiSaveAddress(userId, address);
  }

  /// Delete address
  Future<void> deleteAddress(String userId, String addressId) async {
    if (useMockData) {
      return _mockDeleteAddress(userId, addressId);
    } else {
      return _apiDeleteAddress(userId, addressId);
    }
  }

  /// Mock implementation - Delete address
  Future<void> _mockDeleteAddress(String userId, String addressId) async {
    await _simulateNetworkDelay();
  }

  /// API implementation - Delete address
  /// Note: Cannot delete address separately, it's part of profile
  /// This clears the address fields in the profile
  Future<void> _apiDeleteAddress(String userId, String addressId) async {
    await _apiClient!.put(
      ApiConstants.updateUserProfile,
      data: {
        'city': null,
        'district': null,
        'building_number': null,
      },
    );
  }
}
