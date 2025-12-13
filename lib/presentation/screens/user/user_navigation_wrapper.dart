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

class UserNavigationWrapper extends StatefulWidget {
  final int initialIndex;

  const UserNavigationWrapper({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<UserNavigationWrapper> createState() => _UserNavigationWrapperState();

  // Static method to navigate from child screens
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
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<HomeBloc>(
          create: (context) => getIt<HomeBloc>(),
        ),
        BlocProvider<BookingBloc>(
          create: (context) => getIt<BookingBloc>(),
        ),
        BlocProvider<NotificationBloc>(
          create: (context) => getIt<NotificationBloc>(),
        ),
      ],
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            // If user taps search icon while already on search screen, focus the search field
            if (index == 1 && _currentIndex == 1) {
              // User is already on search screen, focus the search field
              UserSearchScreen.focusSearchField();
            } else {
              // Navigate to the selected screen
              setState(() {
                _currentIndex = index;
              });
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

