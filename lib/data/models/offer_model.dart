import 'package:equatable/equatable.dart';
import 'package:wedly/data/models/service_model.dart';

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
  final String providerId; // Provider who created the offer
  final String providerName; // Provider name in Arabic
  final String serviceType; // Type of service (decoration, photography, etc.)
  final double originalPrice; // Original price before discount
  final double discountedPrice; // Price after discount
  final double rating; // Provider rating
  final int reviewCount; // Number of reviews

  const OfferModel({
    required this.id,
    required this.title,
    required this.titleAr,
    required this.description,
    required this.descriptionAr,
    required this.imageUrl,
    required this.providerId,
    required this.providerName,
    required this.serviceType,
    required this.originalPrice,
    required this.discountedPrice,
    this.discount,
    this.expiryDate,
    this.serviceId,
    this.rating = 4.8,
    this.reviewCount = 200,
  });

  /// Check if offer is still valid (not expired and has an actual discount)
  bool get isValid {
    // Expired offers are invalid
    if (expiryDate != null && DateTime.now().isAfter(expiryDate!)) return false;
    // 0% or no discount means the offer was removed/disabled
    if (originalPrice > 0 && discountedPrice >= originalPrice) return false;
    if (discountedPrice <= 0 && originalPrice <= 0) return false;
    if (discount == '0%' || discount == '-0%' || discount == '0' || discount == '%0') return false;
    return true;
  }

  /// Convert offer to a ServiceModel for booking screens that don't support offers yet
  /// This is a temporary solution until all booking screens are updated
  ServiceModel toService() {
    // Check if this is a venue offer (service type contains 'venue' or 'قاعات')
    final isVenue = serviceType.toLowerCase().contains('venue') ||
                    serviceType.toLowerCase().contains('قاعات') ||
                    serviceType.toLowerCase().contains('hall');

    return ServiceModel(
      id: serviceId ?? id,
      name: titleAr,
      description: descriptionAr,
      imageUrl: imageUrl,
      price: isVenue ? null : discountedPrice, // Venues don't use 'price' field
      category: serviceType,
      providerId: providerId,
      rating: rating,
      reviewCount: reviewCount,
      // Venue-specific fields
      morningPrice: isVenue ? discountedPrice : null,
      eveningPrice: isVenue ? discountedPrice : null,
      chairCount: isVenue ? 500 : null, // Default capacity for venue offers
      hasOffer: true,
      offerApproved: true,
      discountPercentage: ((originalPrice - discountedPrice) / originalPrice * 100),
      offerExpiryDate: expiryDate,
    );
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
        providerId,
        providerName,
        serviceType,
        originalPrice,
        discountedPrice,
        rating,
        reviewCount,
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
    String? providerId,
    String? providerName,
    String? serviceType,
    double? originalPrice,
    double? discountedPrice,
    double? rating,
    int? reviewCount,
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
      providerId: providerId ?? this.providerId,
      providerName: providerName ?? this.providerName,
      serviceType: serviceType ?? this.serviceType,
      originalPrice: originalPrice ?? this.originalPrice,
      discountedPrice: discountedPrice ?? this.discountedPrice,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
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
      providerId: json['provider_id']?.toString() ?? '',
      providerName: json['provider_name'] as String? ?? '',
      serviceType: json['service_type'] as String? ?? '',
      originalPrice: (json['original_price'] as num?)?.toDouble() ?? 0.0,
      discountedPrice: (json['discounted_price'] as num?)?.toDouble() ?? 0.0,
      rating: (json['rating'] as num?)?.toDouble() ?? 4.8,
      reviewCount: json['review_count'] as int? ?? 200,
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
      'provider_id': providerId,
      'provider_name': providerName,
      'service_type': serviceType,
      'original_price': originalPrice,
      'discounted_price': discountedPrice,
      'rating': rating,
      'review_count': reviewCount,
    };
  }
}
