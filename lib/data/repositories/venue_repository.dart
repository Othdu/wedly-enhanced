import 'package:flutter/foundation.dart';
import 'package:wedly/data/models/venue_model.dart';
import 'package:wedly/data/services/api_client.dart';
import 'package:wedly/data/services/api_constants.dart';

/// Repository for managing wedding venues (قاعات أفراح)
///
/// Supports both mock data and real API integration
/// Switch between modes using useMockData flag
class VenueRepository {
  final ApiClient? apiClient;
  final bool useMockData;

  VenueRepository({this.apiClient, this.useMockData = true});

  // ==================== PUBLIC METHODS ====================

  /// Fetch all active venues
  Future<List<VenueModel>> getVenues() async {
    if (useMockData || apiClient == null) {
      return _mockGetVenues();
    }
    return _apiGetVenues();
  }

  /// Fetch a single venue by ID
  Future<VenueModel?> getVenueById(String id) async {
    if (useMockData || apiClient == null) {
      return _mockGetVenueById(id);
    }
    return _apiGetVenueById(id);
  }

  // ==================== API METHODS ====================

  /// API: Get all venues
  Future<List<VenueModel>> _apiGetVenues() async {
    final response = await apiClient!.get(ApiConstants.venues);
    final responseData = response.data['data'] ?? response.data;
    final venuesList = responseData['venues'] ?? responseData;

    return (venuesList as List)
        .map((json) => VenueModel.fromJson(json))
        .toList();
  }

  /// API: Get venue by ID
  Future<VenueModel?> _apiGetVenueById(String id) async {
    try {
      final response = await apiClient!.get(ApiConstants.venueById(id));
      final responseData = response.data['data'] ?? response.data;
      final venueData = responseData['venue'] ?? responseData;
      return VenueModel.fromJson(venueData);
    } catch (e) {
      return null;
    }
  }

  /// Get available and booked dates for a venue
  /// [month] is required in YYYY-MM format
  /// [timeSlot] is optional ('morning' or 'evening') to filter by time slot
  /// Returns a map with 'available_dates' and 'booked_dates' arrays
  Future<Map<String, dynamic>> getVenueAvailableDates(
    String venueId,
    String month, {
    String? timeSlot,
  }) async {
    if (useMockData || apiClient == null) {
      return _mockGetVenueAvailableDates(venueId, month, timeSlot: timeSlot);
    }
    return _apiGetVenueAvailableDates(venueId, month, timeSlot: timeSlot);
  }

  /// API: Get venue available dates
  Future<Map<String, dynamic>> _apiGetVenueAvailableDates(
    String venueId,
    String month, {
    String? timeSlot,
  }) async {
    try {
      final response = await apiClient!.get(
        ApiConstants.getVenueAvailableDates(venueId, month, timeSlot: timeSlot),
      );
      final responseData = response.data['data'] ?? response.data;
      return {
        'available_dates': responseData['available_dates'] ?? [],
        'booked_dates': responseData['booked_dates'] ?? [],
      };
    } catch (e) {
      debugPrint('⚠️ API Error in getVenueAvailableDates: $e');
      debugPrint('📦 Falling back to mock data');
      return _mockGetVenueAvailableDates(venueId, month, timeSlot: timeSlot);
    }
  }

  /// Mock: Get venue available dates
  Future<Map<String, dynamic>> _mockGetVenueAvailableDates(
    String venueId,
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

  // ==================== MOCK METHODS ====================

  /// Mock: Get all venues
  Future<List<VenueModel>> _mockGetVenues() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return _mockVenues;
  }

  /// Mock: Get venue by ID
  Future<VenueModel?> _mockGetVenueById(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      return _mockVenues.firstWhere((venue) => venue.id == id);
    } catch (e) {
      return null;
    }
  }

  // ==================== MOCK DATA ====================

  /// Mock data - 4 venues matching the screenshot
  /// These match the examples shown in the UI design
  static final List<VenueModel> _mockVenues = [
    // Venue 1: قاعة نوفا - التجمع الخامس
    const VenueModel(
      id: 'venue_1',
      name: 'قاعة نوفا - التجمع الخامس',
      description:
          'قاعة أفراح فاخرة في قلب التجمع الخامس مع ديكورات كلاسيكية راقية وثريات كريستال',
      imageUrl:
          'https://images.unsplash.com/photo-1519167758481-83f29da1a26a?w=800&h=600&fit=crop',
      imageUrls: [
        'https://images.unsplash.com/photo-1519167758481-83f29da1a26a?w=800&h=600&fit=crop',
        'https://images.unsplash.com/photo-1464366400600-7168b8af9bc3?w=800&h=600&fit=crop',
      ],
      rating: 4.8,
      reviewCount: 127,
      capacity: 200,
      pricePerPerson: 200.0,
      providerId: 'provider_1',
      address: 'التجمع الخامس، القاهرة الجديدة',
      latitude: 30.0131,
      longitude: 31.4318,
      isActive: true,
      isPendingApproval: false,
    ),

    // Venue 2: قاعة إيلات - الشيخ زايد
    const VenueModel(
      id: 'venue_2',
      name: 'قاعة إيلات - الشيخ زايد',
      description:
          'قاعة عصرية بتصميم أنيق مع إضاءة رومانسية وديكورات زهور طبيعية',
      imageUrl:
          'https://images.unsplash.com/photo-1478146896981-b80fe463b330?w=800&h=600&fit=crop',
      imageUrls: [
        'https://images.unsplash.com/photo-1478146896981-b80fe463b330?w=800&h=600&fit=crop',
        'https://images.unsplash.com/photo-1511578314322-379afb476865?w=800&h=600&fit=crop',
      ],
      rating: 4.6,
      reviewCount: 98,
      capacity: 250,
      pricePerPerson: 250.0,
      providerId: 'provider_2',
      address: 'الشيخ زايد، الجيزة',
      latitude: 30.0692,
      longitude: 31.0118,
      isActive: true,
      isPendingApproval: false,
    ),

    // Venue 3: قاعة روفاتا - 6 أكتوبر
    const VenueModel(
      id: 'venue_3',
      name: 'قاعة روفاتا - 6 أكتوبر',
      description: 'قاعة مودرن بإطلالة ساحرة مع كوش مميز وديكورات ذهبية فاخرة',
      imageUrl:
          'https://images.unsplash.com/photo-1470229538611-16ba8c7ffbd7?w=800&h=600&fit=crop',
      imageUrls: [
        'https://images.unsplash.com/photo-1470229538611-16ba8c7ffbd7?w=800&h=600&fit=crop',
        'https://images.unsplash.com/photo-1465495976277-4387d4b0b4c6?w=800&h=600&fit=crop',
      ],
      rating: 4.5,
      reviewCount: 84,
      capacity: 300,
      pricePerPerson: 300.0,
      providerId: 'provider_3',
      address: '6 أكتوبر، الجيزة',
      latitude: 29.9622,
      longitude: 30.9199,
      isActive: true,
      isPendingApproval: false,
    ),

    // Venue 4: قاعة قلبي الشرطة - مدينة نصر
    const VenueModel(
      id: 'venue_4',
      name: 'قاعة قلبي الشرطة - مدينة نصر',
      description: 'قاعة كلاسيكية فخمة مع ديكورات أوروبية راقية وإضاءة مميزة',
      imageUrl:
          'https://images.unsplash.com/photo-1505236858219-8359eb29e329?w=800&h=600&fit=crop',
      imageUrls: [
        'https://images.unsplash.com/photo-1505236858219-8359eb29e329?w=800&h=600&fit=crop',
        'https://images.unsplash.com/photo-1464366400600-7168b8af9bc3?w=800&h=600&fit=crop',
      ],
      rating: 4.9,
      reviewCount: 156,
      capacity: 400,
      pricePerPerson: 400.0,
      providerId: 'provider_4',
      address: 'مدينة نصر، القاهرة',
      latitude: 30.0444,
      longitude: 31.3486,
      isActive: true,
      isPendingApproval: false,
    ),
  ];
}
