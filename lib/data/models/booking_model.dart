import 'package:equatable/equatable.dart';
import '../../core/utils/enums.dart';

class BookingModel extends Equatable {
  final String id;
  final String serviceId;
  final String serviceName;
  final String serviceImage;
  final String providerId;
  final String userId;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final DateTime bookingDate;
  final DateTime createdAt;
  final BookingStatus status;
  final double totalAmount;
  final PaymentStatus paymentStatus;
  final String? notes;
  final String? specialRequests;
  final String? serviceCategory; // Category of the service (e.g., 'venue', 'photography', etc.)
  final String eventType;
  final int guestCount;
  final String eventLocation;
  final double? discountPercentage; // Optional discount percentage from service
  final String timeSlot; // "morning" or "evening"
  final String paymentMethod; // "cash", "visa", "wallet"
  final String? selectedSectionId; // Selected section ID from dynamic sections
  final List<String>? selectedOptionIds; // Selected option IDs from dynamic sections
  final bool hasReviewed; // Whether the user has already reviewed this booking
  final String? reviewId; // The ID of the user's review if hasReviewed is true
  final double? reviewRating; // The rating of the user's review if hasReviewed is true
  final String? reviewComment; // The comment of the user's review if hasReviewed is true
  final String serviceType; // 'service' or 'venue' - determines which review endpoint to use

  const BookingModel({
    required this.id,
    required this.serviceId,
    required this.serviceName,
    required this.serviceImage,
    required this.providerId,
    required this.userId,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.bookingDate,
    required this.createdAt,
    required this.status,
    required this.totalAmount,
    required this.paymentStatus,
    this.notes,
    this.specialRequests,
    this.serviceCategory,
    required this.eventType,
    required this.guestCount,
    required this.eventLocation,
    this.discountPercentage,
    this.timeSlot = 'morning',
    this.paymentMethod = 'cash',
    this.selectedSectionId,
    this.selectedOptionIds,
    this.hasReviewed = false,
    this.reviewId,
    this.reviewRating,
    this.reviewComment,
    this.serviceType = 'service',
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    // Helper to get value from snake_case or camelCase key
    // Handles null values properly without type cast issues
    String? getStringField(String snakeCase, String camelCase) {
      final value = json[snakeCase] ?? json[camelCase];
      return value?.toString();
    }

    // Parse booking date - handle both snake_case and camelCase
    final bookingDateStr = json['booking_date'] ?? json['bookingDate'];
    final createdAtStr = json['created_at'] ?? json['createdAt'];

    return BookingModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      serviceId: getStringField('service_id', 'serviceId') ?? '',
      serviceName: getStringField('service_name', 'serviceName') ?? '',
      serviceImage: getStringField('service_image', 'serviceImage') ?? '',
      providerId: getStringField('provider_id', 'providerId') ?? '',
      userId: getStringField('user_id', 'userId') ?? '',
      customerName: getStringField('customer_name', 'customerName') ?? '',
      customerEmail: getStringField('customer_email', 'customerEmail') ?? '',
      customerPhone: getStringField('customer_phone', 'customerPhone') ?? '',
      bookingDate: bookingDateStr != null
          ? DateTime.parse(bookingDateStr.toString())
          : DateTime.now(),
      createdAt: createdAtStr != null
          ? DateTime.parse(createdAtStr.toString())
          : DateTime.now(),
      status: BookingStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => BookingStatus.pending,
      ),
      totalAmount: json['total_amount'] != null
          ? (json['total_amount'] as num).toDouble()
          : json['totalAmount'] != null
              ? (json['totalAmount'] as num).toDouble()
              : 0.0,
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) => e.toString().split('.').last == (json['payment_status'] ?? json['paymentStatus']),
        orElse: () => PaymentStatus.pending,
      ),
      notes: json['notes']?.toString(),
      specialRequests: getStringField('special_requests', 'specialRequests'),
      serviceCategory: getStringField('service_category', 'serviceCategory'),
      eventType: getStringField('event_type', 'eventType') ?? '',
      guestCount: json['guest_count'] as int? ?? json['guestCount'] as int? ?? 0,
      eventLocation: getStringField('event_location', 'eventLocation') ?? '',
      discountPercentage: json['discount_percentage'] != null
          ? (json['discount_percentage'] as num).toDouble()
          : json['discountPercentage'] != null
              ? (json['discountPercentage'] as num).toDouble()
              : null,
      timeSlot: getStringField('time_slot', 'timeSlot') ?? 'morning',
      paymentMethod: getStringField('payment_method', 'paymentMethod') ?? 'cash',
      selectedSectionId: getStringField('selected_section_id', 'selectedSectionId'),
      selectedOptionIds: json['selected_option_id'] != null
          ? (json['selected_option_id'] as List).map((e) => e.toString()).toList()
          : json['selectedOptionIds'] != null
              ? (json['selectedOptionIds'] as List).map((e) => e.toString()).toList()
              : null,
      hasReviewed: json['has_reviewed'] as bool? ?? json['hasReviewed'] as bool? ?? false,
      reviewId: getStringField('review_id', 'reviewId'),
      reviewRating: json['review_rating'] != null
          ? (json['review_rating'] as num).toDouble()
          : json['reviewRating'] != null
              ? (json['reviewRating'] as num).toDouble()
              : null,
      reviewComment: getStringField('review_comment', 'reviewComment'),
      serviceType: getStringField('service_type', 'serviceType') ?? 'service',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'serviceImage': serviceImage,
      'providerId': providerId,
      'userId': userId,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'customerPhone': customerPhone,
      'bookingDate': bookingDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'status': status.toString().split('.').last,
      'totalAmount': totalAmount,
      'paymentStatus': paymentStatus.toString().split('.').last,
      'notes': notes,
      'specialRequests': specialRequests,
      'serviceCategory': serviceCategory,
      'eventType': eventType,
      'guestCount': guestCount,
      'eventLocation': eventLocation,
      'discountPercentage': discountPercentage,
      'timeSlot': timeSlot,
      'paymentMethod': paymentMethod,
      'selectedSectionId': selectedSectionId,
      'selectedOptionIds': selectedOptionIds,
      'hasReviewed': hasReviewed,
      'reviewId': reviewId,
      'reviewRating': reviewRating,
      'reviewComment': reviewComment,
      'serviceType': serviceType,
    };
  }

  BookingModel copyWith({
    String? id,
    String? serviceId,
    String? serviceName,
    String? serviceImage,
    String? providerId,
    String? userId,
    String? customerName,
    String? customerEmail,
    String? customerPhone,
    DateTime? bookingDate,
    DateTime? createdAt,
    BookingStatus? status,
    double? totalAmount,
    PaymentStatus? paymentStatus,
    String? notes,
    String? specialRequests,
    String? serviceCategory,
    String? eventType,
    int? guestCount,
    String? eventLocation,
    double? discountPercentage,
    String? timeSlot,
    String? paymentMethod,
    String? selectedSectionId,
    List<String>? selectedOptionIds,
    bool? hasReviewed,
    String? reviewId,
    double? reviewRating,
    String? reviewComment,
    String? serviceType,
  }) {
    return BookingModel(
      id: id ?? this.id,
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      serviceImage: serviceImage ?? this.serviceImage,
      providerId: providerId ?? this.providerId,
      userId: userId ?? this.userId,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      customerPhone: customerPhone ?? this.customerPhone,
      bookingDate: bookingDate ?? this.bookingDate,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      notes: notes ?? this.notes,
      specialRequests: specialRequests ?? this.specialRequests,
      serviceCategory: serviceCategory ?? this.serviceCategory,
      eventType: eventType ?? this.eventType,
      guestCount: guestCount ?? this.guestCount,
      eventLocation: eventLocation ?? this.eventLocation,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      timeSlot: timeSlot ?? this.timeSlot,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      selectedSectionId: selectedSectionId ?? this.selectedSectionId,
      selectedOptionIds: selectedOptionIds ?? this.selectedOptionIds,
      hasReviewed: hasReviewed ?? this.hasReviewed,
      reviewId: reviewId ?? this.reviewId,
      reviewRating: reviewRating ?? this.reviewRating,
      reviewComment: reviewComment ?? this.reviewComment,
      serviceType: serviceType ?? this.serviceType,
    );
  }

  /// Helper method to determine if this booking is for a venue
  /// Returns 'venue' if serviceCategory is 'venue', otherwise returns 'service'
  String get reviewTargetType {
    return serviceCategory?.toLowerCase() == 'venue' ? 'venue' : serviceType;
  }

  @override
  List<Object?> get props => [
        id,
        serviceId,
        serviceName,
        serviceImage,
        providerId,
        userId,
        customerName,
        customerEmail,
        customerPhone,
        bookingDate,
        createdAt,
        status,
        totalAmount,
        paymentStatus,
        notes,
        specialRequests,
        serviceCategory,
        eventType,
        guestCount,
        eventLocation,
        discountPercentage,
        timeSlot,
        paymentMethod,
        selectedSectionId,
        selectedOptionIds,
        hasReviewed,
        reviewId,
        reviewRating,
        reviewComment,
        serviceType,
      ];
}
