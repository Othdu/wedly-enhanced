# Notification Icon Implementation Guide

## Visual Structure

```
┌─────────────────────────────────────────────────────────┐
│                     APP BAR (Golden)                     │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  [👤]  أهلاً بك محمد!                      [🛒]  [🔔]   │
│        جاهز تبدأ رحلة تحضيرات زفافك مع Wedly؟    3    5  │
│                                                   │    │  │
│                                             Cart  Badge │
│                                                          │
└─────────────────────────────────────────────────────────┘
         ↑                                          ↑     ↑
    Profile                                      Cart  Notifications
                                                          (NEW!)
```

## Icon Layout (RTL - Right to Left)

Position from **RIGHT to LEFT**:

1. **Far Right**: 🔔 Notification Bell (NEW - Active)
   - Icon: `Icons.notifications_outlined`
   - Color: White on golden circle background
   - Badge: Red circle with number (when unread > 0)
   - Action: Navigate to notifications list

2. **Right**: 🛒 Cart Icon
   - Icon: `Icons.shopping_cart_outlined`
   - Badge: Red circle with cart item count
   - Action: Navigate to cart screen

3. **Center**: Welcome Text
   - "أهلاً بك محمد!"
   - Subtitle about wedding preparation

4. **Far Left**: 👤 Profile Avatar
   - Circular avatar with user image or icon

## Badge Appearance

### Unread Notifications Badge
```
     ┌───┐
     │ 5 │  ← Red circle with white text
     └───┘
        │
        └─ Positioned at top-right of bell icon
```

### Badge States

| Unread Count | Badge Display | Example |
|--------------|---------------|---------|
| 0 | Hidden | 🔔 (no badge) |
| 1-9 | Shows number | 🔔⑤ |
| 10+ | Shows "9+" | 🔔⁹⁺ |

## Component Structure

```dart
GestureDetector(
  onTap: () {
    // Navigate to notifications screen
    Navigator.pushNamed(context, AppRouter.notificationsList);
  },
  child: Stack(
    children: [
      // Bell icon with golden circle background
      Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.notifications_outlined,
          color: Colors.white,
          size: 24,
        ),
      ),
      // Badge (conditional)
      if (unreadCount > 0)
        Positioned(
          top: -4,
          right: -4,
          child: Container(
            // Red badge with count
          ),
        ),
    ],
  ),
)
```

## Interaction Flow

```
┌──────────────────────┐
│   User on Home       │
│                      │
│   Sees badge: 🔔⑤    │
└──────┬───────────────┘
       │
       ▼ (Taps bell)
┌──────────────────────┐
│  Notifications       │
│  Screen Opens        │
│                      │
│  Shows 5 unread      │
│  notifications       │
└──────┬───────────────┘
       │
       ▼ (Marks all read)
┌──────────────────────┐
│  Returns to Home     │
│                      │
│  Badge gone: 🔔      │
└──────────────────────┘
```

## Color Scheme

| Element | Color | Hex Code |
|---------|-------|----------|
| App bar background | Golden gradient | #D4AF37 → #B8941E |
| Icon background | White translucent | rgba(255,255,255,0.2) |
| Icon color | White | #FFFFFF |
| Badge background | Red | #FF0000 |
| Badge text | White | #FFFFFF |

## Responsive Sizing

```
App Bar Height: 70px (50px top padding + 20px bottom)

Icon Container:
- Padding: 12px all sides
- Icon size: 24x24px
- Total touchable area: 48x48px

Badge:
- Min size: 20x20px
- Padding: 4px
- Font size: 10px
- Position: -4px top, -4px right
```

## State Management

```
NotificationBloc
    │
    ├─ NotificationLoading
    │    └─ Badge: Hidden (loading state)
    │
    ├─ NotificationLoaded
    │    ├─ unreadCount = 0 → Badge: Hidden
    │    ├─ unreadCount = 5 → Badge: Shows "5"
    │    └─ unreadCount = 15 → Badge: Shows "9+"
    │
    └─ NotificationError
         └─ Badge: Hidden (error state)
```

## Integration Points

### 1. BLoC Provider (UserNavigationWrapper)
```dart
MultiBlocProvider(
  providers: [
    BlocProvider<HomeBloc>(...),
    BlocProvider<CartBloc>(...),
    BlocProvider<NotificationBloc>(...),  // ← Added
  ],
)
```

### 2. Auto-Load (UserHomeScreen.initState)
```dart
void initState() {
  super.initState();

  // Load notifications
  if (userId != null) {
    context.read<NotificationBloc>().add(
      NotificationsRequested(userId: userId)
    );
  }
}
```

### 3. UI Update (BlocBuilder)
```dart
BlocBuilder<NotificationBloc, NotificationState>(
  builder: (context, notificationState) {
    int unreadCount = 0;
    if (notificationState is NotificationLoaded) {
      unreadCount = notificationState.unreadCount;
    }

    return GestureDetector(...); // Icon with badge
  },
)
```

## Differences from Bookings Tab

| Feature | Bookings Tab (حجوزاتي) | Notification Icon |
|---------|----------------------|-------------------|
| Location | Bottom navigation bar | App bar (top right) |
| Purpose | View user bookings | View all notifications |
| Badge | None | Shows unread count |
| Access | Always visible | Always visible |
| Tap action | Switch to bookings tab | Opens notifications screen |
| Related to | Booking history | All app notifications |

## Before vs After

### Before (Without Notification Integration)
```
App Bar: [👤] Welcome Text [🛒3] [🔔]
                                    ↑
                              Static icon
                              No badge
                              No click action
```

### After (With Notification Integration)
```
App Bar: [👤] Welcome Text [🛒3] [🔔5]
                                    ↑
                              Active icon
                              Red badge (5 unread)
                              Clicks → Notifications screen
```

## Testing Checklist

- [ ] Bell icon visible in home screen app bar
- [ ] Icon positioned on far right (RTL)
- [ ] Badge shows correct unread count
- [ ] Badge shows "9+" when count > 9
- [ ] Badge hidden when unread count = 0
- [ ] Clicking icon navigates to notifications screen
- [ ] Badge updates after marking notifications as read
- [ ] Badge updates after deleting notifications
- [ ] Works on app restart (auto-loads)
- [ ] No interference with cart icon
- [ ] No interference with bookings tab

## Quick Access Code Locations

| File | Line Numbers | What's There |
|------|-------------|--------------|
| user_home_screen.dart | 14-16 | Import statements |
| user_home_screen.dart | 48-51 | Load notifications in initState |
| user_home_screen.dart | 271-327 | Notification icon with badge |
| user_navigation_wrapper.dart | 7 | NotificationBloc import |
| user_navigation_wrapper.dart | 52-54 | NotificationBloc provider |
| app_router.dart | 53 | Notifications route constant |
| app_router.dart | 170-176 | Notifications route handler |

## Common Questions

**Q: Why is it separate from حجوزاتي (Bookings)?**
A: Bookings tab shows user's booking history. Notifications show ALL app notifications (booking updates, offers, reminders, etc.). They serve different purposes.

**Q: Will the badge update automatically?**
A: Yes, when you mark notifications as read or delete them, the badge updates instantly via BLoC state management.

**Q: Can I add more notification types?**
A: Yes! Just add new types to the `NotificationType` enum in `notification_model.dart` and add corresponding icons/colors.

**Q: How do I change badge color?**
A: Edit the `decoration` color in the badge Positioned widget (line 303 in user_home_screen.dart).

**Q: Can users disable notifications?**
A: Not yet, but you can add a settings screen later to let users control notification preferences.

## Summary

✅ **Separate notification icon** in app bar (not in bottom nav)
✅ **Active badge** showing unread count
✅ **Click navigation** to full notifications screen
✅ **Auto-updates** when notifications change
✅ **Clean architecture** using BLoC pattern
✅ **RTL support** for Arabic interface

The notification system is now **fully integrated** and **ready to use**! 🎉
