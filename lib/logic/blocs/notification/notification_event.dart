import 'package:equatable/equatable.dart';

/// Base class for all notification events
abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load all notifications for a user
class NotificationsRequested extends NotificationEvent {
  final String userId;

  const NotificationsRequested({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Event to mark a notification as read
class NotificationMarkAsRead extends NotificationEvent {
  final String notificationId;

  const NotificationMarkAsRead({required this.notificationId});

  @override
  List<Object?> get props => [notificationId];
}

/// Event to mark all notifications as read
class NotificationMarkAllAsRead extends NotificationEvent {
  final String userId;

  const NotificationMarkAllAsRead({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Event to delete a notification
class NotificationDeleted extends NotificationEvent {
  final String notificationId;

  const NotificationDeleted({required this.notificationId});

  @override
  List<Object?> get props => [notificationId];
}

/// Event to refresh notifications
class NotificationsRefreshed extends NotificationEvent {
  final String userId;

  const NotificationsRefreshed({required this.userId});

  @override
  List<Object?> get props => [userId];
}
