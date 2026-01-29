import 'package:wedly/data/models/notification_model.dart';
import 'package:wedly/data/services/api_client.dart';
import 'package:wedly/data/services/api_constants.dart';

/// Repository for managing notifications
class NotificationRepository {
  final ApiClient _apiClient;

  NotificationRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Get all notifications for a user
  Future<List<NotificationModel>> getNotifications(String userId) async {
    final response = await _apiClient.get(ApiConstants.notifications);
    final responseData = response.data['data'] ?? response.data;
    final notificationsList = responseData['notifications'] ?? responseData;

    if (notificationsList is! List) {
      return [];
    }

    return notificationsList
        .map((json) => NotificationModel.fromJson(json))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Get unread notifications count
  Future<int> getUnreadCount(String userId) async {
    final response = await _apiClient.get(ApiConstants.unreadNotificationCount);
    final responseData = response.data['data'] ?? response.data;
    return responseData['count'] ?? 0;
  }

  /// Mark a notification as read
  Future<void> markAsRead(String notificationId) async {
    await _apiClient.put(ApiConstants.markNotificationAsRead(notificationId));
  }

  /// Mark all notifications as read for a user
  Future<void> markAllAsRead(String userId) async {
    await _apiClient.put(ApiConstants.markAllNotificationsAsRead);
  }

  /// Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    await _apiClient.delete(ApiConstants.deleteNotification(notificationId));
  }
}
