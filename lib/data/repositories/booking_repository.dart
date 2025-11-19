import '../models/booking_model.dart';
import '../../core/utils/enums.dart';

class BookingRepository {
  // Mock data for bookings
  // TODO: Replace with real API endpoint calls
  // API Endpoint: GET /api/bookings?userId={userId}
  // Response format: { "bookings": [ ... booking objects ... ] }
  final List<BookingModel> _mockBookings = [
    // Booking 1: حجز قاعة روزا (Confirmed - Upcoming)
    BookingModel(
      id: '1',
      serviceId: '1',
      serviceName: 'قاعة روزا - التجمع الخامس',
      serviceImage: 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=800',
      providerId: 'provider_1',
      userId: 'user_1763246207853', // Current logged in user
      customerName: 'محمود احمد الحراز',
      customerEmail: 'mahmoud@example.com',
      customerPhone: '+201001234567',
      bookingDate: DateTime(2025, 3, 20, 19, 0), // حفل قادم في مارس
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
      serviceImage: 'https://images.unsplash.com/photo-1606216794074-735e91aa2c92?w=800',
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
      serviceImage: 'https://images.unsplash.com/photo-1492691527719-9d1e07e534b4?w=800',
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
      serviceImage: 'https://images.unsplash.com/photo-1478146896981-b80fe463b330?w=800',
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

    // Booking 5: حجز كوافير (Confirmed)
    BookingModel(
      id: '5',
      serviceId: '6',
      serviceName: 'كوافير وميكب للعروسة',
      serviceImage: 'https://images.unsplash.com/photo-1487412947147-5cebf100ffc2?w=800',
      providerId: 'provider_6',
      userId: 'user_1763246207853',
      customerName: 'محمود احمد الحراز',
      customerEmail: 'mahmoud@example.com',
      customerPhone: '+201001234567',
      bookingDate: DateTime(2025, 3, 20, 14, 0),
      createdAt: DateTime.now().subtract(const Duration(days: 12)),
      status: BookingStatus.confirmed,
      totalAmount: 2500,
      paymentStatus: PaymentStatus.paid,
      eventType: 'كوافير وميكب',
      guestCount: 1,
      eventLocation: 'المنزل - القاهرة',
      notes: 'الموعد في منزل العروسة',
      specialRequests: 'ميكب ناعم وتسريحة مرفوعة',
    ),

    // Booking 6: حجز سيارة زفاف (Confirmed)
    BookingModel(
      id: '6',
      serviceId: '7',
      serviceName: 'BMW 6 Series - سيارة زفاف فاخرة',
      serviceImage: 'https://images.unsplash.com/photo-1555215695-3004980ad54e?w=800',
      providerId: 'provider_7',
      userId: 'user_1763246207853',
      customerName: 'محمود احمد الحراز',
      customerEmail: 'mahmoud@example.com',
      customerPhone: '+201001234567',
      bookingDate: DateTime(2025, 3, 20, 17, 0),
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
      status: BookingStatus.confirmed,
      totalAmount: 1500,
      paymentStatus: PaymentStatus.paid,
      eventType: 'سيارة زفاف',
      guestCount: 2,
      eventLocation: 'التجمع الخامس - القاهرة',
      notes: 'السيارة ستكون مزينة بالورود',
      specialRequests: 'توصيل من المنزل للقاعة والعودة',
    ),

    // Booking 7: حجز منظم أفراح سابق (Completed)
    BookingModel(
      id: '7',
      serviceId: '19',
      serviceName: 'منظم أفراح محترف',
      serviceImage: 'https://images.unsplash.com/photo-1511285560929-80b456fea0bc?w=800',
      providerId: 'provider_19',
      userId: 'user_1763246207853',
      customerName: 'محمود احمد الحراز',
      customerEmail: 'mahmoud@example.com',
      customerPhone: '+201001234567',
      bookingDate: DateTime(2024, 10, 15, 10, 0),
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
      status: BookingStatus.completed,
      totalAmount: 9000,
      paymentStatus: PaymentStatus.paid,
      eventType: 'استشارة تنظيم',
      guestCount: 500,
      eventLocation: 'القاهرة',
      notes: 'تمت الاستشارة بنجاح',
      specialRequests: null,
    ),

    // Booking 8: حجز قاعة سابق (Cancelled)
    BookingModel(
      id: '8',
      serviceId: '2',
      serviceName: 'قاعة ليالي - الشيخ زايد',
      serviceImage: 'https://images.unsplash.com/photo-1464366400600-7168b8af9bc3?w=800',
      providerId: 'provider_2',
      userId: 'user_1763246207853',
      customerName: 'محمود احمد الحراز',
      customerEmail: 'mahmoud@example.com',
      customerPhone: '+201001234567',
      bookingDate: DateTime(2025, 2, 10, 19, 0),
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
      status: BookingStatus.cancelled,
      totalAmount: 15000,
      paymentStatus: PaymentStatus.refunded,
      eventType: 'قاعة أفراح',
      guestCount: 600,
      eventLocation: 'الشيخ زايد - القاهرة',
      notes: 'تم الإلغاء واسترداد المبلغ',
      specialRequests: null,
    ),

    // Booking 9: حجز استوديو تصوير سابق (Completed)
    BookingModel(
      id: '9',
      serviceId: '9',
      serviceName: 'استوديو النور للتصوير',
      serviceImage: 'https://images.unsplash.com/photo-1511285560929-80b456fea0bc?w=800',
      providerId: 'provider_9',
      userId: 'user_1763246207853',
      customerName: 'محمود احمد الحراز',
      customerEmail: 'mahmoud@example.com',
      customerPhone: '+201001234567',
      bookingDate: DateTime(2024, 9, 5, 16, 0),
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
      status: BookingStatus.completed,
      totalAmount: 2500,
      paymentStatus: PaymentStatus.paid,
      eventType: 'جلسة تصوير خطوبة',
      guestCount: 2,
      eventLocation: 'الاستوديو - القاهرة',
      notes: 'جلسة تصوير خطوبة رائعة',
      specialRequests: null,
    ),

    // Booking 10: حجز ديكورات الأحلام (Pending)
    BookingModel(
      id: '10',
      serviceId: '11',
      serviceName: 'ديكورات الأحلام',
      serviceImage: 'https://images.unsplash.com/photo-1464366400600-7168b8af9bc3?w=800',
      providerId: 'provider_11',
      userId: 'user_1763246207853',
      customerName: 'محمود احمد الحراز',
      customerEmail: 'mahmoud@example.com',
      customerPhone: '+201001234567',
      bookingDate: DateTime(2025, 4, 10, 15, 0),
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      status: BookingStatus.pending,
      totalAmount: 6000,
      paymentStatus: PaymentStatus.pending,
      eventType: 'ديكور وزينة',
      guestCount: 300,
      eventLocation: 'المعادي - القاهرة',
      notes: 'في انتظار الرد على عرض السعر',
      specialRequests: 'تصميم كلاسيكي مع إضاءة ذهبية',
    ),

    // Additional bookings for other users (won't show for current user)
    BookingModel(
      id: '11',
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
      id: '12',
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
      id: '13',
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
