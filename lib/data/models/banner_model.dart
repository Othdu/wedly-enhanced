import 'package:equatable/equatable.dart';

/// Model representing a promotional banner shown in the app
/// Banners are configured by admin and can optionally link to external URLs
class BannerModel extends Equatable {
  final String id;
  final String imageUrl;
  final String? link; // Optional external link
  final bool isActive; // Whether banner is currently active
  final DateTime? expirationDate; // Optional expiration date
  final DateTime? createdAt; // Creation timestamp
  final DateTime? updatedAt; // Last update timestamp

  const BannerModel({
    required this.id,
    required this.imageUrl,
    this.link,
    this.isActive = true,
    this.expirationDate,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [id, imageUrl, link, isActive, expirationDate, createdAt, updatedAt];

  BannerModel copyWith({
    String? id,
    String? imageUrl,
    String? link,
    bool? isActive,
    DateTime? expirationDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BannerModel(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      link: link ?? this.link,
      isActive: isActive ?? this.isActive,
      expirationDate: expirationDate ?? this.expirationDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // JSON serialization
  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id']?.toString() ?? '',
      imageUrl: json['image_url'] as String? ?? '',
      link: json['link'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      expirationDate: json['expiration_date'] != null
          ? DateTime.tryParse(json['expiration_date'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image_url': imageUrl,
      if (link != null) 'link': link,
      'is_active': isActive,
      if (expirationDate != null) 'expiration_date': expirationDate!.toIso8601String(),
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }
}
