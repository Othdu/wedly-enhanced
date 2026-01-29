import 'package:wedly/data/models/review_model.dart';
import 'package:wedly/data/services/api_client.dart';
import 'package:wedly/data/services/api_constants.dart';
import 'package:wedly/data/services/api_exceptions.dart';

/// Repository for managing reviews for venues and services
class ReviewRepository {
  final ApiClient _apiClient;

  ReviewRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Fetch reviews for a specific venue
  Future<List<ReviewModel>> getVenueReviews(String venueId) async {
    final response = await _apiClient.get(
      ApiConstants.getVenueReviews(venueId),
    );
    final responseData = response.data['data'] ?? response.data;
    final reviewsList = responseData['reviews'] ?? responseData;

    return (reviewsList as List)
        .map((json) => ReviewModel.fromJson(json))
        .toList();
  }

  /// Fetch reviews for a specific service
  Future<List<ReviewModel>> getServiceReviews(String serviceId) async {
    final response = await _apiClient.get(
      ApiConstants.getServiceReviews(serviceId),
    );
    final responseData = response.data['data'] ?? response.data;
    final reviewsList = responseData['reviews'] ?? responseData;

    return (reviewsList as List)
        .map((json) => ReviewModel.fromJson(json))
        .toList();
  }

  /// Submit a new review for a venue or service
  Future<ReviewModel> submitReview({
    required String targetId,
    required String targetType,
    required String userId,
    required String userName,
    String? userImageUrl,
    required double rating,
    required String comment,
  }) async {
    // Validation - only rating is required, comment is optional
    if (rating < 1 || rating > 5) {
      throw Exception('التقييم يجب أن يكون بين 1 و 5 نجوم');
    }

    final endpoint = targetType == 'venue'
        ? ApiConstants.createVenueReview(targetId)
        : ApiConstants.createServiceReview(targetId);

    try {
      final response = await _apiClient.post(
        endpoint,
        data: {
          'rating': rating.toInt(), // API expects integer rating
          'comment': comment,
        },
      );

      final responseData = response.data['data'] ?? response.data;
      final reviewData = responseData['review'] ?? responseData;
      return ReviewModel.fromJson(reviewData);
    } catch (e) {
      // Check for duplicate review error
      final errorMessage = e.toString().toLowerCase();
      if (errorMessage.contains('already submitted') ||
          errorMessage.contains('already reviewed') ||
          errorMessage.contains('duplicate')) {
        throw DuplicateReviewException();
      }
      rethrow;
    }
  }

  /// Update an existing review
  Future<ReviewModel> updateReview({
    required String reviewId,
    required double rating,
    required String comment,
  }) async {
    // Validation - only rating is required, comment is optional
    if (rating < 1 || rating > 5) {
      throw Exception('التقييم يجب أن يكون بين 1 و 5 نجوم');
    }

    final response = await _apiClient.put(
      ApiConstants.updateReview(reviewId),
      data: {'rating': rating.toInt(), 'comment': comment},
    );

    final responseData = response.data['data'] ?? response.data;
    final reviewData = responseData['review'] ?? responseData;
    return ReviewModel.fromJson(reviewData);
  }

  /// Delete a review
  Future<void> deleteReview(String reviewId) async {
    await _apiClient.delete(ApiConstants.deleteReview(reviewId));
  }

  /// Fetch all reviews by current user
  Future<List<ReviewModel>> getUserReviews(String userId) async {
    final response = await _apiClient.get(ApiConstants.userReviews);
    final responseData = response.data['data'] ?? response.data;
    final reviewsList = responseData['reviews'] ?? responseData;

    return (reviewsList as List)
        .map((json) => ReviewModel.fromJson(json))
        .toList();
  }

  /// Calculate average rating from a list of reviews
  double calculateAverageRating(List<ReviewModel> reviews) {
    if (reviews.isEmpty) return 0.0;
    final sum = reviews.fold<double>(0, (sum, review) => sum + review.rating);
    return sum / reviews.length;
  }
}
