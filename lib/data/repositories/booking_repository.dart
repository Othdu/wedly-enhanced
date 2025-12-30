import '../models/booking_model.dart';
import '../services/api_client.dart';
import '../services/api_constants.dart';
import '../../core/utils/enums.dart';

class BookingRepository {
  final ApiClient? apiClient;
  final bool useMockData;

  BookingRepository({
    this.apiClient,
    this.useMockData = true,
  });

  // ==================== PUBLIC METHODS ====================

  /// Get all bookings for a specific user
  Future<List<BookingModel>> getUserBookings(String userId) async {
    if (useMockData || apiClient == null) {
      return _mockGetUserBookings(userId);
    }
    return _apiGetUserBookings();
  }

  /// Get all bookings for a specific provider
  Future<List<BookingModel>> getProviderBookings(String providerId) async {
    if (useMockData || apiClient == null) {
      return _mockGetProviderBookings(providerId);
    }
    return _apiGetProviderBookings();
  }

  /// Get bookings by status
  Future<List<BookingModel>> getBookingsByStatus(
    String providerId,
    BookingStatus status,
  ) async {
    if (useMockData || apiClient == null) {
      return _mockGetBookingsByStatus(providerId, status);
    }
    // For API mode, we get all bookings and filter client-side
    // Or the API could support ?status=pending query parameter
    final bookings = await _apiGetProviderBookings();
    return bookings.where((b) => b.status == status).toList();
  }

  /// Get a single booking by ID
  Future<BookingModel?> getBookingById(String bookingId) async {
    if (useMockData || apiClient == null) {
      return _mockGetBookingById(bookingId);
    }
    return _apiGetBookingById(bookingId);
  }

  /// Update booking status
  Future<BookingModel> updateBookingStatus(
    String bookingId,
    BookingStatus newStatus,
  ) async {
    if (useMockData || apiClient == null) {
      return _mockUpdateBookingStatus(bookingId, newStatus);
    }
    return _apiUpdateBookingStatus(bookingId, newStatus);
  }

  /// Get bookings count by status for a provider
  Future<Map<BookingStatus, int>> getBookingsCountByStatus(
    String providerId,
  ) async {
    if (useMockData || apiClient == null) {
      return _mockGetBookingsCountByStatus(providerId);
    }
    return _apiGetBookingsCountByStatus();
  }

  /// Get bookings by date range
  Future<List<BookingModel>> getBookingsByDateRange(
    String providerId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    if (useMockData || apiClient == null) {
      return _mockGetBookingsByDateRange(providerId, startDate, endDate);
    }
    // For API mode, get all bookings and filter client-side
    final bookings = await _apiGetProviderBookings();
    return bookings
        .where((b) =>
            b.bookingDate.isAfter(startDate) &&
            b.bookingDate.isBefore(endDate))
        .toList();
  }

  /// Create a new booking
  Future<BookingModel> createBooking(Map<String, dynamic> bookingData) async {
    if (useMockData || apiClient == null) {
      return _mockCreateBooking(bookingData);
    }
    return _apiCreateBooking(bookingData);
  }

  // ==================== API METHODS ====================

  /// API: Get user bookings
  Future<List<BookingModel>> _apiGetUserBookings() async {
    final response = await apiClient!.get(ApiConstants.userBookings);
    final responseData = response.data['data'] ?? response.data;
    final bookingsList = responseData['bookings'] ?? responseData;

    return (bookingsList as List)
        .map((json) => BookingModel.fromJson(json))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// API: Get provider bookings
  Future<List<BookingModel>> _apiGetProviderBookings() async {
    final response = await apiClient!.get(ApiConstants.providerBookings);
    final responseData = response.data['data'] ?? response.data;
    final bookingsList = responseData['bookings'] ?? responseData;

    return (bookingsList as List)
        .map((json) => BookingModel.fromJson(json))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// API: Get booking by ID
  Future<BookingModel?> _apiGetBookingById(String bookingId) async {
    try {
      final response =
          await apiClient!.get(ApiConstants.bookingById(bookingId));
      final responseData = response.data['data'] ?? response.data;
      final bookingData = responseData['booking'] ?? responseData;
      return BookingModel.fromJson(bookingData);
    } catch (e) {
      return null;
    }
  }

  /// API: Update booking status
  Future<BookingModel> _apiUpdateBookingStatus(
    String bookingId,
    BookingStatus newStatus,
  ) async {
    final response = await apiClient!.patch(
      ApiConstants.updateBookingStatus(bookingId),
      data: {'status': newStatus.name},
    );
    final responseData = response.data['data'] ?? response.data;
    final bookingData = responseData['booking'] ?? responseData;
    return BookingModel.fromJson(bookingData);
  }

  /// API: Get bookings count by status
  Future<Map<BookingStatus, int>> _apiGetBookingsCountByStatus() async {
    final response = await apiClient!.get(ApiConstants.providerBookingStats);
    final responseData = response.data['data'] ?? response.data;
    final stats = responseData['stats'] ?? responseData;

    return {
      BookingStatus.pending: stats['pending'] ?? 0,
      BookingStatus.confirmed: stats['confirmed'] ?? 0,
      BookingStatus.completed: stats['completed'] ?? 0,
      BookingStatus.cancelled: stats['cancelled'] ?? 0,
    };
  }

  /// API: Create a new booking
  Future<BookingModel> _apiCreateBooking(Map<String, dynamic> bookingData) async {
    // Remove any null values from the booking data before sending
    final cleanedData = Map<String, dynamic>.from(bookingData)
      ..removeWhere((key, value) => value == null);

    final response = await apiClient!.post(
      ApiConstants.createBooking,
      data: cleanedData,
    );
    final responseData = response.data['data'] ?? response.data;
    final booking = responseData['booking'] ?? responseData;
    return BookingModel.fromJson(booking);
  }

  // ==================== MOCK METHODS ====================

  Future<List<BookingModel>> _mockGetUserBookings(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockBookings
        .where((booking) => booking.userId == userId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<List<BookingModel>> _mockGetProviderBookings(String providerId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockBookings
        .where((booking) => booking.providerId == providerId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<List<BookingModel>> _mockGetBookingsByStatus(
    String providerId,
    BookingStatus status,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockBookings
        .where((booking) => booking.status == status)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<BookingModel?> _mockGetBookingById(String bookingId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _mockBookings.firstWhere((booking) => booking.id == bookingId);
    } catch (e) {
      return null;
    }
  }

  Future<BookingModel> _mockUpdateBookingStatus(
    String bookingId,
    BookingStatus newStatus,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final booking = await _mockGetBookingById(bookingId);
    if (booking == null) {
      throw Exception('Booking not found');
    }
    return booking.copyWith(status: newStatus);
  }

  Future<Map<BookingStatus, int>> _mockGetBookingsCountByStatus(
    String providerId,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final providerBookings =
        _mockBookings.where((b) => b.providerId == providerId);

    return {
      BookingStatus.pending:
          providerBookings.where((b) => b.status == BookingStatus.pending).length,
      BookingStatus.confirmed:
          providerBookings.where((b) => b.status == BookingStatus.confirmed).length,
      BookingStatus.completed:
          providerBookings.where((b) => b.status == BookingStatus.completed).length,
      BookingStatus.cancelled:
          providerBookings.where((b) => b.status == BookingStatus.cancelled).length,
    };
  }

  Future<List<BookingModel>> _mockGetBookingsByDateRange(
    String providerId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockBookings
        .where((booking) =>
            booking.providerId == providerId &&
            booking.bookingDate.isAfter(startDate) &&
            booking.bookingDate.isBefore(endDate))
        .toList()
      ..sort((a, b) => a.bookingDate.compareTo(b.bookingDate));
  }

  Future<BookingModel> _mockCreateBooking(Map<String, dynamic> bookingData) async {
    await Future.delayed(const Duration(milliseconds: 800));

    // Handle both snake_case (from API) and camelCase (from legacy code)
    final serviceId = bookingData['service_id'] ?? bookingData['serviceId'] ?? '';
    final bookingDateStr = bookingData['booking_date'] ?? bookingData['bookingDate'];
    final customerName = bookingData['customer_name'] ?? bookingData['customerName'] ?? '';
    final customerEmail = bookingData['customer_email'] ?? bookingData['customerEmail'] ?? '';
    final customerPhone = bookingData['customer_phone'] ?? bookingData['customerPhone'] ?? '';
    final eventType = bookingData['event_type'] ?? bookingData['eventType'] ?? '';
    final guestCount = bookingData['guest_count'] ?? bookingData['guestCount'] ?? 0;
    final eventLocation = bookingData['event_location'] ?? bookingData['eventLocation'] ?? '';
    final specialRequests = bookingData['special_requests'] ?? bookingData['specialRequests'];
    final timeSlot = bookingData['time_slot'] ?? bookingData['timeSlot'] ?? 'morning';
    final paymentMethod = bookingData['payment_method'] ?? bookingData['paymentMethod'] ?? 'cash';
    final selectedSectionId = bookingData['selected_section_id'] ?? bookingData['selectedSectionId'];
    final selectedOptionIds = bookingData['selected_option_id'] ?? bookingData['selectedOptionIds'];

    final newBooking = BookingModel(
      id: 'booking_${DateTime.now().millisecondsSinceEpoch}',
      serviceId: serviceId,
      serviceName: bookingData['serviceName'] ?? bookingData['service_name'] ?? 'خدمة',
      serviceImage: bookingData['serviceImage'] ?? bookingData['service_image'] ?? '',
      providerId: bookingData['providerId'] ?? bookingData['provider_id'] ?? '',
      userId: bookingData['userId'] ?? bookingData['user_id'] ?? '',
      customerName: customerName,
      customerEmail: customerEmail,
      customerPhone: customerPhone,
      bookingDate: bookingDateStr != null ? DateTime.parse(bookingDateStr) : DateTime.now(),
      createdAt: DateTime.now(),
      status: BookingStatus.pending,
      totalAmount: (bookingData['totalAmount'] ?? bookingData['total_amount'] ?? 0).toDouble(),
      paymentStatus: PaymentStatus.pending,
      eventType: eventType,
      guestCount: guestCount is int ? guestCount : int.tryParse(guestCount.toString()) ?? 0,
      eventLocation: eventLocation,
      notes: bookingData['notes'],
      specialRequests: specialRequests,
      timeSlot: timeSlot,
      paymentMethod: paymentMethod,
      selectedSectionId: selectedSectionId,
      selectedOptionIds: selectedOptionIds is List
          ? selectedOptionIds.map((e) => e.toString()).toList()
          : null,
    );
    _mockBookings.add(newBooking);
    return newBooking;
  }

  // ==================== MOCK DATA ====================

  final List<BookingModel> _mockBookings = [
    // Booking 1: حجز قاعة روزا (Confirmed - Upcoming)
    BookingModel(
      id: '1',
      serviceId: '1',
      serviceName: 'قاعة روزا - التجمع الخامس',
      serviceImage:
          'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=800',
      providerId: 'provider_1',
      userId: 'user_1763246207853',
      customerName: 'محمود احمد الحراز',
      customerEmail: 'mahmoud@example.com',
      customerPhone: '+201001234567',
      bookingDate: DateTime(2025, 3, 20, 19, 0),
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      status: BookingStatus.confirmed,
      totalAmount: 10000,
      paymentStatus: PaymentStatus.paid,
      eventType: 'قاعة أفراح',
      guestCount: 500,
      eventLocation: 'التجمع الخامس - القاهرة',
      notes: 'تم تأكيد الحجز ودفع المقدم',
      specialRequests: 'إضاءة إضافية وديكور ورد طبيعي',
    ),

    // Booking 2: حجز تصوير فوتوغرافي (Confirmed - Same event)
    BookingModel(
      id: '2',
      serviceId: '4',
      serviceName: 'تصوير فوتوغرافي احترافي',
      serviceImage:
          'https://images.unsplash.com/photo-1606216794074-735e91aa2c92?w=800',
      providerId: 'provider_4',
      userId: 'user_1763246207853',
      customerName: 'محمود احمد الحراز',
      customerEmail: 'mahmoud@example.com',
      customerPhone: '+201001234567',
      bookingDate: DateTime(2025, 3, 20, 18, 0),
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      status: BookingStatus.confirmed,
      totalAmount: 3000,
      paymentStatus: PaymentStatus.paid,
      eventType: 'تصوير فوتوغرافي',
      guestCount: 500,
      eventLocation: 'التجمع الخامس - القاهرة',
      notes: 'سيصل المصور قبل ساعة من الحفل',
      specialRequests: 'التركيز على لحظات العائلة وجلسة تصوير خارجية',
    ),

    // Booking 3: حجز فيديوغراف (Pending)
    BookingModel(
      id: '3',
      serviceId: '8',
      serviceName: 'فيديوغراف وتصوير سينمائي',
      serviceImage:
          'https://images.unsplash.com/photo-1492691527719-9d1e07e534b4?w=800',
      providerId: 'provider_8',
      userId: 'user_1763246207853',
      customerName: 'محمود احمد الحراز',
      customerEmail: 'mahmoud@example.com',
      customerPhone: '+201001234567',
      bookingDate: DateTime(2025, 3, 20, 18, 0),
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      status: BookingStatus.pending,
      totalAmount: 4000,
      paymentStatus: PaymentStatus.pending,
      eventType: 'تصوير فيديو',
      guestCount: 500,
      eventLocation: 'التجمع الخامس - القاهرة',
      notes: 'في انتظار تأكيد المزود',
      specialRequests: 'فيديو سينمائي مدته 15 دقيقة مع موسيقى',
    ),

    // Booking 4: حجز ديكور (Confirmed)
    BookingModel(
      id: '4',
      serviceId: '5',
      serviceName: 'ديكور وزينة الأفراح',
      serviceImage:
          'https://images.unsplash.com/photo-1478146896981-b80fe463b330?w=800',
      providerId: 'provider_5',
      userId: 'user_1763246207853',
      customerName: 'محمود احمد الحراز',
      customerEmail: 'mahmoud@example.com',
      customerPhone: '+201001234567',
      bookingDate: DateTime(2025, 3, 20, 15, 0),
      createdAt: DateTime.now().subtract(const Duration(days: 8)),
      status: BookingStatus.confirmed,
      totalAmount: 5000,
      paymentStatus: PaymentStatus.paid,
      eventType: 'ديكور وزينة',
      guestCount: 500,
      eventLocation: 'التجمع الخامس - القاهرة',
      notes: 'تم الاتفاق على التصميم والألوان',
      specialRequests: 'ورود بيضاء وذهبية، كراسي شيفاري',
    ),

    // Booking 5: حجز زفة (Pending)
    BookingModel(
      id: '5',
      serviceId: '6',
      serviceName: 'زفة مصرية تقليدية',
      serviceImage:
          'https://images.unsplash.com/photo-1511795409834-ef04bbd61622?w=800',
      providerId: 'provider_6',
      userId: 'user_1763246207853',
      customerName: 'محمود احمد الحراز',
      customerEmail: 'mahmoud@example.com',
      customerPhone: '+201001234567',
      bookingDate: DateTime(2025, 3, 20, 20, 0),
      createdAt: DateTime.now().subtract(const Duration(hours: 12)),
      status: BookingStatus.pending,
      totalAmount: 2000,
      paymentStatus: PaymentStatus.pending,
      eventType: 'زفة وموسيقى',
      guestCount: 500,
      eventLocation: 'التجمع الخامس - القاهرة',
      notes: 'في انتظار التأكيد',
      specialRequests: 'فرقة موسيقية مع أغاني تراثية',
    ),

    // Booking 6: حجز سابق مكتمل
    BookingModel(
      id: '6',
      serviceId: '2',
      serviceName: 'قاعة النيل - المعادي',
      serviceImage:
          'https://images.unsplash.com/photo-1464366400600-7168b8af9bc3?w=800',
      providerId: 'provider_2',
      userId: 'user_1763246207853',
      customerName: 'محمود احمد الحراز',
      customerEmail: 'mahmoud@example.com',
      customerPhone: '+201001234567',
      bookingDate: DateTime(2024, 12, 15, 19, 0),
      createdAt: DateTime(2024, 11, 1),
      status: BookingStatus.completed,
      totalAmount: 8000,
      paymentStatus: PaymentStatus.paid,
      eventType: 'قاعة أفراح',
      guestCount: 300,
      eventLocation: 'المعادي - القاهرة',
      notes: 'تم الحفل بنجاح',
      specialRequests: null,
    ),

    // Booking 7: حجز ملغي
    BookingModel(
      id: '7',
      serviceId: '3',
      serviceName: 'قاعة الأهرام - الهرم',
      serviceImage:
          'https://images.unsplash.com/photo-1465495976277-4387d4b0b4c6?w=800',
      providerId: 'provider_3',
      userId: 'user_1763246207853',
      customerName: 'محمود احمد الحراز',
      customerEmail: 'mahmoud@example.com',
      customerPhone: '+201001234567',
      bookingDate: DateTime(2025, 2, 10, 18, 0),
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      status: BookingStatus.cancelled,
      totalAmount: 7000,
      paymentStatus: PaymentStatus.refunded,
      eventType: 'قاعة أفراح',
      guestCount: 400,
      eventLocation: 'الجيزة',
      notes: 'تم الإلغاء بناءً على طلب العميل',
      specialRequests: null,
    ),
  ];
}
