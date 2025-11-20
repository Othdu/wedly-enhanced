# Notifications Implementation Guide

## Overview
Complete notifications system implementation matching the design from the screenshot. The implementation is fully ready for API integration with mock data currently in place.

## Files Created

### 1. Data Layer

#### `lib/data/models/notification_model.dart`
- **NotificationType enum**: 5 types (booking, offer, reminder, update, cancellation)
- **NotificationModel class**: Complete model with all fields
  - `id`, `titleAr`, `messageAr`, `type`, `createdAt`, `isRead`, `relatedId`, `imageUrl`
- **Helper methods**:
  - `getTimeAgoAr()`: Returns Arabic time ago string (e.g., "منذ يوم واحد")
  - `getTypeLabelAr()`: Returns Arabic label for notification type
  - `getTypeColor()`: Returns color for each notification type
- **JSON serialization**: `fromJson()` and `toJson()` methods ready for API
- **Equatable**: Value equality support

#### `lib/data/repositories/notification_repository.dart`
- **Mock data**: 7 sample notifications matching the screenshot design
- **Methods** (all with TODO comments for API integration):
  - `getNotifications(userId)`: Get all user notifications
  - `getUnreadCount(userId)`: Get count of unread notifications
  - `markAsRead(notificationId)`: Mark single notification as read
  - `markAllAsRead(userId)`: Mark all notifications as read
  - `deleteNotification(notificationId)`: Delete a notification
- **Network delay**: 300ms simulation for realistic loading
- **API documentation**: Full endpoint specifications in comments

### 2. Logic Layer (BLoC)

#### `lib/logic/blocs/notification/notification_event.dart`
5 events defined:
- `NotificationsRequested`: Load notifications
- `NotificationMarkAsRead`: Mark single notification as read
- `NotificationMarkAllAsRead`: Mark all as read
- `NotificationDeleted`: Delete notification
- `NotificationsRefreshed`: Pull-to-refresh

#### `lib/logic/blocs/notification/notification_state.dart`
5 states defined:
- `NotificationInitial`: Initial state
- `NotificationLoading`: Loading notifications
- `NotificationLoaded`: Notifications loaded successfully
- `NotificationError`: Error state with message
- `NotificationActionInProgress`: Action being performed

#### `lib/logic/blocs/notification/notification_bloc.dart`
- Complete BLoC implementation
- Handles all 5 events
- Error handling with state restoration
- Optimistic UI updates

### 3. Presentation Layer

#### `lib/presentation/screens/user/notifications_list_screen.dart`
Full-featured notifications screen:

**Features:**
- ✅ Golden app bar matching design (الإشعارات)
- ✅ "قراءة الكل" (Mark all as read) button
- ✅ Notification cards with type badges
- ✅ Color-coded notification types
- ✅ Time ago display in Arabic
- ✅ Unread indicator (golden dot)
- ✅ Swipe-to-delete functionality
- ✅ Pull-to-refresh support
- ✅ Loading skeleton UI
- ✅ Empty state UI
- ✅ Error state with retry
- ✅ Tap to mark as read
- ✅ RTL support throughout

**Design matching screenshot:**
- White/yellow background for unread notifications
- Color-coded type badges (booking, offer, reminder, update, cancellation)
- Clean card design with shadows
- Proper Arabic text alignment
- Time ago in Arabic format

### 4. Routing & Dependency Injection

#### `lib/routes/app_router.dart`
- Added route constant: `notificationsList = '/notifications-list'`
- Added route handler with BLoC provider
- Route: `/notifications-list`

#### `lib/core/di/injection_container.dart`
- Registered `NotificationRepository` as lazy singleton
- Registered `NotificationBloc` as factory
- Ready for mock/API switching

## How to Use

### 1. Navigate to Notifications Screen

```dart
Navigator.pushNamed(context, AppRouter.notificationsList);
```

### 2. Access from User Home Screen

You can add a notification icon in the app bar of `user_home_screen.dart`:

```dart
AppBar(
  actions: [
    BlocBuilder<NotificationBloc, NotificationState>(
      builder: (context, state) {
        final unreadCount = state is NotificationLoaded ? state.unreadCount : 0;
        return IconButton(
          icon: Badge(
            label: Text('$unreadCount'),
            isLabelVisible: unreadCount > 0,
            child: const Icon(Icons.notifications),
          ),
          onPressed: () {
            Navigator.pushNamed(context, AppRouter.notificationsList);
          },
        );
      },
    ),
  ],
)
```

### 3. Provide NotificationBloc at App Level (Optional)

If you want notifications available throughout the app, add to `main.dart`:

```dart
MultiBlocProvider(
  providers: [
    // ... existing providers
    BlocProvider<NotificationBloc>(
      create: (context) => getIt<NotificationBloc>(),
    ),
  ],
  child: MaterialApp(...),
)
```

## API Integration Guide

### Step 1: Update Repository

Replace mock methods in `notification_repository.dart` with real API calls:

```dart
import 'package:dio/dio.dart';

class NotificationRepository {
  final Dio _dio;

  NotificationRepository({required Dio dio}) : _dio = dio;

  Future<List<NotificationModel>> getNotifications(String userId) async {
    try {
      final response = await _dio.get(
        '/api/notifications',
        queryParameters: {'user_id': userId},
      );

      return (response.data['notifications'] as List)
          .map((json) => NotificationModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to load notifications');
    }
  }

  // ... implement other methods similarly
}
```

### Step 2: Update Dependency Injection

Modify `injection_container.dart`:

```dart
getIt.registerLazySingleton<NotificationRepository>(
  () => NotificationRepository(
    dio: getIt<Dio>(), // or ApiClient
  ),
);
```

### Step 3: Backend API Endpoints Needed

```
GET    /api/notifications?user_id={userId}
       Response: { notifications: [...], total: 10, unread: 3 }

PUT    /api/notifications/{id}/mark-read
       Response: { success: true, notification: {...} }

PUT    /api/notifications/mark-all-read?user_id={userId}
       Response: { success: true, updated_count: 5 }

DELETE /api/notifications/{id}
       Response: { success: true }

GET    /api/notifications/unread-count?user_id={userId}
       Response: { count: 3 }
```

### Step 4: Expected JSON Format

```json
{
  "id": "notif_123",
  "title_ar": "الحجوزات",
  "message_ar": "تم تأكيد حجزك في كوشة الملوكية",
  "type": "booking",
  "created_at": "2025-11-18T15:30:00Z",
  "is_read": false,
  "related_id": "booking_456",
  "image_url": "https://example.com/image.jpg"
}
```

## Mock Data

The repository includes 7 mock notifications matching the screenshot:

1. **Booking** - Confirmed booking at كوشة الملوكية (1 day ago)
2. **Offer** - 25% discount on قاعات روزا (3 hours ago)
3. **Reminder** - 5 days until wedding (now)
4. **Update** - Photography session rescheduled (2 days ago)
5. **Cancellation** - Venue booking cancelled (5 hours ago)
6. **Offer** - Photography package 30% off (3 days ago, read)
7. **Booking** - Decoration booking received (4 days ago, read)

## Notification Types & Colors

| Type | Arabic Label | Color | Use Case |
|------|-------------|-------|----------|
| booking | الحجوزات | Green (#4CAF50) | Booking confirmations |
| offer | العروض | Orange (#FF9800) | Special offers & deals |
| reminder | التذكيرات | Blue (#2196F3) | Upcoming events |
| update | التحديثات | Purple (#9C27B0) | Changes to bookings |
| cancellation | تم الإلغاء | Red (#F44336) | Cancellations |

## Features Implemented

### User Interactions
- ✅ Tap notification to mark as read
- ✅ Swipe left to delete
- ✅ Pull down to refresh
- ✅ "قراءة الكل" button to mark all as read

### Visual States
- ✅ Unread notifications (yellow background + golden dot)
- ✅ Read notifications (white background)
- ✅ Loading skeleton
- ✅ Empty state with icon and message
- ✅ Error state with retry button

### Navigation
- ✅ Tap notification navigates to related content (TODO: implement navigation logic)
- ✅ Back button returns to previous screen

## Next Steps (Optional Enhancements)

1. **Real-time notifications**: Add Firebase Cloud Messaging (FCM) or WebSocket support
2. **Push notifications**: Integrate with FCM for background notifications
3. **Badge counter**: Add unread count badge to app icon
4. **Notification preferences**: Allow users to configure notification types
5. **Navigation routing**: Implement navigation to related screens based on `relatedId`
6. **Rich notifications**: Add images and action buttons
7. **Notification history**: Add date grouping (Today, Yesterday, This Week)
8. **Search/Filter**: Add ability to filter by notification type

## Testing

To test the implementation:

1. Run the app: `flutter run`
2. Navigate to notifications screen
3. Test all interactions:
   - Tap notifications (mark as read)
   - Swipe to delete
   - Pull to refresh
   - Mark all as read button
   - Empty state (after deleting all)

## Files Summary

**Created (6 files):**
- `lib/data/models/notification_model.dart`
- `lib/data/repositories/notification_repository.dart`
- `lib/logic/blocs/notification/notification_event.dart`
- `lib/logic/blocs/notification/notification_state.dart`
- `lib/logic/blocs/notification/notification_bloc.dart`
- `lib/presentation/screens/user/notifications_list_screen.dart`

**Modified (2 files):**
- `lib/core/di/injection_container.dart`
- `lib/routes/app_router.dart`

## Architecture Compliance

✅ Follows Clean Architecture pattern
✅ Uses BLoC for state management
✅ Repository pattern for data access
✅ Dependency injection with GetIt
✅ Equatable for value equality
✅ Proper error handling
✅ Mock data ready for API switch
✅ RTL Arabic support throughout
✅ Material Design 3 styling

## No Breaking Changes

- All existing functionality remains intact
- No modifications to existing BLoCs or repositories
- No changes to existing screens or widgets
- Only additions to dependency injection and routing
