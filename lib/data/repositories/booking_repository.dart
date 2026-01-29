import '../models/booking_model.dart';
import '../services/api_client.dart';
import '../services/api_constants.dart';
import '../../core/utils/enums.dart';

class BookingRepository {
  final ApiClient _apiClient;

  BookingRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Get all bookings for a specific user
  Future<List<BookingModel>> getUserBookings(String userId) async {
    final response = await _apiClient.get(ApiConstants.userBookings);
    final responseData = response.data['data'] ?? response.data;
    final bookingsList = responseData['bookings'] ?? responseData;

    return (bookingsList as List)
        .map((json) => BookingModel.fromJson(json))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Get all bookings for a specific provider
  Future<List<BookingModel>> getProviderBookings(String providerId) async {
    final response = await _apiClient.get(ApiConstants.providerBookings);
    final responseData = response.data['data'] ?? response.data;
    final bookingsList = responseData['bookings'] ?? responseData;

    return (bookingsList as List)
        .map((json) => BookingModel.fromJson(json))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Get bookings by status
  Future<List<BookingModel>> getBookingsByStatus(
    String providerId,
    BookingStatus status,
  ) async {
    final bookings = await getProviderBookings(providerId);
    return bookings.where((b) => b.status == status).toList();
  }

  /// Get a single booking by ID
  Future<BookingModel?> getBookingById(String bookingId) async {
    try {
      final response = await _apiClient.get(ApiConstants.bookingById(bookingId));
      final responseData = response.data['data'] ?? response.data;
      final bookingData = responseData['booking'] ?? responseData;
      return BookingModel.fromJson(bookingData);
    } catch (e) {
      return null;
    }
  }

  /// Update booking status
  Future<BookingModel> updateBookingStatus(
    String bookingId,
    BookingStatus newStatus,
  ) async {
    final response = await _apiClient.patch(
      ApiConstants.updateBookingStatus(bookingId),
      data: {'status': newStatus.name},
    );
    final responseData = response.data['data'] ?? response.data;
    final bookingData = responseData['booking'] ?? responseData;
    return BookingModel.fromJson(bookingData);
  }

  /// Get bookings count by status for a provider
  Future<Map<BookingStatus, int>> getBookingsCountByStatus(String providerId) async {
    final response = await _apiClient.get(ApiConstants.providerBookingStats);
    final responseData = response.data['data'] ?? response.data;
    final stats = responseData['stats'] ?? responseData;

    return {
      BookingStatus.pending: stats['pending'] ?? 0,
      BookingStatus.confirmed: stats['confirmed'] ?? 0,
      BookingStatus.completed: stats['completed'] ?? 0,
      BookingStatus.cancelled: stats['cancelled'] ?? 0,
    };
  }

  /// Get bookings by date range
  Future<List<BookingModel>> getBookingsByDateRange(
    String providerId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final bookings = await getProviderBookings(providerId);
    return bookings
        .where((b) =>
            b.bookingDate.isAfter(startDate) &&
            b.bookingDate.isBefore(endDate))
        .toList();
  }

  /// Create a new booking
  Future<BookingModel> createBooking(Map<String, dynamic> bookingData) async {
    final cleanedData = Map<String, dynamic>.from(bookingData)
      ..removeWhere((key, value) => value == null);

    final response = await _apiClient.post(
      ApiConstants.createBooking,
      data: cleanedData,
    );
    final responseData = response.data['data'] ?? response.data;
    final booking = responseData['booking'] ?? responseData;
    return BookingModel.fromJson(booking);
  }
}
