import '../models/booking_model.dart';
import '../../core/utils/enums.dart';

class BookingRepository {
  // Mock data for bookings
  final List<BookingModel> _mockBookings = [
    BookingModel(
      id: '1',
      serviceId: '1',
      serviceName: 'قاعة ريحا - الجنح الطائر',
      serviceImage: 'https://images.unsplash.com/photo-1519167758481-83f29da8c6a9?w=800',
      providerId: 'provider1',
      userId: 'user1',
      customerName: 'محمود احمد الحراز',
      customerEmail: 'mahmoud@example.com',
      customerPhone: '+20 100 123 4567',
      bookingDate: DateTime(2024, 11, 15, 19, 0),
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      status: BookingStatus.pending,
      totalAmount: 12000,
      paymentStatus: PaymentStatus.pending,
      eventType: 'قاعة افراح',
      guestCount: 800,
      eventLocation: 'القاهرة',
      notes: null,
      specialRequests: 'نحتاج منصور طبليس من مواضع الفافي مع شاشة العرض',
    ),
    BookingModel(
      id: '2',
      serviceId: '2',
      serviceName: 'قاعة ريحا - الجنح الطائر',
      serviceImage: 'https://images.unsplash.com/photo-1519167758481-83f29da8c6a9?w=800',
      providerId: 'provider1',
      userId: 'user2',
      customerName: 'فاطمة محمد العلي',
      customerEmail: 'fatima@example.com',
      customerPhone: '+20 111 456 7890',
      bookingDate: DateTime(2024, 11, 18, 18, 0),
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      status: BookingStatus.pending,
      totalAmount: 12000,
      paymentStatus: PaymentStatus.pending,
      eventType: 'قاعة افراح',
      guestCount: 800,
      eventLocation: 'الإسكندرية',
      notes: null,
      specialRequests: null,
    ),
    BookingModel(
      id: '3',
      serviceId: '3',
      serviceName: 'تصوير احترافي - استوديو النور',
      serviceImage: 'https://images.unsplash.com/photo-1606216794074-735e91aa2c92?w=800',
      providerId: 'provider1',
      userId: 'user3',
      customerName: 'أحمد حسن السيد',
      customerEmail: 'ahmed@example.com',
      customerPhone: '+20 122 789 0123',
      bookingDate: DateTime(2024, 11, 20, 14, 0),
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      status: BookingStatus.confirmed,
      totalAmount: 8500,
      paymentStatus: PaymentStatus.paid,
      eventType: 'تصوير زفاف',
      guestCount: 300,
      eventLocation: 'الجيزة',
      notes: null,
      specialRequests: 'نريد فيديو سينمائي بالإضافة للتصوير الفوتوغرافي',
    ),
    BookingModel(
      id: '4',
      serviceId: '4',
      serviceName: 'خدمة طعام فاخرة - مطعم الأصالة',
      serviceImage: 'https://images.unsplash.com/photo-1555244162-803834f70033?w=800',
      providerId: 'provider1',
      userId: 'user4',
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
      serviceId: '1',
      serviceName: 'قاعة ريحا - الجنح الطائر',
      serviceImage: 'https://images.unsplash.com/photo-1519167758481-83f29da8c6a9?w=800',
      providerId: 'provider1',
      userId: 'user5',
      customerName: 'خالد يوسف المصري',
      customerEmail: 'khaled@example.com',
      customerPhone: '+20 101 345 6789',
      bookingDate: DateTime(2024, 10, 25, 19, 0),
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      status: BookingStatus.completed,
      totalAmount: 12000,
      paymentStatus: PaymentStatus.paid,
      eventType: 'قاعة افراح',
      guestCount: 700,
      eventLocation: 'القاهرة',
      notes: null,
      specialRequests: null,
    ),
    BookingModel(
      id: '6',
      serviceId: '5',
      serviceName: 'ديكور وورود - حديقة الزهور',
      serviceImage: 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=800',
      providerId: 'provider1',
      userId: 'user6',
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
      id: '7',
      serviceId: '2',
      serviceName: 'قاعة ريحا - الجنح الطائر',
      serviceImage: 'https://images.unsplash.com/photo-1519167758481-83f29da8c6a9?w=800',
      providerId: 'provider1',
      userId: 'user7',
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
  Future<List<BookingModel>> getProviderBookings(String providerId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockBookings
        .where((booking) => booking.providerId == providerId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Get bookings by status
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

  // Get booking by ID
  Future<BookingModel?> getBookingById(String bookingId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _mockBookings.firstWhere((booking) => booking.id == bookingId);
    } catch (e) {
      return null;
    }
  }

  // Update booking status
  Future<BookingModel> updateBookingStatus(
    String bookingId,
    BookingStatus newStatus,
  ) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final index = _mockBookings.indexWhere((b) => b.id == bookingId);
    if (index == -1) {
      throw Exception('Booking not found');
    }

    final updatedBooking = _mockBookings[index].copyWith(status: newStatus);
    _mockBookings[index] = updatedBooking;

    return updatedBooking;
  }

  // Get bookings count by status
  Future<Map<BookingStatus, int>> getBookingsCountByStatus(
    String providerId,
  ) async {
    await Future.delayed(const Duration(milliseconds: 400));

    final providerBookings = _mockBookings
        .where((booking) => booking.providerId == providerId)
        .toList();

    return {
      BookingStatus.pending: providerBookings
          .where((b) => b.status == BookingStatus.pending)
          .length,
      BookingStatus.confirmed: providerBookings
          .where((b) => b.status == BookingStatus.confirmed)
          .length,
      BookingStatus.completed: providerBookings
          .where((b) => b.status == BookingStatus.completed)
          .length,
      BookingStatus.cancelled: providerBookings
          .where((b) => b.status == BookingStatus.cancelled)
          .length,
    };
  }

  // Get bookings by date range
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
