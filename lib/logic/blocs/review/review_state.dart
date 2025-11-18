import 'package:equatable/equatable.dart';
import 'package:wedly/data/models/review_model.dart';

/// Base class for all review states
abstract class ReviewState extends Equatable {
  const ReviewState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any review operations
class ReviewInitial extends ReviewState {
  const ReviewInitial();
}

/// State when reviews are being loaded
class ReviewsLoading extends ReviewState {
  const ReviewsLoading();
}

/// State when reviews are successfully loaded
class ReviewsLoaded extends ReviewState {
  final List<ReviewModel> reviews;
  final double averageRating;
  final int totalReviews;

  const ReviewsLoaded({
    required this.reviews,
    required this.averageRating,
    required this.totalReviews,
  });

  @override
  List<Object?> get props => [reviews, averageRating, totalReviews];

  /// Create a copy with updated values
  ReviewsLoaded copyWith({
    List<ReviewModel>? reviews,
    double? averageRating,
    int? totalReviews,
  }) {
    return ReviewsLoaded(
      reviews: reviews ?? this.reviews,
      averageRating: averageRating ?? this.averageRating,
      totalReviews: totalReviews ?? this.totalReviews,
    );
  }
}

/// State when a review is being submitted
class ReviewSubmitting extends ReviewState {
  const ReviewSubmitting();
}

/// State when a review is successfully submitted
class ReviewSubmitSuccess extends ReviewState {
  final ReviewModel review;
  final String message;

  const ReviewSubmitSuccess({
    required this.review,
    this.message = 'تم إضافة التقييم بنجاح',
  });

  @override
  List<Object?> get props => [review, message];
}

/// State when a review is being updated
class ReviewUpdating extends ReviewState {
  const ReviewUpdating();
}

/// State when a review is successfully updated
class ReviewUpdateSuccess extends ReviewState {
  final ReviewModel review;
  final String message;

  const ReviewUpdateSuccess({
    required this.review,
    this.message = 'تم تحديث التقييم بنجاح',
  });

  @override
  List<Object?> get props => [review, message];
}

/// State when a review is being deleted
class ReviewDeleting extends ReviewState {
  const ReviewDeleting();
}

/// State when a review is successfully deleted
class ReviewDeleteSuccess extends ReviewState {
  final String reviewId;
  final String message;

  const ReviewDeleteSuccess({
    required this.reviewId,
    this.message = 'تم حذف التقييم بنجاح',
  });

  @override
  List<Object?> get props => [reviewId, message];
}

/// State when there's an error with review operations
class ReviewError extends ReviewState {
  final String message;
  final String? errorCode;

  const ReviewError({
    required this.message,
    this.errorCode,
  });

  @override
  List<Object?> get props => [message, errorCode];
}

/// State when reviews are empty (no reviews found)
class ReviewsEmpty extends ReviewState {
  final String message;

  const ReviewsEmpty({
    this.message = 'لا توجد تقييمات بعد. كن أول من يقيّم!',
  });

  @override
  List<Object?> get props => [message];
}

/// State when reviews are being refreshed
class ReviewsRefreshing extends ReviewState {
  final List<ReviewModel> currentReviews; // Keep showing current data while refreshing

  const ReviewsRefreshing(this.currentReviews);

  @override
  List<Object?> get props => [currentReviews];
}
