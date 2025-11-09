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
  final String eventType;
  final int guestCount;
  final String eventLocation;

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
    required this.eventType,
    required this.guestCount,
    required this.eventLocation,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] as String,
      serviceId: json['serviceId'] as String,
      serviceName: json['serviceName'] as String,
      serviceImage: json['serviceImage'] as String,
      providerId: json['providerId'] as String,
      userId: json['userId'] as String,
      customerName: json['customerName'] as String,
      customerEmail: json['customerEmail'] as String,
      customerPhone: json['customerPhone'] as String,
      bookingDate: DateTime.parse(json['bookingDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      status: BookingStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
      ),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['paymentStatus'],
      ),
      notes: json['notes'] as String?,
      specialRequests: json['specialRequests'] as String?,
      eventType: json['eventType'] as String,
      guestCount: json['guestCount'] as int,
      eventLocation: json['eventLocation'] as String,
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
      'eventType': eventType,
      'guestCount': guestCount,
      'eventLocation': eventLocation,
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
    String? eventType,
    int? guestCount,
    String? eventLocation,
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
      eventType: eventType ?? this.eventType,
      guestCount: guestCount ?? this.guestCount,
      eventLocation: eventLocation ?? this.eventLocation,
    );
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
        eventType,
        guestCount,
        eventLocation,
      ];
}
