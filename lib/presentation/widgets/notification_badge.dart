import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wedly/core/services/push_notification_service.dart';

/// A badge widget that shows unread notification count
/// Updates automatically when new notifications arrive
class NotificationBadge extends StatefulWidget {
  final Widget child;
  final Color? badgeColor;
  final Color? textColor;
  final double? top;
  final double? right;

  const NotificationBadge({
    super.key,
    required this.child,
    this.badgeColor,
    this.textColor,
    this.top,
    this.right,
  });

  @override
  State<NotificationBadge> createState() => _NotificationBadgeState();
}

class _NotificationBadgeState extends State<NotificationBadge> {
  final NotificationService _notificationService = NotificationService();
  late int _unreadCount;
  StreamSubscription<int>? _subscription;

  @override
  void initState() {
    super.initState();
    _unreadCount = _notificationService.unreadCount;

    // Listen to unread count changes
    _subscription = _notificationService.unreadCountStream.listen((count) {
      if (mounted) {
        setState(() {
          _unreadCount = count;
        });
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        widget.child,
        if (_unreadCount > 0)
          Positioned(
            top: widget.top ?? -4,
            right: widget.right ?? -4,
            child: Container(
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
              decoration: BoxDecoration(
                color: widget.badgeColor ?? Colors.red,
                shape: _unreadCount > 9 ? BoxShape.rectangle : BoxShape.circle,
                borderRadius: _unreadCount > 9 ? BorderRadius.circular(9) : null,
              ),
              child: Center(
                child: Text(
                  _unreadCount > 99 ? '99+' : _unreadCount.toString(),
                  style: TextStyle(
                    color: widget.textColor ?? Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// A simple notification icon with badge
class NotificationIconButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color? iconColor;
  final double iconSize;

  const NotificationIconButton({
    super.key,
    this.onPressed,
    this.iconColor,
    this.iconSize = 24,
  });

  @override
  Widget build(BuildContext context) {
    return NotificationBadge(
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          Icons.notifications_outlined,
          color: iconColor ?? Theme.of(context).iconTheme.color,
          size: iconSize,
        ),
      ),
    );
  }
}
