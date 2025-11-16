import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wedly/core/constants/app_strings.dart';
import 'package:wedly/core/di/injection_container.dart';
import 'package:wedly/logic/blocs/home/home_bloc.dart';
import 'package:wedly/logic/blocs/booking/booking_bloc.dart';
import 'package:wedly/presentation/screens/user/user_home_screen.dart';
import 'package:wedly/presentation/screens/user/user_profile_screen.dart';
import 'package:wedly/presentation/screens/user/user_bookings_screen.dart';

class UserNavigationWrapper extends StatefulWidget {
  const UserNavigationWrapper({super.key});

  @override
  State<UserNavigationWrapper> createState() => _UserNavigationWrapperState();
}

class _UserNavigationWrapperState extends State<UserNavigationWrapper> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const UserHomeScreen(),
      const Placeholder(), // TODO: Add search screen
      const UserBookingsScreen(),
      const UserProfileScreen(),
    ];
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
      ],
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
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

