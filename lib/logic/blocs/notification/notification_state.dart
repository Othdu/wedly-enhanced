import 'package:equatable/equatable.dart';
import 'package:wedly/data/models/notification_model.dart';

/// Base class for all notification states
abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any notifications are loaded
class NotificationInitial extends NotificationState {}

/// State when notifications are being loaded
class NotificationLoading extends NotificationState {}

/// State when notifications are successfully loaded
class NotificationLoaded extends NotificationState {
  final List<NotificationModel> notifications;
  final int unreadCount;

  const NotificationLoaded({
    required this.notifications,
    required this.unreadCount,
  });

  @override
  List<Object?> get props => [notifications, unreadCount];
}

/// State when there's an error loading notifications
class NotificationError extends NotificationState {
  final String message;

  const NotificationError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// State when a notification action is being performed (mark read, delete, etc.)
class NotificationActionInProgress extends NotificationState {
  final List<NotificationModel> notifications;
  final int unreadCount;

  const NotificationActionInProgress({
    required this.notifications,
    required this.unreadCount,
  });

  @override
  List<Object?> get props => [notifications, unreadCount];
}
