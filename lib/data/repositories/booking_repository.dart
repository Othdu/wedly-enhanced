import '../models/booking_model.dart';
import '../../core/utils/enums.dart';

class BookingRepository {
  // Mock data for bookings
  // TODO: Replace with real API endpoint calls
  // API Endpoint: GET /api/bookings?userId={userId}
  // Response format: { "bookings": [ ... booking objects ... ] }
  final List<BookingModel> _mockBookings = [
    // Booking 1: حجز القستان (Pending)
    BookingModel(
      id: '1',
      serviceId: '1',
      serviceName: 'فستان الخصر العالي',
      serviceImage: 'https://images.unsplash.com/photo-1519167758481-83f29da8c6a9?w=800',
      providerId: 'provider1',
      userId: 'user_1763246207853', // Current logged in user
      customerName: 'محمود احمد الحراز',
      customerEmail: 'mahmoud@example.com',
      customerPhone: '+201001234567',
      bookingDate: DateTime(2024, 11, 15, 20, 0), // 15 نوفمبر - الساعة 8:00 مساءً
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      status: BookingStatus.pending,
      totalAmount: 6000,
      paymentStatus: PaymentStatus.pending,
      eventType: 'فستان زفاف',
      guestCount: 1,
      eventLocation: 'القاهرة',
      notes: null,
      specialRequests: null,
    ),

    // Booking 2: حجز المصور (Completed)
    BookingModel(
      id: '2',
      serviceId: '2',
      serviceName: 'مصطفى محمود',
      serviceImage: 'https://images.unsplash.com/photo-1606216794074-735e91aa2c92?w=800',
      providerId: 'provider1',
      userId: 'user_1763246207853', // Current logged in user
      customerName: 'مصطفى محمود',
      customerEmail: 'mustafa@example.com',
      customerPhone: '+201001234567',
      bookingDate: DateTime(2024, 11, 15, 20, 0),
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      status: BookingStatus.completed,
      totalAmount: 9000,
      paymentStatus: PaymentStatus.paid,
      eventType: 'تصوير فوتوغرافي',
      guestCount: 1,
      eventLocation: 'القاهرة',
      notes: null,
      specialRequests: null,
    ),

    // Booking 3: حجز القاعة (Completed)
    BookingModel(
      id: '3',
      serviceId: '3',
      serviceName: 'قاعة روزا - التجمع الخامس',
      serviceImage: 'https://images.unsplash.com/photo-1519167758481-83f29da8c6a9?w=800',
      providerId: 'provider1',
      userId: 'user_1763246207853', // Current logged in user
      customerName: 'قاعة روزا',
      customerEmail: 'rosa@example.com',
      customerPhone: '+201001234567',
      bookingDate: DateTime(2024, 11, 15, 20, 0),
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      status: BookingStatus.completed,
      totalAmount: 12000,
      paymentStatus: PaymentStatus.paid,
      eventType: 'قاعة أفراح',
      guestCount: 500,
      eventLocation: 'التجمع الخامس',
      notes: null,
      specialRequests: null,
    ),

    // Additional bookings for other users (won't show for current user)
    BookingModel(
      id: '4',
      serviceId: '4',
      serviceName: 'خدمة طعام فاخرة - مطعم الأصالة',
      serviceImage: 'https://images.unsplash.com/photo-1555244162-803834f70033?w=800',
      providerId: 'provider1',
      userId: 'user2',
      customerName: 'سارة علي الشامي',
      customerEmail: 'sara@example.com',
      customerPhone: '+20 100 234 5678',
      bookingDate: DateTime(2024, 11, 22, 20, 0),
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      status: BookingStatus.confirmed,
      totalAmount: 15000,
      paymentStatus: PaymentStatus.paid,
      eventType: 'خدمة طعام',
      guestCount: 500,
      eventLocation: 'القاهرة',
      notes: null,
      specialRequests: 'قائمة طعام نباتية لـ 50 شخص',
    ),
    BookingModel(
      id: '5',
      serviceId: '5',
      serviceName: 'ديكور وورود - حديقة الزهور',
      serviceImage: 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=800',
      providerId: 'provider1',
      userId: 'user3',
      customerName: 'ليلى إبراهيم الحسيني',
      customerEmail: 'layla@example.com',
      customerPhone: '+20 112 456 7890',
      bookingDate: DateTime(2024, 10, 20, 16, 0),
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
      status: BookingStatus.completed,
      totalAmount: 6000,
      paymentStatus: PaymentStatus.paid,
      eventType: 'ديكور وورود',
      guestCount: 400,
      eventLocation: 'الإسكندرية',
      notes: null,
      specialRequests: null,
    ),
    BookingModel(
      id: '6',
      serviceId: '2',
      serviceName: 'قاعة ريحا - الجنح الطائر',
      serviceImage: 'https://images.unsplash.com/photo-1519167758481-83f29da8c6a9?w=800',
      providerId: 'provider1',
      userId: 'user4',
      customerName: 'عمر سعيد الأحمد',
      customerEmail: 'omar@example.com',
      customerPhone: '+20 123 567 8901',
      bookingDate: DateTime(2024, 10, 10, 18, 0),
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      status: BookingStatus.cancelled,
      totalAmount: 12000,
      paymentStatus: PaymentStatus.refunded,
      eventType: 'قاعة افراح',
      guestCount: 600,
      eventLocation: 'الجيزة',
      notes: 'تم الإلغاء بناءً على طلب العميل',
      specialRequests: null,
    ),
  ];

  // Get all bookings for a specific provider
  // TODO: Replace with API call
  // API Endpoint: GET /api/provider/bookings?providerId={providerId}
  Future<List<BookingModel>> getProviderBookings(String providerId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockBookings
        .where((booking) => booking.providerId == providerId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Get all bookings for a specific user
  // TODO: Replace with API call
  // API Endpoint: GET /api/user/bookings?userId={userId}
  Future<List<BookingModel>> getUserBookings(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockBookings
        .where((booking) => booking.userId == userId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Get bookings by status
  // TODO: Replace with API call
  // API Endpoint: GET /api/bookings?providerId={providerId}&status={status}
  Future<List<BookingModel>> getBookingsByStatus(
    String providerId,
    BookingStatus status,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // For mock/demo mode: return all bookings with the specified status
    // In production, filter by providerId
    return _mockBookings
        .where((booking) => booking.status == status)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Get a single booking by ID
  // TODO: Replace with API call
  // API Endpoint: GET /api/bookings/{bookingId}
  Future<BookingModel?> getBookingById(String bookingId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _mockBookings.firstWhere((booking) => booking.id == bookingId);
    } catch (e) {
      return null;
    }
  }

  // Update booking status
  // TODO: Replace with API call
  // API Endpoint: PATCH /api/bookings/{bookingId}/status
  // Request body: { "status": "confirmed" | "cancelled" | "completed" }
  Future<BookingModel> updateBookingStatus(
    String bookingId,
    BookingStatus newStatus,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final booking = await getBookingById(bookingId);
    if (booking == null) {
      throw Exception('Booking not found');
    }
    return booking.copyWith(status: newStatus);
  }

  // Get bookings count by status
  // TODO: Replace with API call
  // API Endpoint: GET /api/bookings/count?providerId={providerId}
  Future<Map<BookingStatus, int>> getBookingsCountByStatus(
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

  // Get bookings by date range
  // TODO: Replace with API call
  // API Endpoint: GET /api/bookings?providerId={providerId}&startDate={start}&endDate={end}
  Future<List<BookingModel>> getBookingsByDateRange(
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
}
