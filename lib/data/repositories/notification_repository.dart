import 'package:wedly/data/models/notification_model.dart';

/// Repository for managing notifications
///
/// TODO: Replace mock data with real API calls when backend is ready
/// API Endpoints needed:
/// - GET /api/notifications?user_id={userId} - Get all notifications for user
/// - PUT /api/notifications/{id}/mark-read - Mark notification as read
/// - PUT /api/notifications/mark-all-read?user_id={userId} - Mark all as read
/// - DELETE /api/notifications/{id} - Delete notification
/// - GET /api/notifications/unread-count?user_id={userId} - Get unread count
class NotificationRepository {
  // Network delay simulation (300ms)
  static const _networkDelay = Duration(milliseconds: 300);

  /// Get all notifications for a user
  ///
  /// API Integration:
  /// - Endpoint: GET /api/notifications?user_id={userId}
  /// - Headers: Authorization: Bearer {token}
  /// - Response: { "notifications": [...], "total": 10, "unread": 3 }
  Future<List<NotificationModel>> getNotifications(String userId) async {
    await Future.delayed(_networkDelay);

    // TODO: Replace with API call
    // final response = await dio.get('/api/notifications', queryParameters: {'user_id': userId});
    // return (response.data['notifications'] as List).map((json) => NotificationModel.fromJson(json)).toList();

    // Sort by most recent first (newest to oldest)
    final sortedNotifications = List<NotificationModel>.from(_mockNotifications);
    sortedNotifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return sortedNotifications;
  }

  /// Get unread notifications count
  ///
  /// API Integration:
  /// - Endpoint: GET /api/notifications/unread-count?user_id={userId}
  /// - Response: { "count": 3 }
  Future<int> getUnreadCount(String userId) async {
    await Future.delayed(_networkDelay);

    // TODO: Replace with API call
    // final response = await dio.get('/api/notifications/unread-count', queryParameters: {'user_id': userId});
    // return response.data['count'] as int;

    return _mockNotifications.where((n) => !n.isRead).length;
  }

  /// Mark a notification as read
  ///
  /// API Integration:
  /// - Endpoint: PUT /api/notifications/{id}/mark-read
  /// - Headers: Authorization: Bearer {token}
  /// - Response: { "success": true, "notification": {...} }
  Future<void> markAsRead(String notificationId) async {
    await Future.delayed(_networkDelay);

    // TODO: Replace with API call
    // await dio.put('/api/notifications/$notificationId/mark-read');

    // Update mock data
    final index = _mockNotifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _mockNotifications[index] = _mockNotifications[index].copyWith(isRead: true);
    }
  }

  /// Mark all notifications as read for a user
  ///
  /// API Integration:
  /// - Endpoint: PUT /api/notifications/mark-all-read?user_id={userId}
  /// - Headers: Authorization: Bearer {token}
  /// - Response: { "success": true, "updated_count": 5 }
  Future<void> markAllAsRead(String userId) async {
    await Future.delayed(_networkDelay);

    // TODO: Replace with API call
    // await dio.put('/api/notifications/mark-all-read', queryParameters: {'user_id': userId});

    // Update mock data
    _mockNotifications = _mockNotifications
        .map((n) => n.copyWith(isRead: true))
        .toList();
  }

  /// Delete a notification
  ///
  /// API Integration:
  /// - Endpoint: DELETE /api/notifications/{id}
  /// - Headers: Authorization: Bearer {token}
  /// - Response: { "success": true }
  Future<void> deleteNotification(String notificationId) async {
    await Future.delayed(_networkDelay);

    // TODO: Replace with API call
    // await dio.delete('/api/notifications/$notificationId');

    // Remove from mock data
    _mockNotifications.removeWhere((n) => n.id == notificationId);
  }

  // Mock data - sorted by most recent first
  static List<NotificationModel> _mockNotifications = [
    // Most recent - 1 minute ago
    NotificationModel(
      id: 'notif_1',
      titleAr: 'التذكيرات',
      messageAr: 'تبقى 5 أيام على موعد زفافك! تأكدي من تفاصيل المكياج والفساتين.',
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
