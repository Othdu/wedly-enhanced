import 'dart:async';
import 'package:wedly/data/models/address_model.dart';

class AddressRepository {
  // TODO: API - Replace mock data with real API calls
  // Endpoints:
  // - GET /api/addresses/cities - Get list of Egyptian cities
  // - GET /api/addresses/districts?city={city} - Get districts for a city
  // - GET /api/user/address - Get user's saved address
  // - POST /api/user/address - Save user's address

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
    await _simulateNetworkDelay();
    return List.from(_mockCities);
  }

  /// Get districts for a specific city
  Future<List<String>> getDistricts(String city) async {
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

  /// Get user's saved address
  Future<AddressModel?> getUserAddress(String userId) async {
    await _simulateNetworkDelay();

    // Return mock saved address
    // TODO: API - Replace with actual API call to get user's address
    return const AddressModel(
      id: 'address_1',
      city: 'القاهرة',
      district: 'التجمع الخامس',
      buildingNumber: 'عمارة 12 - الدور الثالث',
      isDefault: true,
    );
  }

  /// Save user's address
  Future<AddressModel> saveAddress(String userId, AddressModel address) async {
    await _simulateNetworkDelay();

    // Simulate saving address and returning it with an ID
    // TODO: API - Replace with actual API call to save address
    final savedAddress = address.copyWith(
      id: 'address_${DateTime.now().millisecondsSinceEpoch}',
      isDefault: true,
    );

    return savedAddress;
  }

  /// Update existing address
  Future<AddressModel> updateAddress(String userId, AddressModel address) async {
    await _simulateNetworkDelay();

    // Simulate updating address
    // TODO: API - Replace with actual API call to update address
    return address;
  }

  /// Delete address
  Future<void> deleteAddress(String userId, String addressId) async {
    await _simulateNetworkDelay();

    // Simulate deleting address
    // TODO: API - Replace with actual API call to delete address
  }
}
