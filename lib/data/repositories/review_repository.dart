import 'package:wedly/data/models/review_model.dart';
import 'package:wedly/data/services/api_client.dart';
import 'package:wedly/data/services/api_constants.dart';
import 'package:wedly/data/services/api_exceptions.dart';

/// Repository for managing reviews for venues and services
///
/// Supports both mock data and real API integration
/// Switch between modes using useMockData flag
class ReviewRepository {
  final ApiClient? apiClient;
  final bool useMockData;

  ReviewRepository({this.apiClient, this.useMockData = true});

  // ==================== PUBLIC METHODS ====================

  /// Fetch reviews for a specific venue
  Future<List<ReviewModel>> getVenueReviews(String venueId) async {
    if (useMockData || apiClient == null) {
      return _mockGetVenueReviews(venueId);
    }
    return _apiGetVenueReviews(venueId);
  }

  /// Fetch reviews for a specific service
  Future<List<ReviewModel>> getServiceReviews(String serviceId) async {
    if (useMockData || apiClient == null) {
      return _mockGetServiceReviews(serviceId);
    }
    return _apiGetServiceReviews(serviceId);
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
    if (useMockData || apiClient == null) {
      return _mockSubmitReview(
        targetId: targetId,
        targetType: targetType,
        userId: userId,
        userName: userName,
        userImageUrl: userImageUrl,
        rating: rating,
        comment: comment,
      );
    }
    return _apiSubmitReview(
      targetId: targetId,
      targetType: targetType,
      userId: userId,
      userName: userName,
      userImageUrl: userImageUrl,
      rating: rating,
      comment: comment,
    );
  }

  /// Update an existing review
  Future<ReviewModel> updateReview({
    required String reviewId,
    required double rating,
    required String comment,
  }) async {
    if (useMockData || apiClient == null) {
      return _mockUpdateReview(
        reviewId: reviewId,
        rating: rating,
        comment: comment,
      );
    }
    return _apiUpdateReview(
      reviewId: reviewId,
      rating: rating,
      comment: comment,
    );
  }

  /// Delete a review
  Future<void> deleteReview(String reviewId) async {
    if (useMockData || apiClient == null) {
      return _mockDeleteReview(reviewId);
    }
    return _apiDeleteReview(reviewId);
  }

  /// Fetch all reviews by current user
  Future<List<ReviewModel>> getUserReviews(String userId) async {
    if (useMockData || apiClient == null) {
      return _mockGetUserReviews(userId);
    }
    return _apiGetUserReviews();
  }

  /// Calculate average rating from a list of reviews
  double calculateAverageRating(List<ReviewModel> reviews) {
    if (reviews.isEmpty) return 0.0;
    final sum = reviews.fold<double>(0, (sum, review) => sum + review.rating);
    return sum / reviews.length;
  }

  // ==================== API METHODS ====================

  /// API: Get venue reviews
  Future<List<ReviewModel>> _apiGetVenueReviews(String venueId) async {
    final response = await apiClient!.get(
      ApiConstants.getVenueReviews(venueId),
    );
    final responseData = response.data['data'] ?? response.data;
    final reviewsList = responseData['reviews'] ?? responseData;

    return (reviewsList as List)
        .map((json) => ReviewModel.fromJson(json))
        .toList();
  }

  /// API: Get service reviews
  Future<List<ReviewModel>> _apiGetServiceReviews(String serviceId) async {
    final response = await apiClient!.get(
      ApiConstants.getServiceReviews(serviceId),
    );
    final responseData = response.data['data'] ?? response.data;
    final reviewsList = responseData['reviews'] ?? responseData;

    return (reviewsList as List)
        .map((json) => ReviewModel.fromJson(json))
        .toList();
  }

  /// API: Submit a review
  Future<ReviewModel> _apiSubmitReview({
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
      final response = await apiClient!.post(
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

  /// API: Update review
  Future<ReviewModel> _apiUpdateReview({
    required String reviewId,
    required double rating,
    required String comment,
  }) async {
    // Validation - only rating is required, comment is optional
    if (rating < 1 || rating > 5) {
      throw Exception('التقييم يجب أن يكون بين 1 و 5 نجوم');
    }

    final response = await apiClient!.put(
      ApiConstants.updateReview(reviewId),
      data: {'rating': rating.toInt(), 'comment': comment},
    );

    final responseData = response.data['data'] ?? response.data;
    final reviewData = responseData['review'] ?? responseData;
    return ReviewModel.fromJson(reviewData);
  }

  /// API: Delete review
  Future<void> _apiDeleteReview(String reviewId) async {
    await apiClient!.delete(ApiConstants.deleteReview(reviewId));
  }

  /// API: Get user reviews
  Future<List<ReviewModel>> _apiGetUserReviews() async {
    final response = await apiClient!.get(ApiConstants.userReviews);
    final responseData = response.data['data'] ?? response.data;
    final reviewsList = responseData['reviews'] ?? responseData;

    return (reviewsList as List)
        .map((json) => ReviewModel.fromJson(json))
        .toList();
  }

  // ==================== MOCK METHODS ====================

  /// Mock: Get venue reviews
  Future<List<ReviewModel>> _mockGetVenueReviews(String venueId) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return _getMockReviewsForTarget(venueId, 'venue');
  }

  /// Mock: Get service reviews
  Future<List<ReviewModel>> _mockGetServiceReviews(String serviceId) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return _getMockReviewsForTarget(serviceId, 'service');
  }

  /// Mock: Submit review
  Future<ReviewModel> _mockSubmitReview({
    required String targetId,
    required String targetType,
    required String userId,
    required String userName,
    String? userImageUrl,
    required double rating,
    required String comment,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    // Validation - only rating is required, comment is optional
    if (rating < 1 || rating > 5) {
      throw Exception('التقييم يجب أن يكون بين 1 و 5 نجوم');
    }

    // Create new review (simulate backend creating it with ID)
    final newReview = ReviewModel(
      id: 'review_${DateTime.now().millisecondsSinceEpoch}',
      venueId: targetId,
      userId: userId,
      userName: userName,
      userImageUrl: userImageUrl,
      rating: rating,
      comment: comment,
      createdAt: DateTime.now(),
    );

    return newReview;
  }

  /// Mock: Update review
  Future<ReviewModel> _mockUpdateReview({
    required String reviewId,
    required double rating,
    required String comment,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));

    // Validation - only rating is required, comment is optional
    if (rating < 1 || rating > 5) {
      throw Exception('التقييم يجب أن يكون بين 1 و 5 نجوم');
    }

    // Find and update the review (mock)
    final mockReview = _allMockReviews.firstWhere(
      (r) => r.id == reviewId,
      orElse: () => throw Exception('التقييم غير موجود'),
    );

    return mockReview.copyWith(rating: rating, comment: comment);
  }

  /// Mock: Delete review
  Future<void> _mockDeleteReview(String reviewId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    // Simulate deletion (in real app, backend would handle this)
    final reviewExists = _allMockReviews.any((r) => r.id == reviewId);
    if (!reviewExists) {
      throw Exception('التقييم غير موجود');
    }
    // In mock, we just verify it exists. Real API would delete it.
  }

  /// Mock: Get user reviews
  Future<List<ReviewModel>> _mockGetUserReviews(String userId) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return _allMockReviews.where((r) => r.userId == userId).toList();
  }

  /// Helper method to get mock reviews for a specific target
  List<ReviewModel> _getMockReviewsForTarget(String targetId, String type) {
    return _allMockReviews.where((r) => r.venueId == targetId).toList();
  }

  // ==================== MOCK DATA ====================

  /// Mock reviews database
  /// In real app, this would come from backend API
  static final List<ReviewModel> _allMockReviews = [
    // Venue 1 reviews (قاعة نوفا)
    ReviewModel(
      id: 'review_v1_1',
      venueId: 'venue_1',
      userId: 'user_1',
      userName: 'مصطفى الشرقاوي',
      userImageUrl: 'https://i.pravatar.cc/150?img=12',
      rating: 5.0,
      comment:
          'تجربة ممتازة! التنظيم راائع والخدمة سريعة والموظفون محترمون جدًا',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    ReviewModel(
      id: 'review_v1_2',
      venueId: 'venue_1',
      userId: 'user_2',
      userName: 'أحمد محمود',
      userImageUrl: 'https://i.pravatar.cc/150?img=33',
      rating: 5.0,
      comment:
          'القاعة رائعة والديكورات فخمة جداً. الإضاءة مثالية والصوتيات ممتازة',
      createdAt: DateTime.now().subtract(const Duration(days: 12)),
    ),
    ReviewModel(
      id: 'review_v1_3',
      venueId: 'venue_1',
      userId: 'user_3',
      userName: 'سارة عبدالله',
      userImageUrl: 'https://i.pravatar.cc/150?img=45',
      rating: 4.0,
      comment: 'قاعة جميلة والطاقم متعاون. السعر مناسب للخدمات المقدمة',
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
    ),

    // Venue 2 reviews (قاعة إيلات)
    ReviewModel(
      id: 'review_v2_1',
      venueId: 'venue_2',
      userId: 'user_4',
      userName: 'خالد يوسف',
      userImageUrl: 'https://i.pravatar.cc/150?img=15',
      rating: 5.0,
      comment: 'حفلة رائعة! القاعة نظيفة والديكور عصري. ننصح بها بشدة',
      createdAt: DateTime.now().subtract(const Duration(days: 8)),
    ),
    ReviewModel(
      id: 'review_v2_2',
      venueId: 'venue_2',
      userId: 'user_5',
      userName: 'نورا حسن',
      userImageUrl: 'https://i.pravatar.cc/150?img=47',
      rating: 4.5,
      comment: 'مكان مميز وأسعار معقولة. الخدمة جيدة والموقع سهل الوصول',
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
    ),

    // Venue 3 reviews (قاعة روفاتا)
    ReviewModel(
      id: 'review_v3_1',
      venueId: 'venue_3',
      userId: 'user_6',
      userName: 'عمر السيد',
      userImageUrl: 'https://i.pravatar.cc/150?img=52',
      rating: 4.5,
      comment: 'قاعة واسعة ومريحة. الإطلالة جميلة والجو رائع',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),

    // Venue 4 reviews (قاعة قلبي الشرطة)
    ReviewModel(
      id: 'review_v4_1',
      venueId: 'venue_4',
      userId: 'user_7',
      userName: 'ياسمين علي',
      userImageUrl: 'https://i.pravatar.cc/150?img=28',
      rating: 5.0,
      comment: 'أفضل قاعة في القاهرة! الديكورات فخمة والخدمة VIP',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    ReviewModel(
      id: 'review_v4_2',
      venueId: 'venue_4',
      userId: 'user_8',
      userName: 'محمد فتحي',
      userImageUrl: 'https://i.pravatar.cc/150?img=60',
      rating: 5.0,
      comment: 'تجربة لا تنسى! كل شيء كان مثالي من البداية للنهاية',
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
    ReviewModel(
      id: 'review_v4_3',
      venueId: 'venue_4',
      userId: 'user_9',
      userName: 'ليلى إبراهيم',
      userImageUrl: 'https://i.pravatar.cc/150?img=32',
      rating: 4.5,
      comment: 'قاعة راقية جداً والموظفين محترمين ومتعاونين',
      createdAt: DateTime.now().subtract(const Duration(days: 14)),
    ),
  ];
}
