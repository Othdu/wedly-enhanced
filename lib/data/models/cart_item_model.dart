import 'package:equatable/equatable.dart';
import 'package:wedly/data/models/service_model.dart';

class CartItemModel extends Equatable {
  final String id;
  final ServiceModel service;
  final String date; // e.g., "15 نوفمبر"
  final String time; // e.g., "الساعة 8:00 مساءً"
  final double servicePrice; // Main service price
  final double photographerPrice; // Optional photographer price
  final double serviceCharge; // Service charge (ضريبة)
  final DateTime addedAt;

  const CartItemModel({
    required this.id,
    required this.service,
    required this.date,
    required this.time,
    required this.servicePrice,
    this.photographerPrice = 0,
    this.serviceCharge = 100, // Default service charge
    required this.addedAt,
  });

  double get totalPrice => servicePrice + photographerPrice + serviceCharge;

  @override
  List<Object?> get props => [
        id,
        service,
        date,
        time,
        servicePrice,
        photographerPrice,
        serviceCharge,
        addedAt,
      ];

  CartItemModel copyWith({
    String? id,
    ServiceModel? service,
    String? date,
    String? time,
    double? servicePrice,
    double? photographerPrice,
    double? serviceCharge,
    DateTime? addedAt,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      service: service ?? this.service,
      date: date ?? this.date,
      time: time ?? this.time,
      servicePrice: servicePrice ?? this.servicePrice,
      photographerPrice: photographerPrice ?? this.photographerPrice,
      serviceCharge: serviceCharge ?? this.serviceCharge,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  // JSON serialization
  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'].toString(),
      service: ServiceModel.fromJson(json['service'] as Map<String, dynamic>),
      date: json['date'] as String,
      time: json['time'] as String,
      servicePrice: (json['service_price'] as num).toDouble(),
      photographerPrice: json['photographer_price'] != null
          ? (json['photographer_price'] as num).toDouble()
          : 0,
      serviceCharge: json['service_charge'] != null
          ? (json['service_charge'] as num).toDouble()
          : 100,
      addedAt: DateTime.parse(json['added_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'service': service.toJson(),
      'date': date,
      'time': time,
      'service_price': servicePrice,
      'photographer_price': photographerPrice,
      'service_charge': serviceCharge,
      'added_at': addedAt.toIso8601String(),
    };
  }
}
