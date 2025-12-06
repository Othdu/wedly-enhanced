import 'package:equatable/equatable.dart';

/// Model representing a promotional banner shown in the app
/// Banners are configured by admin and can optionally link to external URLs
class BannerModel extends Equatable {
  final String id;
  final String imageUrl;
  final String? link; // Optional external link
  final String? title; // Optional title overlay
  final String? titleAr; // Optional Arabic title overlay
  final int order; // Display order (lower = shown first)
  final bool isActive; // Whether banner is currently active

  const BannerModel({
    required this.id,
    required this.imageUrl,
    this.link,
    this.title,
    this.titleAr,
    this.order = 0,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [id, imageUrl, link, title, titleAr, order, isActive];

  BannerModel copyWith({
    String? id,
    String? imageUrl,
    String? link,
    String? title,
    String? titleAr,
    int? order,
    bool? isActive,
  }) {
    return BannerModel(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      link: link ?? this.link,
      title: title ?? this.title,
      titleAr: titleAr ?? this.titleAr,
      order: order ?? this.order,
      isActive: isActive ?? this.isActive,
    );
  }

  // JSON serialization
  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id']?.toString() ?? '',
      imageUrl: json['image_url'] as String? ?? '',
      link: json['link'] as String?,
      title: json['title'] as String?,
      titleAr: json['title_ar'] as String?,
      order: json['order'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image_url': imageUrl,
      'link': link,
      'title': title,
      'title_ar': titleAr,
      'order': order,
      'is_active': isActive,
    };
  }
}
