import 'dart:async';
import 'package:wedly/core/utils/app_logger.dart';
import 'package:wedly/data/models/notification_model.dart';
import 'package:wedly/data/repositories/notification_repository.dart';

/// Service to manage notifications via API polling
/// Provides real-time notification updates by periodically checking the API
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  NotificationRepository? _repository;
  Timer? _pollingTimer;

  // Stream controller for unread count updates
  final _unreadCountController = StreamController<int>.broadcast();
  Stream<int> get unreadCountStream => _unreadCountController.stream;

  // Stream controller for new notifications
  final _notificationController = StreamController<NotificationModel>.broadcast();
  Stream<NotificationModel> get notificationStream => _notificationController.stream;

  // Current unread count
  int _unreadCount = 0;
  int get unreadCount => _unreadCount;

  // Last check timestamp
  DateTime? _lastCheck;

  // Polling interval (30 seconds)
  static const Duration _pollingInterval = Duration(seconds: 30);

  /// Initialize the notification service
  void initialize(NotificationRepository repository) {
    _repository = repository;
    AppLogger.info('Notification service initialized', tag: 'Notifications');
  }

  /// Start polling for notifications
  /// Call this when user is authenticated
  void startPolling(String userId) {
    if (_repository == null) {
      AppLogger.warning('Notification service not initialized', tag: 'Notifications');
      return;
    }

    // Stop any existing polling
    stopPolling();

    // Initial fetch
    _fetchUnreadCount();

    // Start periodic polling
    _pollingTimer = Timer.periodic(_pollingInterval, (_) {
      _fetchUnreadCount();
    });

    AppLogger.info('Started notification polling', tag: 'Notifications');
  }

  /// Stop polling for notifications
  /// Call this when user logs out
  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _unreadCount = 0;
    _lastCheck = null;
    AppLogger.info('Stopped notification polling', tag: 'Notifications');
  }

  /// Fetch unread notification count
  Future<void> _fetchUnreadCount() async {
    if (_repository == null) return;

    try {
      final count = await _repository!.getUnreadCount('');

      // Check if count changed
      if (count != _unreadCount) {
        final previousCount = _unreadCount;
        _unreadCount = count;
        _unreadCountController.add(count);

        // If count increased, there are new notifications
        if (count > previousCount && previousCount > 0) {
          AppLogger.info('New notifications received: ${count - previousCount}', tag: 'Notifications');
          // Optionally fetch the new notifications to show them
          _fetchNewNotifications();
        }
      }

      _lastCheck = DateTime.now();
    } catch (e) {
      AppLogger.error('Failed to fetch unread count', tag: 'Notifications', error: e);
    }
  }

  /// Fetch new notifications (called when count increases)
  Future<void> _fetchNewNotifications() async {
    if (_repository == null) return;

    try {
      final notifications = await _repository!.getNotifications('');

      // Get unread notifications
      final unread = notifications.where((n) => !n.isRead).toList();

      // Emit each new notification (could be used to show local notifications)
      for (final notification in unread) {
        if (_lastCheck == null || notification.createdAt.isAfter(_lastCheck!)) {
          _notificationController.add(notification);
        }
      }
    } catch (e) {
      AppLogger.error('Failed to fetch new notifications', tag: 'Notifications', error: e);
    }
  }

  /// Get all notifications
  Future<List<NotificationModel>> getNotifications({
    bool? isRead,
    String? type,
    int page = 1,
    int limit = 20,
  }) async {
    if (_repository == null) {
      return [];
    }

    try {
      final notifications = await _repository!.getNotifications('');

      // Apply filters if provided
      var filtered = notifications;

      if (isRead != null) {
        filtered = filtered.where((n) => n.isRead == isRead).toList();
      }

      if (type != null) {
        filtered = filtered.where((n) => n.type.name == type).toList();
      }

      return filtered;
    } catch (e) {
      AppLogger.error('Failed to get notifications', tag: 'Notifications', error: e);
      return [];
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    if (_repository == null) return;

    try {
      await _repository!.markAsRead(notificationId);

      // Update unread count
      if (_unreadCount > 0) {
        _unreadCount--;
        _unreadCountController.add(_unreadCount);
      }

      AppLogger.debug('Notification marked as read: $notificationId', tag: 'Notifications');
    } catch (e) {
      AppLogger.error('Failed to mark notification as read', tag: 'Notifications', error: e);
      rethrow;
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    if (_repository == null) return;

    try {
      await _repository!.markAllAsRead('');

      // Reset unread count
      _unreadCount = 0;
      _unreadCountController.add(0);

      AppLogger.debug('All notifications marked as read', tag: 'Notifications');
    } catch (e) {
      AppLogger.error('Failed to mark all notifications as read', tag: 'Notifications', error: e);
      rethrow;
    }
  }

  /// Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    if (_repository == null) return;

    try {
      await _repository!.deleteNotification(notificationId);

      // Refresh unread count
      _fetchUnreadCount();

      AppLogger.debug('Notification deleted: $notificationId', tag: 'Notifications');
    } catch (e) {
      AppLogger.error('Failed to delete notification', tag: 'Notifications', error: e);
      rethrow;
    }
  }

  /// Manually refresh notifications
  Future<void> refresh() async {
    await _fetchUnreadCount();
  }

  /// Dispose the service
  void dispose() {
    stopPolling();
    _unreadCountController.close();
    _notificationController.close();
  }
}
