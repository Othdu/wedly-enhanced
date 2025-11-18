import 'package:wedly/data/models/review_model.dart';

/// Repository for managing reviews for venues and services
/// Currently uses mock data - ready for API integration
class ReviewRepository {
  // TODO: API Integration - Replace mock data with real API calls
  // Base URL: /api/reviews
  // GET /api/venues/:id/reviews - Fetch venue reviews
  // GET /api/services/:id/reviews - Fetch service reviews
  // POST /api/venues/:id/reviews - Submit venue review
  // POST /api/services/:id/reviews - Submit service review
  // PUT /api/reviews/:id - Update review
  // DELETE /api/reviews/:id - Delete review
  // GET /api/users/me/reviews - Fetch current user's reviews

  /// Fetch reviews for a specific venue
  /// Network delay: 600ms (simulated)
  Future<List<ReviewModel>> getVenueReviews(String venueId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));

    // TODO: API Integration - Replace with: dio.get('/api/venues/$venueId/reviews')
    return _getMockReviewsForTarget(venueId, 'venue');
  }

  /// Fetch reviews for a specific service
  /// Network delay: 600ms (simulated)
  Future<List<ReviewModel>> getServiceReviews(String serviceId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));

    // TODO: API Integration - Replace with: dio.get('/api/services/$serviceId/reviews')
    return _getMockReviewsForTarget(serviceId, 'service');
  }

  /// Submit a new review for a venue or service
  /// Network delay: 800ms (simulated)
  Future<ReviewModel> submitReview({
    required String targetId,
    required String targetType,
    required String userId,
    required String userName,
    String? userImageUrl,
    required double rating,
    required String comment,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // TODO: API Integration - Replace with: dio.post('/api/$targetType/$targetId/reviews')
    // Validation
    if (rating < 1 || rating > 5) {
      throw Exception('التقييم يجب أن يكون بين 1 و 5 نجوم');
    }
    if (comment.trim().isEmpty) {
      throw Exception('الرجاء كتابة تعليق');
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

  /// Update an existing review
  /// Network delay: 700ms (simulated)
  Future<ReviewModel> updateReview({
    required String reviewId,
    required double rating,
    required String comment,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 700));

    // TODO: API Integration - Replace with: dio.put('/api/reviews/$reviewId')
    // Validation
    if (rating < 1 || rating > 5) {
      throw Exception('التقييم يجب أن يكون بين 1 و 5 نجوم');
    }
    if (comment.trim().isEmpty) {
      throw Exception('الرجاء كتابة تعليق');
    }

    // Find and update the review (mock)
    final mockReview = _allMockReviews.firstWhere(
      (r) => r.id == reviewId,
      orElse: () => throw Exception('التقييم غير موجود'),
    );

    return mockReview.copyWith(
      rating: rating,
      comment: comment,
    );
  }

  /// Delete a review
  /// Network delay: 500ms (simulated)
  Future<void> deleteReview(String reviewId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // TODO: API Integration - Replace with: dio.delete('/api/reviews/$reviewId')
    // Simulate deletion (in real app, backend would handle this)
    final reviewExists = _allMockReviews.any((r) => r.id == reviewId);
    if (!reviewExists) {
      throw Exception('التقييم غير موجود');
    }
    // In mock, we just verify it exists. Real API would delete it.
  }

  /// Fetch all reviews by current user
  /// Network delay: 600ms (simulated)
  Future<List<ReviewModel>> getUserReviews(String userId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));

    // TODO: API Integration - Replace with: dio.get('/api/users/me/reviews')
    return _allMockReviews.where((r) => r.userId == userId).toList();
  }

  /// Calculate average rating from a list of reviews
  double calculateAverageRating(List<ReviewModel> reviews) {
    if (reviews.isEmpty) return 0.0;
    final sum = reviews.fold<double>(0, (sum, review) => sum + review.rating);
    return sum / reviews.length;
  }

  /// Helper method to get mock reviews for a specific target
  List<ReviewModel> _getMockReviewsForTarget(String targetId, String type) {
    return _allMockReviews.where((r) => r.venueId == targetId).toList();
  }

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
      comment: 'تجربة ممتازة! التنظيم راائع والخدمة سريعة والموظفون محترمون جدًا',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    ReviewModel(
      id: 'review_v1_2',
      venueId: 'venue_1',
      userId: 'user_2',
      userName: 'أحمد محمود',
      userImageUrl: 'https://i.pravatar.cc/150?img=33',
      rating: 5.0,
      comment: 'القاعة رائعة والديكورات فخمة جداً. الإضاءة مثالية والصوتيات ممتازة',
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
