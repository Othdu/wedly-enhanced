import 'dart:async';
import 'package:wedly/data/models/address_model.dart';
import 'package:wedly/data/services/api_client.dart';
import 'package:wedly/data/services/api_constants.dart';

class AddressRepository {
  final ApiClient _apiClient;

  AddressRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  // Egyptian cities (static data - not from API)
  static const List<String> _cities = [
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
    'البحر الأحمر',
  ];

  // Districts by city (static data - not from API)
  static const Map<String, List<String>> _districts = {
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

  /// Get list of all Egyptian cities
  Future<List<String>> getCities() async {
    return List.from(_cities);
  }

  /// Get districts for a specific city
  Future<List<String>> getDistricts(String city) async {
    if (_districts.containsKey(city)) {
      return List.from(_districts[city]!);
    }

    // Default districts if city not in list
    return [
      'المنطقة الأولى',
      'المنطقة الثانية',
      'المنطقة الثالثة',
      'المنطقة الرابعة',
      'المنطقة الخامسة',
    ];
  }

  /// Get user's saved address from profile
  Future<AddressModel?> getUserAddress(String userId) async {
    try {
      final response = await _apiClient.get(ApiConstants.userProfile);

      if (response.data == null) {
        return null;
      }

      final userData = response.data['data']?['user'] ??
                      response.data['user'] ??
                      response.data['data'];

      if (userData == null) {
        return null;
      }

      final city = userData['city'];
      final district = userData['district'];
      final buildingNumber = userData['building_number'];

      if (city == null || district == null || buildingNumber == null) {
        return null;
      }

      return AddressModel(
        id: null,
        city: city.toString(),
        district: district.toString(),
        buildingNumber: buildingNumber.toString(),
        isDefault: true,
      );
    } catch (e) {
      if (e.toString().contains('404') || e.toString().contains('not found')) {
        return null;
      }
      rethrow;
    }
  }

  /// Save user's address (update profile)
  Future<AddressModel> saveAddress(String userId, AddressModel address) async {
    final response = await _apiClient.put(
      ApiConstants.updateUserProfile,
      data: {
        'city': address.city,
        'district': address.district,
        'building_number': address.buildingNumber,
      },
    );

    final userData = response.data['data']?['user'] ??
                    response.data['user'] ??
                    response.data['data'];

    return AddressModel(
      id: null,
      city: userData['city']?.toString() ?? address.city,
      district: userData['district']?.toString() ?? address.district,
      buildingNumber: userData['building_number']?.toString() ?? address.buildingNumber,
      isDefault: true,
    );
  }

  /// Update existing address (same as save)
  Future<AddressModel> updateAddress(String userId, AddressModel address) async {
    return saveAddress(userId, address);
  }

  /// Delete address (clear from profile)
  Future<void> deleteAddress(String userId, String addressId) async {
    await _apiClient.put(
      ApiConstants.updateUserProfile,
      data: {
        'city': null,
        'district': null,
        'building_number': null,
      },
    );
  }
}
