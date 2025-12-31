/// API Constants for Wedly App
/// Contains all API endpoints and configuration constants
/// Updated to match real Wedly API at https://api.wedlyinfo.com
class ApiConstants {
  // Base URL - Real Wedly API
  static const String baseUrl = 'https://64.226.96.53';

  // Timeout durations
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Auth Endpoints
  static const String login = '/api/auth/login';
  static const String register = '/api/auth/register';
  static const String registerProvider = '/api/auth/register-provider';
  static const String verifyOtp = '/api/auth/verify-otp';
  static const String resendOtp = '/api/auth/resend-otp';
  static const String forgotPassword = '/api/auth/forgot-password';
  static const String resetPassword = '/api/auth/reset-password';
  static const String refreshToken = '/api/auth/refresh';
  static const String logout = '/api/auth/logout';
  static const String getCurrentUser = '/api/auth/me';
  static const String googleLogin = '/api/auth/google-login';
  static const String socialLogin = '/api/auth/google-login'; // Kept for backward compatibility

  // User Endpoints
  static const String userProfile = '/api/users/profile';
  static const String updateUserProfile = '/api/users/profile';
  static const String uploadProfileImage = '/api/users/profile/image';
  static const String changePassword = '/api/users/change-password';
  static const String switchRole = '/api/users/switch-role';
  static const String setWeddingDate = '/api/users/wedding-date';

  // Service Endpoints
  static const String services = '/api/services';
  static const String createService = '/api/services'; // POST
  static String serviceById(dynamic id) => '/api/services/$id';
  static String updateService(String id) => '/api/services/$id'; // PUT
  static String servicesByCategory(String category) => '/api/services?category=$category';
  static String providerServices(String providerId) =>
      '/api/services/providers/$providerId/services';
  static String toggleServiceStatus(dynamic id) => '/api/services/$id/toggle-status';
  static String getServicePackages(dynamic id) => '/api/services/$id/packages';

  // Dynamic Sections Endpoints (per API spec)
  static String getServiceDynamicSections(dynamic id) => '/api/services/$id/dynamic-sections';
  static String createDynamicSection(String serviceId) => '/api/services/$serviceId/dynamic-sections'; // POST
  static String updateDynamicSection(String serviceId, String sectionId) =>
      '/api/services/$serviceId/dynamic-sections/$sectionId'; // PUT
  static String deleteDynamicSection(String serviceId, String sectionId) =>
      '/api/services/$serviceId/dynamic-sections/$sectionId'; // DELETE
  static String createSectionOption(String serviceId, String sectionId) =>
      '/api/services/$serviceId/dynamic-sections/$sectionId/options'; // POST
  static String updateSectionOption(String serviceId, String sectionId, String optionId) =>
      '/api/services/$serviceId/dynamic-sections/$sectionId/options/$optionId'; // PUT
  static String deleteSectionOption(String serviceId, String sectionId, String optionId) =>
      '/api/services/$serviceId/dynamic-sections/$sectionId/options/$optionId'; // DELETE

  // Service Available Dates (calendar view) - requires month param (YYYY-MM format)
  static String getServiceAvailableDates(dynamic id, String month, {String? timeSlot}) =>
      '/api/services/$id/available-dates?month=$month${timeSlot != null ? '&time_slot=$timeSlot' : ''}';

  // Services with filters - GET /api/services with query params
  static String servicesWithFilters({
    String? category,
    String? city,
    double? minPrice,
    double? maxPrice,
    double? rating,
    bool? hasOffer,
    int? page,
    int? limit,
    String? sort,
  }) {
    final params = <String, String>{};
    if (category != null) params['category'] = category;
    if (city != null) params['city'] = city;
    if (minPrice != null) params['min_price'] = minPrice.toString();
    if (maxPrice != null) params['max_price'] = maxPrice.toString();
    if (rating != null) params['rating'] = rating.toString();
    if (hasOffer != null) params['has_offer'] = hasOffer.toString();
    if (page != null) params['page'] = page.toString();
    if (limit != null) params['limit'] = limit.toString();
    if (sort != null) params['sort'] = sort;

    final queryString = params.entries.map((e) => '${e.key}=${e.value}').join('&');
    return '/api/services${queryString.isNotEmpty ? '?$queryString' : ''}';
  }

  static String homeLayout(String screenName) => '/api/layout/$screenName';
  static String userCountdown(String userId) => '/api/user/$userId/countdown';

  // Category Endpoints
  static const String categories = '/api/categories';
  static const String createCategory = '/api/categories'; // POST
  static String categoryById(String id) => '/api/categories/$id';
  static String updateCategory(String id) => '/api/categories/$id'; // PUT
  static String deleteCategory(String id) => '/api/categories/$id'; // DELETE

  // Booking Endpoints
  static const String userBookings = '/api/users/bookings';
  static const String providerBookings = '/api/providers/bookings';
  static const String providerBookingStats = '/api/providers/bookings/stats';
  static String bookingById(String id) => '/api/bookings/$id';
  static const String createBooking = '/api/bookings';
  static String updateBookingStatus(String id) => '/api/bookings/$id/status';

  // Cart Endpoints
  static const String cart = '/api/cart';
  static const String addToCart = '/api/cart';
  static const String clearCart = '/api/cart';
  static String removeFromCart(String itemId) => '/api/cart/$itemId';

  // Notifications Endpoints
  static const String notifications = '/api/notifications';
  static const String unreadNotificationCount = '/api/notifications/unread-count';
  static String markNotificationAsRead(String id) => '/api/notifications/$id/mark-read';
  static const String markAllNotificationsAsRead = '/api/notifications/mark-all-read';
  static String deleteNotification(String id) => '/api/notifications/$id';

  // Offers Endpoints
  static const String offers = '/api/offers';
  static const String createOffer = '/api/offers'; // POST
  static String offerById(String id) => '/api/offers/$id';
  static String updateOffer(String id) => '/api/offers/$id'; // PUT
  static String deleteOffer(String id) => '/api/offers/$id'; // DELETE
  static String getProviderOffers(String providerId) => '/api/providers/$providerId/offers';
  static String submitServiceOffer(String serviceId) => '/api/offers/services/$serviceId'; // PATCH - Submit offer for service

  // Reviews Endpoints
  static String updateReview(String id) => '/api/reviews/$id';
  static String deleteReview(String id) => '/api/reviews/$id';
  static const String userReviews = '/api/users/reviews';
  static String getServiceReviews(String serviceId) => '/api/services/$serviceId/reviews';
  static String createServiceReview(String serviceId) => '/api/services/$serviceId/reviews';
  static String getVenueReviews(String venueId) => '/api/venues/$venueId/reviews';
  static String createVenueReview(String venueId) => '/api/venues/$venueId/reviews';

  // Venues Endpoints
  static const String venues = '/api/venues';
  static const String createVenue = '/api/venues'; // POST
  static String venueById(String id) => '/api/venues/$id';
  static String updateVenue(String id) => '/api/venues/$id'; // PUT
  // Venue Available Dates (calendar view) - requires month param (YYYY-MM format)
  static String getVenueAvailableDates(dynamic id, String month, {String? timeSlot}) =>
      '/api/venues/$id/available-dates?month=$month${timeSlot != null ? '&time_slot=$timeSlot' : ''}';

  // Address Endpoints
  static const String addressCities = '/api/addresses/cities';
  static String addressDistricts(String city) => '/api/addresses/districts?city=$city';
  static const String userAddress = '/api/users/address';
  static String updateUserAddress(String id) => '/api/users/address/$id';
  static String deleteUserAddress(String id) => '/api/users/address/$id';

  // Admin Endpoints
  static const String adminUsers = '/api/users/admin/users';
  static String adminUserById(String id) => '/api/users/admin/users/$id';
  static String updateUserActivation(String id) => '/api/users/admin/users/$id/activation';

  // Banner Endpoints
  static const String banners = '/api/banners'; // GET - Get all active banners (public)
  static const String adminBanners = '/api/banners/admin'; // GET - Get all banners (admin only)
  static const String createBanner = '/api/banners'; // POST - Create a new banner
  static String bannerById(String id) => '/api/banners/$id'; // GET - Get banner by ID
  static String updateBanner(String id) => '/api/banners/$id'; // PUT - Update a banner
  static String deleteBanner(String id) => '/api/banners/$id'; // DELETE - Delete a banner
  static String updateBannerImage(String id) => '/api/banners/$id/image'; // PUT - Update banner image
  static String toggleBannerVisibility(String id) => '/api/banners/$id/toggle-visibility'; // PATCH - Toggle banner visibility

  // Headers
  static const String contentType = 'application/json';
  static const String accept = 'application/json';

  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userRoleKey = 'user_role';
}
