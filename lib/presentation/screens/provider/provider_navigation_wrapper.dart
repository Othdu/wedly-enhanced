import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wedly/core/di/injection_container.dart';
import 'package:wedly/logic/blocs/booking/booking_bloc.dart';
import 'package:wedly/logic/blocs/provider_service/provider_service_bloc.dart';
import 'package:wedly/presentation/screens/provider/provider_services_screen.dart';
import 'package:wedly/presentation/screens/provider/provider_bookings_screen_new.dart';
import 'package:wedly/presentation/screens/provider/provider_profile_screen_final.dart';

class ProviderNavigationWrapper extends StatefulWidget {
  const ProviderNavigationWrapper({super.key});

  @override
  State<ProviderNavigationWrapper> createState() =>
      _ProviderNavigationWrapperState();
}

class _ProviderNavigationWrapperState
    extends State<ProviderNavigationWrapper> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const ProviderServicesScreen(),
    const ProviderBookingsScreen(),
    const ProviderProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ProviderServiceBloc>(
          create: (context) => getIt<ProviderServiceBloc>(),
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
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.work),
              label: 'خدماتي',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: 'الحجوزات',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'حسابي',
            ),
          ],
        ),
      ),
    );
  }
}

