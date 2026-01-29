import 'package:flutter/foundation.dart';
import 'package:wedly/data/models/venue_model.dart';
import 'package:wedly/data/services/api_client.dart';
import 'package:wedly/data/services/api_constants.dart';

/// Repository for managing wedding venues (قاعات أفراح)
class VenueRepository {
  final ApiClient _apiClient;

  VenueRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Fetch all active venues
  Future<List<VenueModel>> getVenues() async {
    try {
      final response = await _apiClient.get(ApiConstants.venues);
      final responseData = response.data['data'] ?? response.data;
      final venuesList = responseData['venues'] ?? responseData;

      if (venuesList is! List) {
        debugPrint('⚠️ VenueRepository: Unexpected response format');
        return [];
      }

      return venuesList
          .map((json) => VenueModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('❌ VenueRepository Error in getVenues: $e');
      rethrow;
    }
  }

  /// Fetch a single venue by ID
  Future<VenueModel?> getVenueById(String id) async {
    try {
      final response = await _apiClient.get(ApiConstants.venueById(id));
      final responseData = response.data['data'] ?? response.data;
      final venueData = responseData['venue'] ?? responseData;
      return VenueModel.fromJson(venueData);
    } catch (e) {
      debugPrint('❌ VenueRepository Error in getVenueById: $e');
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
    try {
      final response = await _apiClient.get(
        ApiConstants.getVenueAvailableDates(venueId, month, timeSlot: timeSlot),
      );
      final responseData = response.data['data'] ?? response.data;
      return {
        'available_dates': responseData['available_dates'] ?? [],
        'booked_dates': responseData['booked_dates'] ?? [],
      };
    } catch (e) {
      debugPrint('❌ VenueRepository Error in getVenueAvailableDates: $e');
      rethrow;
    }
  }
}
