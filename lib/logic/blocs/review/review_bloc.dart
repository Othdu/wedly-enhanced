import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wedly/data/repositories/review_repository.dart';
import 'package:wedly/data/services/api_exceptions.dart';
import 'package:wedly/logic/blocs/auth/auth_bloc.dart';
import 'package:wedly/logic/blocs/auth/auth_state.dart';
import 'package:wedly/logic/blocs/review/review_event.dart';
import 'package:wedly/logic/blocs/review/review_state.dart';

/// BLoC for managing review operations
/// Handles fetching, submitting, updating, and deleting reviews
class ReviewBloc extends Bloc<ReviewEvent, ReviewState> {
  final ReviewRepository reviewRepository;
  final AuthBloc authBloc;

  ReviewBloc({
    required this.reviewRepository,
    required this.authBloc,
  }) : super(const ReviewInitial()) {
    // Register event handlers
    on<VenueReviewsRequested>(_onVenueReviewsRequested);
    on<ServiceReviewsRequested>(_onServiceReviewsRequested);
    on<ReviewSubmitted>(_onReviewSubmitted);
    on<ReviewUpdated>(_onReviewUpdated);
    on<ReviewDeleted>(_onReviewDeleted);
    on<UserReviewsRequested>(_onUserReviewsRequested);
    on<ReviewsRefreshed>(_onReviewsRefreshed);
  }

  /// Handle fetching venue reviews
  Future<void> _onVenueReviewsRequested(
    VenueReviewsRequested event,
    Emitter<ReviewState> emit,
  ) async {
    try {
      emit(const ReviewsLoading());

      final reviews = await reviewRepository.getVenueReviews(event.venueId);

      if (reviews.isEmpty) {
        emit(const ReviewsEmpty());
        return;
      }

      final averageRating = reviewRepository.calculateAverageRating(reviews);

      emit(ReviewsLoaded(
        reviews: reviews,
        averageRating: averageRating,
        totalReviews: reviews.length,
      ));
    } catch (e) {
      emit(ReviewError(
        message: 'فشل في تحميل التقييمات: ${e.toString()}',
      ));
    }
  }

  /// Handle fetching service reviews
  Future<void> _onServiceReviewsRequested(
    ServiceReviewsRequested event,
    Emitter<ReviewState> emit,
  ) async {
    try {
      emit(const ReviewsLoading());

      final reviews = await reviewRepository.getServiceReviews(event.serviceId);

      if (reviews.isEmpty) {
        emit(const ReviewsEmpty());
        return;
      }

      final averageRating = reviewRepository.calculateAverageRating(reviews);

      emit(ReviewsLoaded(
        reviews: reviews,
        averageRating: averageRating,
        totalReviews: reviews.length,
      ));
    } catch (e) {
      emit(ReviewError(
        message: 'فشل في تحميل التقييمات: ${e.toString()}',
      ));
    }
  }

  /// Handle submitting a new review
  Future<void> _onReviewSubmitted(
    ReviewSubmitted event,
    Emitter<ReviewState> emit,
  ) async {
    // Store current state to restore if needed
    final previousState = state;

    try {
      emit(const ReviewSubmitting());

      // Get user info from AuthBloc
      final authState = authBloc.state;
      if (authState is! AuthAuthenticated) {
        emit(const ReviewError(message: 'يجب تسجيل الدخول لإضافة تقييم'));
        return;
      }

      final user = authState.user;
      final review = await reviewRepository.submitReview(
        targetId: event.targetId,
        targetType: event.targetType,
        userId: user.id,
        userName: user.name,
        userImageUrl: user.profileImageUrl,
        rating: event.rating,
        comment: event.comment,
      );

      emit(ReviewSubmitSuccess(review: review));

      // After successful submission, reload reviews
      await Future.delayed(const Duration(milliseconds: 500));
      if (event.targetType == 'venue') {
        add(VenueReviewsRequested(event.targetId));
      } else {
        add(ServiceReviewsRequested(event.targetId));
      }
    } on DuplicateReviewException {
      // User already submitted a review - offer to edit instead
      emit(ReviewDuplicateDetected(
        targetId: event.targetId,
        targetType: event.targetType,
      ));
    } catch (e) {
      emit(ReviewError(
        message: 'فشل في إضافة التقييم: ${e.toString()}',
      ));
      // Restore previous state after error
      await Future.delayed(const Duration(seconds: 2));
      if (previousState is ReviewsLoaded) {
        emit(previousState);
      }
    }
  }

  /// Handle updating an existing review
  Future<void> _onReviewUpdated(
    ReviewUpdated event,
    Emitter<ReviewState> emit,
  ) async {
    final previousState = state;

    try {
      emit(const ReviewUpdating());

      final updatedReview = await reviewRepository.updateReview(
        reviewId: event.reviewId,
        rating: event.rating,
        comment: event.comment,
      );

      emit(ReviewUpdateSuccess(review: updatedReview));

      // After successful update, restore the reviews list with updated review
      await Future.delayed(const Duration(milliseconds: 500));
      if (previousState is ReviewsLoaded) {
        final updatedReviews = previousState.reviews.map((review) {
          return review.id == updatedReview.id ? updatedReview : review;
        }).toList();

        final averageRating =
            reviewRepository.calculateAverageRating(updatedReviews);

        emit(ReviewsLoaded(
          reviews: updatedReviews,
          averageRating: averageRating,
          totalReviews: updatedReviews.length,
        ));
      }
    } catch (e) {
      emit(ReviewError(
        message: 'فشل في تحديث التقييم: ${e.toString()}',
      ));
      // Restore previous state after error
      await Future.delayed(const Duration(seconds: 2));
      if (previousState is ReviewsLoaded) {
        emit(previousState);
      }
    }
  }

  /// Handle deleting a review
  Future<void> _onReviewDeleted(
    ReviewDeleted event,
    Emitter<ReviewState> emit,
  ) async {
    final previousState = state;

    try {
      emit(const ReviewDeleting());

      await reviewRepository.deleteReview(event.reviewId);

      emit(ReviewDeleteSuccess(reviewId: event.reviewId));

      // After successful deletion, update the reviews list
      await Future.delayed(const Duration(milliseconds: 500));
      if (previousState is ReviewsLoaded) {
        final remainingReviews = previousState.reviews
            .where((review) => review.id != event.reviewId)
            .toList();

        if (remainingReviews.isEmpty) {
          emit(const ReviewsEmpty());
        } else {
          final averageRating =
              reviewRepository.calculateAverageRating(remainingReviews);

          emit(ReviewsLoaded(
            reviews: remainingReviews,
            averageRating: averageRating,
            totalReviews: remainingReviews.length,
          ));
        }
      }
    } catch (e) {
      emit(ReviewError(
        message: 'فشل في حذف التقييم: ${e.toString()}',
      ));
      // Restore previous state after error
      await Future.delayed(const Duration(seconds: 2));
      if (previousState is ReviewsLoaded) {
        emit(previousState);
      }
    }
  }

  /// Handle fetching user's reviews
  Future<void> _onUserReviewsRequested(
    UserReviewsRequested event,
    Emitter<ReviewState> emit,
  ) async {
    try {
      emit(const ReviewsLoading());

      // Get user ID from AuthBloc
      final authState = authBloc.state;
      if (authState is! AuthAuthenticated) {
        emit(const ReviewError(message: 'يجب تسجيل الدخول لعرض التقييمات'));
        return;
      }

      final reviews = await reviewRepository.getUserReviews(authState.user.id);

      if (reviews.isEmpty) {
        emit(const ReviewsEmpty(
          message: 'ليس لديك تقييمات بعد',
        ));
        return;
      }

      final averageRating = reviewRepository.calculateAverageRating(reviews);

      emit(ReviewsLoaded(
        reviews: reviews,
        averageRating: averageRating,
        totalReviews: reviews.length,
      ));
    } catch (e) {
      emit(ReviewError(
        message: 'فشل في تحميل تقييماتك: ${e.toString()}',
      ));
    }
  }

  /// Handle refreshing reviews (pull to refresh)
  Future<void> _onReviewsRefreshed(
    ReviewsRefreshed event,
    Emitter<ReviewState> emit,
  ) async {
    // Keep current reviews visible while refreshing
    if (state is ReviewsLoaded) {
      emit(ReviewsRefreshing((state as ReviewsLoaded).reviews));
    }

    try {
      final reviews = event.targetType == 'venue'
          ? await reviewRepository.getVenueReviews(event.targetId)
          : await reviewRepository.getServiceReviews(event.targetId);

      if (reviews.isEmpty) {
        emit(const ReviewsEmpty());
        return;
      }

      final averageRating = reviewRepository.calculateAverageRating(reviews);

      emit(ReviewsLoaded(
        reviews: reviews,
        averageRating: averageRating,
        totalReviews: reviews.length,
      ));
    } catch (e) {
      emit(ReviewError(
        message: 'فشل في تحديث التقييمات: ${e.toString()}',
      ));
    }
  }
}
