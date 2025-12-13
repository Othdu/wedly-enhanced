import 'package:wedly/data/models/notification_model.dart';
import 'package:wedly/data/services/api_client.dart';
import 'package:wedly/data/services/api_constants.dart';

/// Repository for managing notifications
///
/// Supports both mock data and real API integration
/// Switch between modes using useMockData flag
class NotificationRepository {
  final ApiClient? apiClient;
  final bool useMockData;

  NotificationRepository({this.apiClient, this.useMockData = true});

  // ==================== PUBLIC METHODS ====================

  /// Get all notifications for a user
  Future<List<NotificationModel>> getNotifications(String userId) async {
    if (useMockData || apiClient == null) {
      return _mockGetNotifications(userId);
    }
    return _apiGetNotifications();
  }

  /// Get unread notifications count
  Future<int> getUnreadCount(String userId) async {
    if (useMockData || apiClient == null) {
      return _mockGetUnreadCount(userId);
    }
    return _apiGetUnreadCount();
  }

  /// Mark a notification as read
  Future<void> markAsRead(String notificationId) async {
    if (useMockData || apiClient == null) {
      return _mockMarkAsRead(notificationId);
    }
    return _apiMarkAsRead(notificationId);
  }

  /// Mark all notifications as read for a user
  Future<void> markAllAsRead(String userId) async {
    if (useMockData || apiClient == null) {
      return _mockMarkAllAsRead(userId);
    }
    return _apiMarkAllAsRead();
  }

  /// Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    if (useMockData || apiClient == null) {
      return _mockDeleteNotification(notificationId);
    }
    return _apiDeleteNotification(notificationId);
  }

  // ==================== API METHODS ====================

  /// API: Get all notifications
  Future<List<NotificationModel>> _apiGetNotifications() async {
    final response = await apiClient!.get(ApiConstants.notifications);
    final responseData = response.data['data'] ?? response.data;
    final notificationsList = responseData['notifications'] ?? responseData;

    return (notificationsList as List)
        .map((json) => NotificationModel.fromJson(json))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// API: Get unread notifications count
  Future<int> _apiGetUnreadCount() async {
    final response = await apiClient!.get(ApiConstants.unreadNotificationCount);
    final responseData = response.data['data'] ?? response.data;
    return responseData['count'] ?? 0;
  }

  /// API: Mark notification as read
  Future<void> _apiMarkAsRead(String notificationId) async {
    await apiClient!.put(ApiConstants.markNotificationAsRead(notificationId));
  }

  /// API: Mark all notifications as read
  Future<void> _apiMarkAllAsRead() async {
    await apiClient!.put(ApiConstants.markAllNotificationsAsRead);
  }

  /// API: Delete notification
  Future<void> _apiDeleteNotification(String notificationId) async {
    await apiClient!.delete(ApiConstants.deleteNotification(notificationId));
  }

  // ==================== MOCK METHODS ====================

  /// Mock: Get all notifications
  Future<List<NotificationModel>> _mockGetNotifications(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // Sort by most recent first (newest to oldest)
    final sortedNotifications = List<NotificationModel>.from(
      _mockNotifications,
    );
    sortedNotifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return sortedNotifications;
  }

  /// Mock: Get unread notifications count
  Future<int> _mockGetUnreadCount(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockNotifications.where((n) => !n.isRead).length;
  }

  /// Mock: Mark notification as read
  Future<void> _mockMarkAsRead(String notificationId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // Update mock data
    final index = _mockNotifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _mockNotifications[index] = _mockNotifications[index].copyWith(
        isRead: true,
      );
    }
  }

  /// Mock: Mark all notifications as read
  Future<void> _mockMarkAllAsRead(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // Update mock data
    _mockNotifications = _mockNotifications
        .map((n) => n.copyWith(isRead: true))
        .toList();
  }

  /// Mock: Delete notification
  Future<void> _mockDeleteNotification(String notificationId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // Remove from mock data
    _mockNotifications.removeWhere((n) => n.id == notificationId);
  }

  // ==================== MOCK DATA ====================

  // Mock data - sorted by most recent first
  static List<NotificationModel> _mockNotifications = [
    // Most recent - 1 minute ago
    NotificationModel(
      id: 'notif_1',
      titleAr: 'التذكيرات',
      messageAr:
          'تبقى 5 أيام على موعد زفافك! تأكدي من تفاصيل المكياج والفساتين.',
      type: NotificationType.reminder,
      createdAt: DateTime.now().subtract(const Duration(minutes: 1)),
      isRead: false,
    ),
    // 15 minutes ago
    NotificationModel(
      id: 'notif_2',
      titleAr: 'العروض',
      messageAr: 'خصم 25% على قاعات روزا – العرض ساري حتى نهاية الأسبوع!',
      type: NotificationType.offer,
      createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
      isRead: false,
      relatedId: 'offer_456',
    ),
    // 45 minutes ago
    NotificationModel(
      id: 'notif_3',
      titleAr: 'الحجوزات',
      messageAr: 'تم تأكيد حجزك في كوشة الملوكية بيوم 10 نوفمبر.',
      type: NotificationType.booking,
      createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
      isRead: false,
      relatedId: 'booking_123',
    ),
    // 2 hours ago
    NotificationModel(
      id: 'notif_4',
      titleAr: 'التحديثات',
      messageAr: 'تم تعديل موعد جلسة التصوير الخاصة بك إلى يوم الخميس القادم.',
      type: NotificationType.update,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: false,
      relatedId: 'booking_789',
    ),
    // 5 hours ago
    NotificationModel(
      id: 'notif_5',
      titleAr: 'تم الإلغاء',
      messageAr: 'تم إلغاء حجزك في قاعة المناسبة بناءً على طلبك.',
      type: NotificationType.cancellation,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      isRead: false,
      relatedId: 'booking_321',
    ),
    // 1 day ago (read)
    NotificationModel(
      id: 'notif_6',
      titleAr: 'العروض',
      messageAr: 'عرض خاص: باقة تصوير فوتوغرافي كاملة بخصم 30%',
      type: NotificationType.offer,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
      relatedId: 'offer_654',
    ),
    // 3 days ago (read)
    NotificationModel(
      id: 'notif_7',
      titleAr: 'الحجوزات',
      messageAr: 'تم استلام طلب حجزك لخدمة التزيين. سيتم التواصل معك قريباً.',
      type: NotificationType.booking,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      isRead: true,
      relatedId: 'booking_987',
    ),
  ];
}
