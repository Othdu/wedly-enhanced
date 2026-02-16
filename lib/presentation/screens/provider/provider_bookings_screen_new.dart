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
import '../../widgets/error_view.dart';
import '../../widgets/skeleton_loading.dart';
import 'provider_booking_details_screen.dart';
import 'provider_confirmed_bookings_screen.dart';

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
    context.read<BookingBloc>().add(
      FetchBookingsByStatus(_providerId!, status),
    );
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'الحجوزات',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.check_circle_outline,
              color: AppColors.gold,
            ),
            tooltip: 'عرض الحجوزات المكتملة',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (newContext) => BlocProvider.value(
                    value: context.read<BookingBloc>(),
                    child: const ProviderConfirmedBookingsScreen(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
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
                  return BlocConsumer<BookingBloc, BookingState>(
                    listener: (context, state) {
                      // When booking status is updated, reload the current tab
                      if (state is BookingStatusUpdated) {
                        // Ensure _providerId is set before fetching
                        if (_providerId == null) {
                          final authState = context.read<AuthBloc>().state;
                          if (authState is AuthAuthenticated) {
                            _providerId = authState.user.id;
                          }
                        }
                        _fetchBookingsByStatus(_statusForIndex(_currentTabIndex));
                      }
                    },
                    builder: (context, state) {
                      if (state is BookingInitial || state is BookingLoading || state is BookingStatusUpdated) {
                        return SkeletonLoading.providerBookingsList();
                      }

                      if (state is BookingError) {
                        return ErrorView(
                          error: state.error,
                          onRetry: () => _fetchBookingsByStatus(
                            _statusForIndex(_currentTabIndex),
                          ),
                        );
                      }

                      if (state is BookingsEmpty) {
                        return _buildEmpty(_currentTabIndex);
                      }

                      if (state is BookingsLoaded) {
                        final bookings = state.bookings;
                        if (bookings.isEmpty) return _buildEmpty(_currentTabIndex);

                        return RefreshIndicator(
                          onRefresh: () async => _fetchBookingsByStatus(
                            _statusForIndex(_currentTabIndex),
                          ),
                          color: AppColors.gold,
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 12,
                            ),
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemCount: bookings.length,
                            itemBuilder: (context, index) {
                              final booking = bookings[index];
                              return BookingCard(
                                booking: booking,
                                onViewDetails: () async {
                                  final result = await Navigator.of(context)
                                      .push<bool>(
                                        MaterialPageRoute(
                                          builder: (newContext) =>
                                              BlocProvider.value(
                                                value: context
                                                    .read<BookingBloc>(),
                                                child:
                                                    ProviderBookingDetailsScreen(
                                                      booking: booking,
                                                    ),
                                              ),
                                        ),
                                      );

                                  // Refresh the current tab if booking was updated
                                  if (result == true && mounted) {
                                    _fetchBookingsByStatus(
                                      _statusForIndex(_currentTabIndex),
                                    );
                                  }
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

  Widget _buildEmpty(int tabIndex) {
    // Different messages for each tab
    String title;
    String description;
    IconData icon;

    switch (tabIndex) {
      case 0: // Pending
        title = 'لا توجد حجوزات جديدة';
        description = 'لم يتم استلام أي حجوزات جديدة بعد';
        icon = Icons.pending_actions_outlined;
        break;
      case 1: // Confirmed
        title = 'لا توجد حجوزات مؤكدة';
        description = 'لم تقم بتأكيد أي حجوزات حتى الآن';
        icon = Icons.event_available_outlined;
        break;
      case 2: // Cancelled
        title = 'لا توجد حجوزات مرفوضة';
        description = 'لم تقم برفض أي حجوزات';
        icon = Icons.event_busy_outlined;
        break;
      default:
        title = 'لا توجد حجوزات';
        description = '';
        icon = Icons.event_note_outlined;
    }

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Empty state illustration
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 80,
                color: AppColors.gold.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 32),

            // Title
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              description,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Info box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.blue.shade100,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      tabIndex == 0
                          ? 'ستظهر هنا الحجوزات الجديدة التي تحتاج للمراجعة'
                          : tabIndex == 1
                              ? 'الحجوزات التي قمت بتأكيدها ستظهر هنا'
                              : 'الحجوزات المرفوضة ستظهر في هذه القائمة',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blue.shade700,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
