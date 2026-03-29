import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wedly/core/constants/app_strings.dart';
import 'package:wedly/core/di/injection_container.dart';
import 'package:wedly/logic/blocs/home/home_bloc.dart';
import 'package:wedly/logic/blocs/booking/booking_bloc.dart';
import 'package:wedly/logic/blocs/notification/notification_bloc.dart';
import 'package:wedly/presentation/screens/user/user_home_screen.dart';
import 'package:wedly/presentation/screens/user/user_search_screen.dart';
import 'package:wedly/presentation/screens/user/user_profile_screen.dart';
import 'package:wedly/presentation/screens/user/user_bookings_screen.dart';
import 'package:wedly/routes/app_router.dart';

class UserNavigationWrapper extends StatefulWidget {
  final int initialIndex;
  final bool isGuest;

  const UserNavigationWrapper({
    super.key,
    this.initialIndex = 0,
    this.isGuest = false,
  });

  @override
  State<UserNavigationWrapper> createState() => _UserNavigationWrapperState();

  static void navigateToTab(BuildContext context, int index) {
    final state = context.findAncestorStateOfType<_UserNavigationWrapperState>();
    state?._navigateToTab(index);
  }
}

class _UserNavigationWrapperState extends State<UserNavigationWrapper> {
  late int _currentIndex;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _screens = [
      const UserHomeScreen(),
      const UserSearchScreen(),
      const UserBookingsScreen(),
      const UserProfileScreen(),
    ];
  }

  void _navigateToTab(int index) {
    if (mounted) {
      setState(() => _currentIndex = index);
    }
  }

  void _showLoginPrompt() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              'يجب تسجيل الدخول أولاً',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 8),
            const Text(
              'سجّل دخولك للوصول إلى هذه الميزة',
              style: TextStyle(color: Colors.grey),
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    AppRouter.login,
                    (route) => false,
                  );
                },
                child: const Text(
                  'تسجيل الدخول',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<HomeBloc>(create: (context) => getIt<HomeBloc>()),
        BlocProvider<BookingBloc>(create: (context) => getIt<BookingBloc>()),
        BlocProvider<NotificationBloc>(create: (context) => getIt<NotificationBloc>()),
      ],
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            // Guard bookings (2) and profile (3) for guests
            if (widget.isGuest && (index == 2 || index == 3)) {
              _showLoginPrompt();
              return;
            }

            if (index == 1 && _currentIndex == 1) {
              UserSearchScreen.focusSearchField();
            } else {
              setState(() => _currentIndex = index);
            }
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFFD4AF37),
          unselectedItemColor: Colors.grey,
          items: [
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/images/home-alt.png',
                width: 24,
                height: 24,
                color: _currentIndex == 0 ? const Color(0xFFD4AF37) : Colors.grey,
              ),
              label: AppStrings.home,
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/images/search.png',
                width: 24,
                height: 24,
                color: _currentIndex == 1 ? const Color(0xFFD4AF37) : Colors.grey,
              ),
              label: AppStrings.search,
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/images/calendar-a.png',
                width: 24,
                height: 24,
                color: _currentIndex == 2 ? const Color(0xFFD4AF37) : Colors.grey,
              ),
              label: AppStrings.bookings,
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/images/user.png',
                width: 24,
                height: 24,
                color: _currentIndex == 3 ? const Color(0xFFD4AF37) : Colors.grey,
              ),
              label: AppStrings.profile,
            ),
          ],
        ),
      ),
    );
  }
}