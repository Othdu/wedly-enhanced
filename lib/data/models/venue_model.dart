import 'package:equatable/equatable.dart';

/// Model representing a wedding venue (قاعة أفراح)
/// Venues are specialized services with specific pricing and capacity information
class VenueModel extends Equatable {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final List<String>? imageUrls; // Multiple images
  final double rating;
  final int reviewCount;
  final int capacity; // Maximum number of chairs/guests
  final double pricePerPerson; // Price per person in EGP
  final String providerId;
  final String? address;
  final double? latitude;
  final double? longitude;
  final bool isActive;
  final bool isPendingApproval;

  // TODO: API Integration - These fields will be populated from the admin dashboard
  // Endpoint: GET /api/venues
  // Endpoint: POST /api/admin/venues (admin creates new venue)
  // Endpoint: PUT /api/provider/venues/:id (provider edits their venue)

  const VenueModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    this.imageUrls,
    required this.rating,
    required this.reviewCount,
    required this.capacity,
    required this.pricePerPerson,
    required this.providerId,
    this.address,
    this.latitude,
    this.longitude,
    this.isActive = true,
    this.isPendingApproval = false,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        imageUrl,
        imageUrls,
        rating,
        reviewCount,
        capacity,
        pricePerPerson,
        providerId,
        address,
        latitude,
        longitude,
        isActive,
        isPendingApproval,
      ];

  VenueModel copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    List<String>? imageUrls,
    double? rating,
    int? reviewCount,
    int? capacity,
    double? pricePerPerson,
    String? providerId,
    String? address,
    double? latitude,
    double? longitude,
    bool? isActive,
    bool? isPendingApproval,
  }) {
    return VenueModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      imageUrls: imageUrls ?? this.imageUrls,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      capacity: capacity ?? this.capacity,
      pricePerPerson: pricePerPerson ?? this.pricePerPerson,
      providerId: providerId ?? this.providerId,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isActive: isActive ?? this.isActive,
      isPendingApproval: isPendingApproval ?? this.isPendingApproval,
    );
  }

  // JSON serialization for API integration
  // TODO: API Integration - Implement when connecting to real backend
  factory VenueModel.fromJson(Map<String, dynamic> json) {
    return VenueModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? json['imageUrl'] as String? ?? '',
      imageUrls: json['image_urls'] != null
          ? List<String>.from(json['image_urls'] as List)
          : null,
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : 0.0,
      reviewCount: json['review_count'] as int? ?? json['reviewCount'] as int? ?? 0,
      capacity: json['capacity'] as int? ?? 0,
      pricePerPerson: json['price_per_person'] != null
          ? (json['price_per_person'] as num).toDouble()
          : json['pricePerPerson'] != null
              ? (json['pricePerPerson'] as num).toDouble()
              : 0.0,
      providerId: json['provider_id'] as String? ?? json['providerId'] as String? ?? '',
      address: json['address'] as String?,
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
      isActive: json['is_active'] as bool? ?? json['isActive'] as bool? ?? true,
      isPendingApproval: json['is_pending_approval'] as bool? ??
          json['isPendingApproval'] as bool? ??
          false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'image_urls': imageUrls,
      'rating': rating,
      'review_count': reviewCount,
      'capacity': capacity,
      'price_per_person': pricePerPerson,
      'provider_id': providerId,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'is_active': isActive,
      'is_pending_approval': isPendingApproval,
    };
  }
}
