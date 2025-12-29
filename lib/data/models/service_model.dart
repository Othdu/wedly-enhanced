import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:wedly/data/models/venue_model.dart';

class ServiceModel extends Equatable {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final double? price;
  final String category;
  final bool isActive;
  final double? discountPercentage; // Optional discount percentage (0-100)
  final bool hasOffer; // Whether this service has an active offer
  final bool offerApproved; // Whether the offer is approved by admin
  final DateTime? offerExpiryDate; // Offer expiration date
  final String providerId; // Provider who owns this service
  final List<String>? imageUrls; // Multiple images (API will upload)
  final double? morningPrice; // Price for morning time slot (صباحي)
  final double? eveningPrice; // Price for evening time slot (مسائي)
  final int? chairCount; // Number of chairs for venue services
  final String? city; // City where service is available
  final double? latitude; // Service location (from Google Maps)
  final double? longitude; // Service location (from Google Maps)
  final String? address; // Human-readable address
  final bool isPendingApproval; // For admin approval workflow
  final double? rating; // Average rating from users
  final int? reviewCount; // Number of reviews
  final File? imageFile; // Image file for service creation (not persisted)
  final List<Map<String, dynamic>>? dynamicSections; // Dynamic pricing sections from API

  const ServiceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    this.price,
    required this.category,
    this.isActive = true,
    this.discountPercentage,
    this.hasOffer = false,
    this.offerApproved = false,
    this.offerExpiryDate,
    required this.providerId,
    this.imageUrls,
    this.morningPrice,
    this.eveningPrice,
    this.chairCount,
    this.city,
    this.latitude,
    this.longitude,
    this.address,
    this.isPendingApproval = false,
    this.rating,
    this.reviewCount,
    this.imageFile,
    this.dynamicSections,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        imageUrl,
        price,
        category,
        isActive,
        discountPercentage,
        hasOffer,
        offerApproved,
        offerExpiryDate,
        providerId,
        imageUrls,
        morningPrice,
        eveningPrice,
        chairCount,
        city,
        latitude,
        longitude,
        address,
        isPendingApproval,
        rating,
        reviewCount,
        dynamicSections,
        // Note: imageFile is intentionally excluded from props as it's transient
      ];

  ServiceModel copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    double? price,
    String? category,
    bool? isActive,
    double? discountPercentage,
    bool? hasOffer,
    bool? offerApproved,
    DateTime? offerExpiryDate,
    String? providerId,
    List<String>? imageUrls,
    double? morningPrice,
    double? eveningPrice,
    int? chairCount,
    String? city,
    double? latitude,
    double? longitude,
    String? address,
    bool? isPendingApproval,
    double? rating,
    int? reviewCount,
    File? imageFile,
    List<Map<String, dynamic>>? dynamicSections,
  }) {
    return ServiceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      category: category ?? this.category,
      isActive: isActive ?? this.isActive,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      hasOffer: hasOffer ?? this.hasOffer,
      offerApproved: offerApproved ?? this.offerApproved,
      offerExpiryDate: offerExpiryDate ?? this.offerExpiryDate,
      providerId: providerId ?? this.providerId,
      imageUrls: imageUrls ?? this.imageUrls,
      morningPrice: morningPrice ?? this.morningPrice,
      eveningPrice: eveningPrice ?? this.eveningPrice,
      chairCount: chairCount ?? this.chairCount,
      city: city ?? this.city,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      isPendingApproval: isPendingApproval ?? this.isPendingApproval,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      imageFile: imageFile ?? this.imageFile,
      dynamicSections: dynamicSections ?? this.dynamicSections,
    );
  }

  // JSON serialization
  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'].toString(),
      name: json['name'] as String,
      description: json['description'] as String,
      imageUrl: json['image_url'] as String? ?? json['imageUrl'] as String? ?? '',
      price: json['price'] != null ? (json['price'] as num).toDouble() : null,
      category: json['category'] as String,
      isActive: json['is_active'] as bool? ?? json['isActive'] as bool? ?? true,
      discountPercentage: json['discount_percentage'] != null
          ? (json['discount_percentage'] as num).toDouble()
          : null,
      hasOffer: json['has_offer'] as bool? ?? json['hasOffer'] as bool? ?? false,
      offerApproved: json['offer_approved'] as bool? ?? json['offerApproved'] as bool? ?? false,
      offerExpiryDate: json['offer_expiry_date'] != null
          ? DateTime.parse(json['offer_expiry_date'] as String)
          : null,
      providerId: json['provider_id'] as String? ?? json['providerId'] as String? ?? '',
      imageUrls: json['image_urls'] != null
          ? List<String>.from(json['image_urls'] as List)
          : null,
      morningPrice: json['morning_price'] != null
          ? (json['morning_price'] as num).toDouble()
          : null,
      eveningPrice: json['evening_price'] != null
          ? (json['evening_price'] as num).toDouble()
          : null,
      chairCount: json['chair_count'] as int?,
      city: json['city'] as String?,
      latitude: json['latitude'] != null
          ? (json['latitude'] as num).toDouble()
          : null,
      longitude: json['longitude'] != null
          ? (json['longitude'] as num).toDouble()
          : null,
      address: json['address'] as String?,
      isPendingApproval: json['is_pending_approval'] as bool? ??
                        json['isPendingApproval'] as bool? ??
                        false,
      rating: json['rating'] != null
          ? (json['rating'] as num).toDouble()
          : null,
      reviewCount: json['review_count'] as int?,
      dynamicSections: json['dynamic_sections'] != null
          ? List<Map<String, dynamic>>.from(
              (json['dynamic_sections'] as List).map(
                (section) => Map<String, dynamic>.from(section as Map),
              ),
            )
          : null,
      // imageFile is not included in JSON as it's only used for creation
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'price': price,
      'category': category,
      'is_active': isActive,
      'discount_percentage': discountPercentage,
      'has_offer': hasOffer,
      'offer_approved': offerApproved,
      'offer_expiry_date': offerExpiryDate?.toIso8601String(),
      'provider_id': providerId,
      'image_urls': imageUrls,
      'morning_price': morningPrice,
      'evening_price': eveningPrice,
      'chair_count': chairCount,
      'city': city,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'is_pending_approval': isPendingApproval,
      'rating': rating,
      'review_count': reviewCount,
      'dynamic_sections': dynamicSections,
      // imageFile is not serialized to JSON
    };
  }

  // Helper method to calculate discounted price
  double? get finalPrice {
    if (price == null) return null;
    if (hasOffer && offerApproved && discountPercentage != null && discountPercentage! > 0) {
      return price! * (1 - discountPercentage! / 100);
    }
    return price;
  }

  // Helper method to check if service has approved offer
  bool get hasApprovedOffer => hasOffer && offerApproved;

  // Convert ServiceModel to VenueModel (for venue services)
  VenueModel toVenueModel() {
    return VenueModel(
      id: id,
      name: name,
      description: description,
      imageUrl: imageUrl,
      imageUrls: imageUrls,
      rating: rating ?? 0.0,
      reviewCount: reviewCount ?? 0,
      capacity: chairCount ?? 0,
      pricePerPerson: price ?? 0.0,
      morningPrice: morningPrice,
      eveningPrice: eveningPrice,
      providerId: providerId,
      address: address,
      latitude: latitude,
      longitude: longitude,
      isActive: isActive,
      isPendingApproval: isPendingApproval,
    );
  }
}

