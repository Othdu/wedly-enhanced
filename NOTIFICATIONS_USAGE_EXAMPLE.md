# Notifications Usage Examples

## How to Add Notification Bell Icon to User Home Screen

### Option 1: Add to AppBar in user_home_screen.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wedly/logic/blocs/notification/notification_bloc.dart';
import 'package:wedly/logic/blocs/notification/notification_state.dart';
import 'package:wedly/routes/app_router.dart';

// In your UserHomeScreen or UserNavigationWrapper AppBar:
AppBar(
  title: const Text('الرئيسية'),
  actions: [
    // Notification bell with badge
    Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, size: 28),
          onPressed: () {
            Navigator.pushNamed(context, AppRouter.notificationsList);
          },
        ),
        // Unread badge
        BlocBuilder<NotificationBloc, NotificationState>(
          builder: (context, state) {
            final unreadCount = state is NotificationLoaded ? state.unreadCount : 0;

            if (unreadCount == 0) return const SizedBox.shrink();

            return Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 18,
                  minHeight: 18,
                ),
                child: Center(
                  child: Text(
                    unreadCount > 9 ? '9+' : '$unreadCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    ),
    const SizedBox(width: 8),
  ],
)
```

### Option 2: Add to Navigation Bar (Bottom Tab)

If you want notifications as a tab in the bottom navigation:

```dart
// In UserNavigationWrapper
final List<BottomNavigationBarItem> _navItems = [
  BottomNavigationBarItem(
    icon: Icon(Icons.home_outlined),
    activeIcon: Icon(Icons.home),
    label: 'الرئيسية',
  ),
  BottomNavigationBarItem(
    icon: Icon(Icons.shopping_bag_outlined),
    activeIcon: Icon(Icons.shopping_bag),
    label: 'حجوزاتي',
  ),
  // Add this:
  BottomNavigationBarItem(
    icon: Badge(
      label: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          final count = state is NotificationLoaded ? state.unreadCount : 0;
          return Text('$count');
        },
      ),
      isLabelVisible: true, // Show badge
      child: Icon(Icons.notifications_outlined),
    ),
    activeIcon: Icon(Icons.notifications),
    label: 'الإشعارات',
  ),
  BottomNavigationBarItem(
    icon: Icon(Icons.person_outline),
    activeIcon: Icon(Icons.person),
    label: 'حسابي',
  ),
];

// Add NotificationsListScreen to your screens list
final List<Widget> _screens = [
  UserHomeScreen(),
  UserBookingsScreen(),
  NotificationsListScreen(), // Add this
  UserProfileScreen(),
];
```

### Option 3: Simple Button in Home Screen Body

Add a notifications card in the home screen body:

```dart
// In user_home_screen.dart body
GestureDetector(
  onTap: () {
    Navigator.pushNamed(context, AppRouter.notificationsList);
  },
  child: Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Icon(
          Icons.arrow_back_ios,
          size: 16,
          color: Colors.grey[600],
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              BlocBuilder<NotificationBloc, NotificationState>(
                builder: (context, state) {
                  final unreadCount = state is NotificationLoaded
                      ? state.unreadCount
                      : 0;

                  if (unreadCount == 0) {
                    return const Text(
                      'الإشعارات',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      textDirection: TextDirection.rtl,
                    );
                  }

                  return Text(
                    'الإشعارات ($unreadCount جديد)',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFD4AF37),
                    ),
                    textDirection: TextDirection.rtl,
                  );
                },
              ),
              const SizedBox(width: 12),
              const Icon(
                Icons.notifications,
                color: Color(0xFFD4AF37),
                size: 24,
              ),
            ],
          ),
        ),
      ],
    ),
  ),
)
```

## Providing NotificationBloc Globally

To make notifications available app-wide, update `main.dart`:

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wedly/logic/blocs/notification/notification_bloc.dart';
import 'package:wedly/logic/blocs/notification/notification_event.dart';
import 'package:wedly/logic/blocs/auth/auth_bloc.dart';
import 'package:wedly/logic/blocs/auth/auth_state.dart';
import 'package:wedly/core/di/injection_container.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => getIt<AuthBloc>()..add(AuthCheckRequested()),
        ),
        BlocProvider<HomeBloc>(
          create: (context) => getIt<HomeBloc>(),
        ),
        // Add NotificationBloc
        BlocProvider<NotificationBloc>(
          create: (context) {
            final authState = context.read<AuthBloc>().state;
            final bloc = getIt<NotificationBloc>();

            // Load notifications if user is authenticated
            if (authState is AuthAuthenticated) {
              bloc.add(NotificationsRequested(userId: authState.user.id));
            }

            return bloc;
          },
        ),
        // ... other blocs
      ],
      child: MaterialApp(
        // ... app configuration
      ),
    );
  }
}
```

## Loading Notifications After Login

To automatically load notifications after user logs in:

```dart
// In auth_bloc.dart or in a listener in main.dart
BlocListener<AuthBloc, AuthState>(
  listener: (context, state) {
    if (state is AuthAuthenticated) {
      // User just logged in, load their notifications
      context.read<NotificationBloc>().add(
        NotificationsRequested(userId: state.user.id),
      );
    } else if (state is AuthUnauthenticated) {
      // User logged out, reset notification state
      // (NotificationBloc will automatically reset when recreated)
    }
  },
  child: YourApp(),
)
```

## Periodic Notification Refresh

To periodically check for new notifications:

```dart
import 'dart:async';

class UserHomeScreen extends StatefulWidget {
  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  Timer? _notificationTimer;

  @override
  void initState() {
    super.initState();
    _startNotificationPolling();
  }

  void _startNotificationPolling() {
    // Refresh notifications every 2 minutes
    _notificationTimer = Timer.periodic(
      const Duration(minutes: 2),
      (timer) {
        final authState = context.read<AuthBloc>().state;
        if (authState is AuthAuthenticated) {
          context.read<NotificationBloc>().add(
            NotificationsRefreshed(userId: authState.user.id),
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _notificationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ... your screen UI
  }
}
```

## Handling Notification Taps (Navigation)

To navigate to related content when notification is tapped, update the `_handleNotificationTap` method in `notifications_list_screen.dart`:

```dart
void _handleNotificationTap(NotificationModel notification) {
  // Mark as read if not already
  if (!notification.isRead) {
    context.read<NotificationBloc>().add(
      NotificationMarkAsRead(notificationId: notification.id),
    );
  }

  // Navigate based on notification type and relatedId
  switch (notification.type) {
    case NotificationType.booking:
      if (notification.relatedId != null) {
        // Navigate to booking details
        Navigator.pushNamed(
          context,
          AppRouter.bookingDetails,
          arguments: {'bookingId': notification.relatedId},
        );
      }
      break;

    case NotificationType.offer:
      if (notification.relatedId != null) {
        // Navigate to offer details or offers list
        Navigator.pushNamed(
          context,
          AppRouter.offersList,
        );
      }
      break;

    case NotificationType.reminder:
      // Show reminder dialog or navigate to bookings
      _showReminderDialog(notification);
      break;

    case NotificationType.update:
      if (notification.relatedId != null) {
        // Navigate to updated booking
        Navigator.pushNamed(
          context,
          AppRouter.bookingDetails,
          arguments: {'bookingId': notification.relatedId},
        );
      }
      break;

    case NotificationType.cancellation:
      // Show cancellation details or navigate to bookings
      Navigator.pushNamed(context, AppRouter.userBookings);
      break;
  }
}

void _showReminderDialog(NotificationModel notification) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text(
        'تذكير',
        textDirection: TextDirection.rtl,
      ),
      content: Text(
        notification.messageAr,
        textDirection: TextDirection.rtl,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'حسناً',
            textDirection: TextDirection.rtl,
          ),
        ),
      ],
    ),
  );
}
```

## Testing Notifications

### Manual Test Checklist

1. **Load Notifications**
   - Open notifications screen
   - Verify 7 mock notifications appear
   - Check loading skeleton displays briefly

2. **Mark as Read**
   - Tap an unread notification (yellow background)
   - Verify background changes to white
   - Verify golden dot disappears
   - Verify unread count decreases

3. **Mark All as Read**
   - Tap "قراءة الكل" button
   - Verify all notifications change to white background
   - Verify unread count becomes 0
   - Verify button disappears

4. **Delete Notification**
   - Swipe left on any notification
   - Verify red delete background appears
   - Complete swipe to delete
   - Verify notification is removed
   - Verify snackbar shows "تم حذف الإشعار"

5. **Pull to Refresh**
   - Pull down from top of list
   - Verify refresh indicator shows
   - Verify notifications reload

6. **Empty State**
   - Delete all notifications
   - Verify empty state UI shows:
     - Icon: notifications_off_outlined
     - Text: "لا توجد إشعارات"
     - Subtext: "ستظهر هنا جميع إشعاراتك"

7. **Navigation**
   - Tap notification
   - Verify snackbar shows navigation message
   - (Later: implement actual navigation)

## Integration with Push Notifications (Future)

When you add Firebase Cloud Messaging:

```dart
// In your FCM handler
FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  // Refresh notifications when new one arrives
  final authState = context.read<AuthBloc>().state;
  if (authState is AuthAuthenticated) {
    context.read<NotificationBloc>().add(
      NotificationsRefreshed(userId: authState.user.id),
    );
  }

  // Show local notification
  _showLocalNotification(message);
});
```

## Common Issues & Solutions

### Issue: Unread count not updating
**Solution**: Make sure NotificationBloc is provided at app level in main.dart

### Issue: Notifications not loading
**Solution**: Check that user is authenticated and userId is being passed correctly

### Issue: UI not updating after action
**Solution**: Verify BlocBuilder is wrapping the widget that should update

### Issue: Swipe to delete not working
**Solution**: Ensure Dismissible key is unique (using notification.id)

### Issue: RTL alignment issues
**Solution**: Set textDirection: TextDirection.rtl on all Arabic text widgets
