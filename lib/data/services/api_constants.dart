/// API Constants for Wedly App
/// Contains all API endpoints and configuration constants
class ApiConstants {
  // Base URL - Update this when backend is ready
  static const String baseUrl = 'https://api.wedly.example.com';
  static const String apiVersion = '/api/v1';

  // Timeout durations
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Auth Endpoints
  static const String login = '$apiVersion/auth/login';
  static const String register = '$apiVersion/auth/register';
  static const String refreshToken = '$apiVersion/auth/refresh';
  static const String logout = '$apiVersion/auth/logout';
  static const String getCurrentUser = '$apiVersion/auth/me';

  // Service Endpoints
  static const String services = '$apiVersion/services';
  static String serviceById(int id) => '$apiVersion/services/$id';
  static String servicesByCategory(String category) =>
      '$apiVersion/services/category/$category';

  // Provider Endpoints
  static String providerServices(String providerId) =>
      '$apiVersion/provider/$providerId/services';
  static String providerServiceById(int id) =>
      '$apiVersion/provider/services/$id';
  static String toggleServiceStatus(int id) =>
      '$apiVersion/provider/services/$id/toggle-status';

  // User Endpoints
  static const String userProfile = '$apiVersion/user/profile';
  static const String userBookings = '$apiVersion/user/bookings';

  // Booking Endpoints
  static String providerBookings(String providerId) =>
      '$apiVersion/provider/$providerId/bookings';
  static String bookingById(String id) => '$apiVersion/bookings/$id';
  static String updateBookingStatus(String id) =>
      '$apiVersion/bookings/$id/status';

  // Headers
  static const String contentType = 'application/json';
  static const String accept = 'application/json';

  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userRoleKey = 'user_role';
}
