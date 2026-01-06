import 'package:flutter/foundation.dart';
import 'package:wedly/data/models/offer_model.dart';
import 'package:wedly/data/services/api_client.dart';
import 'package:wedly/data/services/api_constants.dart';

/// Repository for managing offers data
///
/// Fetches offers from real API only - no mock data fallback
class OfferRepository {
  final ApiClient? apiClient;

  OfferRepository({this.apiClient});

  // ==================== PUBLIC METHODS ====================

  /// Get all active offers from API
  Future<List<OfferModel>> getOffers() async {
    if (apiClient == null) {
      debugPrint('⚠️ OfferRepository: No API client available');
      return [];
    }

    try {
      final response = await apiClient!.get(ApiConstants.offers);
      final responseData = response.data['data'] ?? response.data;
      final offersList = responseData['offers'] ?? responseData;

      final offers = (offersList as List)
          .map((json) => OfferModel.fromJson(json))
          .where((offer) => offer.isValid)
          .toList();

      debugPrint('📦 OfferRepository: Fetched ${offers.length} offers from API');
      return offers;
    } catch (e) {
      debugPrint('⚠️ OfferRepository Error in getOffers: $e');
      return [];
    }
  }

  /// Get offer by ID from API
  Future<OfferModel?> getOfferById(String offerId) async {
    if (apiClient == null) {
      debugPrint('⚠️ OfferRepository: No API client available');
      return null;
    }

    try {
      final response = await apiClient!.get(ApiConstants.offerById(offerId));
      final responseData = response.data['data'] ?? response.data;
      final offerData = responseData['offer'] ?? responseData;
      return OfferModel.fromJson(offerData);
    } catch (e) {
      debugPrint('⚠️ OfferRepository Error in getOfferById: $e');
      return null;
    }
  }

  /// Get offers by provider from API
  Future<List<OfferModel>> getOffersByProvider(String providerId) async {
    if (apiClient == null) {
      debugPrint('⚠️ OfferRepository: No API client available');
      return [];
    }

    try {
      final response = await apiClient!.get(
        ApiConstants.getProviderOffers(providerId),
      );
      final responseData = response.data['data'] ?? response.data;
      final offersList = responseData['offers'] ?? responseData;

      return (offersList as List)
          .map((json) => OfferModel.fromJson(json))
          .where((offer) => offer.isValid)
          .toList();
    } catch (e) {
      debugPrint('⚠️ OfferRepository Error in getOffersByProvider: $e');
      return [];
    }
  }

  /// Get offers by service type from API
  Future<List<OfferModel>> getOffersByServiceType(String serviceType) async {
    if (apiClient == null) {
      debugPrint('⚠️ OfferRepository: No API client available');
      return [];
    }

    try {
      // Get all offers and filter client-side by service type
      final offers = await getOffers();
      return offers
          .where((offer) => offer.serviceType == serviceType && offer.isValid)
          .toList();
    } catch (e) {
      debugPrint('⚠️ OfferRepository Error in getOffersByServiceType: $e');
      return [];
    }
  }
}
