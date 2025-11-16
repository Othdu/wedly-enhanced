import 'package:equatable/equatable.dart';

class ServiceModel extends Equatable {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final double? price;
  final String category;
  final bool isActive;
  final double? discountPercentage; // Optional discount percentage (0-100)
  final String providerId; // Provider who owns this service
  final List<String>? imageUrls; // Multiple images (API will upload)
  final double? morningPrice; // Price for morning time slot (صباحي)
  final double? eveningPrice; // Price for evening time slot (مسائي)
  final int? chairCount; // Number of chairs for venue services
  final double? latitude; // Service location (from Google Maps)
  final double? longitude; // Service location (from Google Maps)
  final String? address; // Human-readable address
  final bool isPendingApproval; // For admin approval workflow
  final double? rating; // Average rating from users
  final int? reviewCount; // Number of reviews

  const ServiceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    this.price,
    required this.category,
    this.isActive = true,
    this.discountPercentage,
    required this.providerId,
    this.imageUrls,
    this.morningPrice,
    this.eveningPrice,
    this.chairCount,
    this.latitude,
    this.longitude,
    this.address,
    this.isPendingApproval = false,
    this.rating,
    this.reviewCount,
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
        providerId,
        imageUrls,
        morningPrice,
        eveningPrice,
        chairCount,
        latitude,
        longitude,
        address,
        isPendingApproval,
        rating,
        reviewCount,
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
    String? providerId,
    List<String>? imageUrls,
    double? morningPrice,
    double? eveningPrice,
    int? chairCount,
    double? latitude,
    double? longitude,
    String? address,
    bool? isPendingApproval,
    double? rating,
    int? reviewCount,
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
      providerId: providerId ?? this.providerId,
      imageUrls: imageUrls ?? this.imageUrls,
      morningPrice: morningPrice ?? this.morningPrice,
      eveningPrice: eveningPrice ?? this.eveningPrice,
      chairCount: chairCount ?? this.chairCount,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      isPendingApproval: isPendingApproval ?? this.isPendingApproval,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
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
      'provider_id': providerId,
      'image_urls': imageUrls,
      'morning_price': morningPrice,
      'evening_price': eveningPrice,
      'chair_count': chairCount,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'is_pending_approval': isPendingApproval,
      'rating': rating,
      'review_count': reviewCount,
    };
  }
}

