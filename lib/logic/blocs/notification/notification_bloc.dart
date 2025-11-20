import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wedly/data/repositories/notification_repository.dart';
import 'notification_event.dart';
import 'notification_state.dart';

/// BLoC for managing notification state
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository notificationRepository;

  NotificationBloc({required this.notificationRepository})
      : super(NotificationInitial()) {
    on<NotificationsRequested>(_onNotificationsRequested);
    on<NotificationMarkAsRead>(_onNotificationMarkAsRead);
    on<NotificationMarkAllAsRead>(_onNotificationMarkAllAsRead);
    on<NotificationDeleted>(_onNotificationDeleted);
    on<NotificationsRefreshed>(_onNotificationsRefreshed);
  }

  /// Handle loading notifications
  Future<void> _onNotificationsRequested(
    NotificationsRequested event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());

    try {
      final notifications =
          await notificationRepository.getNotifications(event.userId);
      final unreadCount = notifications.where((n) => !n.isRead).length;

      emit(NotificationLoaded(
        notifications: notifications,
        unreadCount: unreadCount,
      ));
    } catch (e) {
      emit(NotificationError(
        message: 'فشل تحميل الإشعارات. يرجى المحاولة مرة أخرى.',
      ));
    }
  }

  /// Handle marking a notification as read
  Future<void> _onNotificationMarkAsRead(
    NotificationMarkAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    if (state is NotificationLoaded) {
      final currentState = state as NotificationLoaded;

      // Show action in progress
      emit(NotificationActionInProgress(
        notifications: currentState.notifications,
        unreadCount: currentState.unreadCount,
      ));

      try {
        await notificationRepository.markAsRead(event.notificationId);

        // Update the notification in the list
        final updatedNotifications = currentState.notifications.map((n) {
          if (n.id == event.notificationId) {
            return n.copyWith(isRead: true);
          }
          return n;
        }).toList();

        final unreadCount = updatedNotifications.where((n) => !n.isRead).length;

        emit(NotificationLoaded(
          notifications: updatedNotifications,
          unreadCount: unreadCount,
        ));
      } catch (e) {
        // Revert to previous state on error
        emit(NotificationLoaded(
          notifications: currentState.notifications,
          unreadCount: currentState.unreadCount,
        ));
      }
    }
  }

  /// Handle marking all notifications as read
  Future<void> _onNotificationMarkAllAsRead(
    NotificationMarkAllAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    if (state is NotificationLoaded) {
      final currentState = state as NotificationLoaded;

      // Show action in progress
      emit(NotificationActionInProgress(
        notifications: currentState.notifications,
        unreadCount: currentState.unreadCount,
      ));

      try {
        await notificationRepository.markAllAsRead(event.userId);

        // Update all notifications to read
        final updatedNotifications = currentState.notifications
            .map((n) => n.copyWith(isRead: true))
            .toList();

        emit(NotificationLoaded(
          notifications: updatedNotifications,
          unreadCount: 0,
        ));
      } catch (e) {
        // Revert to previous state on error
        emit(NotificationLoaded(
          notifications: currentState.notifications,
          unreadCount: currentState.unreadCount,
        ));
      }
    }
  }

  /// Handle deleting a notification
  Future<void> _onNotificationDeleted(
    NotificationDeleted event,
    Emitter<NotificationState> emit,
  ) async {
    if (state is NotificationLoaded) {
      final currentState = state as NotificationLoaded;

      // Show action in progress
      emit(NotificationActionInProgress(
        notifications: currentState.notifications,
        unreadCount: currentState.unreadCount,
      ));

      try {
        await notificationRepository.deleteNotification(event.notificationId);

        // Remove the notification from the list
        final updatedNotifications = currentState.notifications
            .where((n) => n.id != event.notificationId)
            .toList();

        final unreadCount = updatedNotifications.where((n) => !n.isRead).length;

        emit(NotificationLoaded(
          notifications: updatedNotifications,
          unreadCount: unreadCount,
        ));
      } catch (e) {
        // Revert to previous state on error
        emit(NotificationLoaded(
          notifications: currentState.notifications,
          unreadCount: currentState.unreadCount,
        ));
      }
    }
  }

  /// Handle refreshing notifications
  Future<void> _onNotificationsRefreshed(
    NotificationsRefreshed event,
    Emitter<NotificationState> emit,
  ) async {
    // Don't show loading state on refresh
    try {
      final notifications =
          await notificationRepository.getNotifications(event.userId);
      final unreadCount = notifications.where((n) => !n.isRead).length;

      emit(NotificationLoaded(
        notifications: notifications,
        unreadCount: unreadCount,
      ));
    } catch (e) {
      // Keep current state if refresh fails
      if (state is NotificationLoaded) {
        emit(state);
      } else {
        emit(NotificationError(
          message: 'فشل تحديث الإشعارات. يرجى المحاولة مرة أخرى.',
        ));
      }
    }
  }
}
