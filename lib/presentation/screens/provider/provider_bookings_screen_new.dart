import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/enums.dart';
import '../../../logic/blocs/auth/auth_bloc.dart';
import '../../../logic/blocs/auth/auth_state.dart';
import '../../../logic/blocs/booking/booking_bloc.dart';
import '../../../logic/blocs/booking/booking_event.dart';
import '../../../logic/blocs/booking/booking_state.dart';
import '../../widgets/booking_card_new.dart';

class ProviderBookingsScreen extends StatefulWidget {
  const ProviderBookingsScreen({super.key});

  @override
  State<ProviderBookingsScreen> createState() => _ProviderBookingsScreenState();
}

class _ProviderBookingsScreenState extends State<ProviderBookingsScreen> {
  int _currentTabIndex = 0;
  String? _providerId;
  final PageController _pageController = PageController(initialPage: 0);

  final List<String> _tabTitles = [
    'الحجوزات الجديدة',
    'الحجوزات المؤكدة',
    'الحجوزات المرفوضة',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initialize());
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _initialize() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      _providerId = authState.user.id;
      _fetchBookingsByStatus(BookingStatus.pending);
    }
  }

  void _fetchBookingsByStatus(BookingStatus status) {
    if (_providerId == null) return;
    context.read<BookingBloc>().add(FetchBookingsByStatus(_providerId!, status));
  }

  BookingStatus _statusForIndex(int index) {
    switch (index) {
      case 0:
        return BookingStatus.pending;
      case 1:
        return BookingStatus.confirmed;
      case 2:
        return BookingStatus.cancelled;
      default:
        return BookingStatus.pending;
    }
  }

  void _onTabChanged(int index) {
    if (index == _currentTabIndex) return;
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    setState(() => _currentTabIndex = index);
    _fetchBookingsByStatus(_statusForIndex(index));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greyBackground,
      body: SafeArea(
        child: Column(
          children: [
            // ---------------- TAB HEADER ----------------
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                children: List.generate(
                  _tabTitles.length,
                  (index) => Expanded(
                    child: GestureDetector(
                      onTap: () => _onTabChanged(index),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _tabTitles[index],
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _currentTabIndex == index
                                  ? AppColors.gold
                                  : Colors.grey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            height: 3,
                            width: 80,
                            decoration: BoxDecoration(
                              color: _currentTabIndex == index
                                  ? AppColors.gold
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ---------------- TAB CONTENT ----------------
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _tabTitles.length,
                itemBuilder: (context, pageIndex) {
                  return BlocBuilder<BookingBloc, BookingState>(
                    builder: (context, state) {
                      if (state is BookingLoading) {
                        return const Center(
                          child: CircularProgressIndicator(color: AppColors.gold),
                        );
                      }

                      if (state is BookingError) {
                        return _buildError(state.message);
                      }

                      if (state is BookingsLoaded) {
                        final bookings = state.bookings;
                        if (bookings.isEmpty) return _buildEmpty();

                        return RefreshIndicator(
                          onRefresh: () async =>
                              _fetchBookingsByStatus(_statusForIndex(_currentTabIndex)),
                          color: AppColors.gold,
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 12),
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemCount: bookings.length,
                            itemBuilder: (context, index) {
                              final booking = bookings[index];
                              return BookingCard(
                                booking: booking,
                                onViewDetails: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('قريباً: تفاصيل الحجز'),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- REUSABLE WIDGETS ----------------

  Widget _buildError(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'لا توجد حجوزات',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
        ],
      ),
    );
  }
}
