import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wedly/core/constants/app_strings.dart';
import 'package:wedly/core/di/injection_container.dart';
import 'package:wedly/logic/blocs/home/home_bloc.dart';
import 'package:wedly/presentation/screens/user/user_home_screen.dart';
import 'package:wedly/presentation/screens/user/user_profile_screen.dart';

class UserNavigationWrapper extends StatefulWidget {
  const UserNavigationWrapper({super.key});

  @override
  State<UserNavigationWrapper> createState() => _UserNavigationWrapperState();
}

class _UserNavigationWrapperState extends State<UserNavigationWrapper> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const UserHomeScreen(),
    const Placeholder(), // TODO: Add bookings screen
    const Placeholder(), // TODO: Add favorites screen
    const UserProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HomeBloc>(
      create: (context) => getIt<HomeBloc>(),
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
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home),
              label: AppStrings.home,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.book),
              label: AppStrings.bookings,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.favorite),
              label: AppStrings.favorites,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person),
              label: AppStrings.profile,
            ),
          ],
        ),
      ),
    );
  }
}

