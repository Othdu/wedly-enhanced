import 'package:equatable/equatable.dart';

/// Model representing a user review for a venue or service
/// Reviews include rating, comment, user info, and timestamp
class ReviewModel extends Equatable {
  final String id;
  final String venueId; // or serviceId
  final String userId;
  final String userName;
  final String? userImageUrl;
  final double rating; // 1-5 stars
  final String comment;
  final DateTime createdAt;

  const ReviewModel({
    required this.id,
    required this.venueId,
    required this.userId,
    required this.userName,
    this.userImageUrl,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        venueId,
        userId,
        userName,
        userImageUrl,
        rating,
        comment,
        createdAt,
      ];

  ReviewModel copyWith({
    String? id,
    String? venueId,
    String? userId,
    String? userName,
    String? userImageUrl,
    double? rating,
    String? comment,
    DateTime? createdAt,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      venueId: venueId ?? this.venueId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userImageUrl: userImageUrl ?? this.userImageUrl,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // JSON serialization for API integration
  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id']?.toString() ?? '',
      venueId: json['venue_id'] as String? ?? json['venueId'] as String? ?? '',
      userId: json['user_id'] as String? ?? json['userId'] as String? ?? '',
      userName: json['user_name'] as String? ?? json['userName'] as String? ?? '',
      userImageUrl: json['user_image_url'] as String? ?? json['userImageUrl'] as String?,
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : 0.0,
      comment: json['comment'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : json['createdAt'] != null
              ? DateTime.parse(json['createdAt'] as String)
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'venue_id': venueId,
      'user_id': userId,
      'user_name': userName,
      'user_image_url': userImageUrl,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
