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
  final String timeSlot; // "morning" or "evening" - for venues from user selection, "morning" for other services
  final String? selectedSectionId; // Selected section ID from dynamic sections
  final List<String>? selectedOptionIds; // Selected option IDs from dynamic sections

  const CartItemModel({
    required this.id,
    required this.service,
    required this.date,
    required this.time,
    required this.servicePrice,
    this.photographerPrice = 0,
    required this.addedAt,
    this.timeSlot = 'morning',
    this.selectedSectionId,
    this.selectedOptionIds,
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
        timeSlot,
        selectedSectionId,
        selectedOptionIds,
      ];

  CartItemModel copyWith({
    String? id,
    ServiceModel? service,
    String? date,
    String? time,
    double? servicePrice,
    double? photographerPrice,
    DateTime? addedAt,
    String? timeSlot,
    String? selectedSectionId,
    List<String>? selectedOptionIds,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      service: service ?? this.service,
      date: date ?? this.date,
      time: time ?? this.time,
      servicePrice: servicePrice ?? this.servicePrice,
      photographerPrice: photographerPrice ?? this.photographerPrice,
      addedAt: addedAt ?? this.addedAt,
      timeSlot: timeSlot ?? this.timeSlot,
      selectedSectionId: selectedSectionId ?? this.selectedSectionId,
      selectedOptionIds: selectedOptionIds ?? this.selectedOptionIds,
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

    // Debug: Print time_slot value from JSON
    final rawTimeSlot = json['time_slot'];
    print('🔍 CartItemModel.fromJson - raw time_slot: "$rawTimeSlot" (type: ${rawTimeSlot?.runtimeType})');
    final timeSlot = json['time_slot'] as String? ?? 'morning';
    print('🔍 CartItemModel.fromJson - parsed timeSlot: "$timeSlot"');

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
      timeSlot: timeSlot,
      selectedSectionId: json['selected_section_id'] as String?,
      selectedOptionIds: json['selected_option_ids'] != null
          ? (json['selected_option_ids'] as List).map((e) => e.toString()).toList()
          : null,
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
      'time_slot': timeSlot,
      'selected_section_id': selectedSectionId,
      'selected_option_ids': selectedOptionIds,
    };
  }
}
