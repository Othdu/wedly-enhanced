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
  static const String verifyOtp = '/api/auth/verify-otp';
  static const String resendOtp = '/api/auth/resend-otp';
  static const String forgotPassword = '/api/auth/forgot-password';
  static const String resetPassword = '/api/auth/reset-password';
  static const String refreshToken = '/api/auth/refresh';
  static const String logout = '/api/auth/logout';
  static const String getCurrentUser = '/api/auth/me';
  static const String socialLogin = '/api/auth/social-login';

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
  static String getServiceDynamicSections(dynamic id) => '/api/services/$id/dynamic-sections';
  static String getDynamicSectionOptions(String id) => '/api/services/$id/dynamic-sections/options';
  static String createDynamicSectionOption(String id) => '/api/services/$id/dynamic-sections/options'; // POST
  static String updateDynamicSectionOption(String serviceId, String optionId) =>
      '/api/services/$serviceId/dynamic-sections/options/$optionId'; // PUT
  static String deleteDynamicSectionOption(String serviceId, String optionId) =>
      '/api/services/$serviceId/dynamic-sections/options/$optionId'; // DELETE
  static String getServiceAvailableDates(dynamic id) => '/api/services/$id/available-dates';
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

  // Headers
  static const String contentType = 'application/json';
  static const String accept = 'application/json';

  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userRoleKey = 'user_role';
}
