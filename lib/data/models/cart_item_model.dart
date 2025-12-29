import 'package:equatable/equatable.dart';
import 'package:wedly/data/models/service_model.dart';

class CartItemModel extends Equatable {
  final String id;
  final ServiceModel service;
  final String date; // e.g., "15 نوفمبر"
  final String time; // e.g., "الساعة 8:00 مساءً"
  final double servicePrice; // Main service price
  final double photographerPrice; // Optional photographer price
  final DateTime addedAt;

  const CartItemModel({
    required this.id,
    required this.service,
    required this.date,
    required this.time,
    required this.servicePrice,
    this.photographerPrice = 0,
    required this.addedAt,
  });

  double get totalPrice => servicePrice + photographerPrice;

  @override
  List<Object?> get props => [
        id,
        service,
        date,
        time,
        servicePrice,
        photographerPrice,
        addedAt,
      ];

  CartItemModel copyWith({
    String? id,
    ServiceModel? service,
    String? date,
    String? time,
    double? servicePrice,
    double? photographerPrice,
    DateTime? addedAt,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      service: service ?? this.service,
      date: date ?? this.date,
      time: time ?? this.time,
      servicePrice: servicePrice ?? this.servicePrice,
      photographerPrice: photographerPrice ?? this.photographerPrice,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  // JSON serialization
  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    // Handle partial service data from cart API
    final serviceJson = json['service'] as Map<String, dynamic>;
    final service = ServiceModel(
      id: serviceJson['id']?.toString() ?? '',
      name: serviceJson['name'] as String? ?? '',
      description: '', // Cart API doesn't include description
      imageUrl: serviceJson['image_url'] as String? ?? '',
      price: serviceJson['price'] != null
          ? (serviceJson['price'] as num).toDouble()
          : null,
      category: '', // Cart API doesn't include category
      providerId: '', // Cart API doesn't include provider_id
    );

    return CartItemModel(
      id: json['id'].toString(),
      service: service,
      date: json['date'] as String,
      time: json['time'] as String,
      servicePrice: (json['service_price'] as num).toDouble(),
      photographerPrice: json['photographer_price'] != null
          ? (json['photographer_price'] as num).toDouble()
          : 0,
      addedAt: DateTime.parse(json['added_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'service_id': service.id, // Send only service ID for API
      'date': date,
      'time': time,
      'service_price': servicePrice,
      'photographer_price': photographerPrice,
      'added_at': addedAt.toIso8601String(),
    };
  }
}
