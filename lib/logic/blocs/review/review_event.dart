import 'package:equatable/equatable.dart';

/// Base class for all review-related events
abstract class ReviewEvent extends Equatable {
  const ReviewEvent();

  @override
  List<Object?> get props => [];
}

/// Event to fetch reviews for a specific venue
class VenueReviewsRequested extends ReviewEvent {
  final String venueId;

  const VenueReviewsRequested(this.venueId);

  @override
  List<Object?> get props => [venueId];
}

/// Event to fetch reviews for a specific service
class ServiceReviewsRequested extends ReviewEvent {
  final String serviceId;

  const ServiceReviewsRequested(this.serviceId);

  @override
  List<Object?> get props => [serviceId];
}

/// Event to submit a new review
class ReviewSubmitted extends ReviewEvent {
  final String targetId; // venue or service ID
  final String targetType; // 'venue' or 'service'
  final double rating;
  final String comment;

  const ReviewSubmitted({
    required this.targetId,
    required this.targetType,
    required this.rating,
    required this.comment,
  });

  @override
  List<Object?> get props => [targetId, targetType, rating, comment];
}

/// Event to update an existing review
class ReviewUpdated extends ReviewEvent {
  final String reviewId;
  final double rating;
  final String comment;

  const ReviewUpdated({
    required this.reviewId,
    required this.rating,
    required this.comment,
  });

  @override
  List<Object?> get props => [reviewId, rating, comment];
}

/// Event to delete a review
class ReviewDeleted extends ReviewEvent {
  final String reviewId;

  const ReviewDeleted(this.reviewId);

  @override
  List<Object?> get props => [reviewId];
}

/// Event to fetch reviews by current user
class UserReviewsRequested extends ReviewEvent {
  const UserReviewsRequested();
}

/// Event to refresh reviews (pull to refresh)
class ReviewsRefreshed extends ReviewEvent {
  final String targetId;
  final String targetType; // 'venue' or 'service'

  const ReviewsRefreshed({
    required this.targetId,
    required this.targetType,
  });

  @override
  List<Object?> get props => [targetId, targetType];
}
