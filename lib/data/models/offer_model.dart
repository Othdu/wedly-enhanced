import 'package:equatable/equatable.dart';

/// Model representing a promotional offer
class OfferModel extends Equatable {
  final String id;
  final String title;
  final String titleAr;
  final String description;
  final String descriptionAr;
  final String imageUrl;
  final String? discount; // e.g., "خصم %30"
  final DateTime? expiryDate;
  final String? serviceId; // Optional link to a specific service

  const OfferModel({
    required this.id,
    required this.title,
    required this.titleAr,
    required this.description,
    required this.descriptionAr,
    required this.imageUrl,
    this.discount,
    this.expiryDate,
    this.serviceId,
  });

  /// Check if offer is still valid
  bool get isValid {
    if (expiryDate == null) return true;
    return DateTime.now().isBefore(expiryDate!);
  }

  @override
  List<Object?> get props => [
        id,
        title,
        titleAr,
        description,
        descriptionAr,
        imageUrl,
        discount,
        expiryDate,
        serviceId,
      ];

  OfferModel copyWith({
    String? id,
    String? title,
    String? titleAr,
    String? description,
    String? descriptionAr,
    String? imageUrl,
    String? discount,
    DateTime? expiryDate,
    String? serviceId,
  }) {
    return OfferModel(
      id: id ?? this.id,
      title: title ?? this.title,
      titleAr: titleAr ?? this.titleAr,
      description: description ?? this.description,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      imageUrl: imageUrl ?? this.imageUrl,
      discount: discount ?? this.discount,
      expiryDate: expiryDate ?? this.expiryDate,
      serviceId: serviceId ?? this.serviceId,
    );
  }

  // JSON serialization
  factory OfferModel.fromJson(Map<String, dynamic> json) {
    return OfferModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      titleAr: json['title_ar'] as String? ?? json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      descriptionAr: json['description_ar'] as String? ?? json['description'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
      discount: json['discount'] as String?,
      expiryDate: json['expiry_date'] != null
          ? DateTime.parse(json['expiry_date'] as String)
          : null,
      serviceId: json['service_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'title_ar': titleAr,
      'description': description,
      'description_ar': descriptionAr,
      'image_url': imageUrl,
      'discount': discount,
      'expiry_date': expiryDate?.toIso8601String(),
      'service_id': serviceId,
    };
  }
}
