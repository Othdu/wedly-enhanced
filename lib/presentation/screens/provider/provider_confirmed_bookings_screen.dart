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

/// Dedicated screen for viewing completed bookings
/// Shows bookings with status: completed only
class ProviderConfirmedBookingsScreen extends StatefulWidget {
  const ProviderConfirmedBookingsScreen({super.key});

  @override
  State<ProviderConfirmedBookingsScreen> createState() =>
      _ProviderConfirmedBookingsScreenState();
}

class _ProviderConfirmedBookingsScreenState
    extends State<ProviderConfirmedBookingsScreen> {
  String? _providerId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initialize());
  }

  void _initialize() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      _providerId = authState.user.id;
      _fetchCompletedBookings();
    }
  }

  void _fetchCompletedBookings() {
    if (_providerId == null) return;
    // Fetch all provider bookings, then filter for completed only
    context.read<BookingBloc>().add(
          FetchProviderBookings(_providerId!),
        );
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
          'الحجوزات المكتملة',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _buildBookingsList(),
    );
  }

  Widget _buildBookingsList() {
    return BlocConsumer<BookingBloc, BookingState>(
      listener: (context, state) {
        // Reload when status is updated
        if (state is BookingStatusUpdated) {
          if (_providerId == null) {
            final authState = context.read<AuthBloc>().state;
            if (authState is AuthAuthenticated) {
              _providerId = authState.user.id;
            }
          }
          _fetchCompletedBookings();
        }
      },
      builder: (context, state) {
        if (state is BookingInitial ||
            state is BookingLoading ||
            state is BookingStatusUpdated) {
          return SkeletonLoading.providerConfirmedBookings();
        }

        if (state is BookingError) {
          return ErrorView(
            error: state.error,
            onRetry: () => _fetchCompletedBookings(),
          );
        }

        if (state is BookingsEmpty) {
          return _buildEmpty();
        }

        if (state is BookingsLoaded) {
          // Filter for completed bookings only
          final bookings = state.bookings
              .where((b) => b.status == BookingStatus.completed)
              .toList();

          if (bookings.isEmpty) return _buildEmpty();

          // Calculate summary statistics
          final int totalServices = bookings.length;
          final double totalAmount = bookings.fold(
            0.0,
            (sum, booking) => sum + booking.totalAmount,
          );

          return RefreshIndicator(
            onRefresh: () async => _fetchCompletedBookings(),
            color: AppColors.gold,
            child: Column(
              children: [
                // Summary Section
                _buildSummarySection(totalServices, totalAmount),

                // Bookings List
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 12,
                    ),
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemCount: bookings.length,
                    itemBuilder: (context, index) {
                      final booking = bookings[index];
                      return BookingCard(
                        booking: booking,
                        onViewDetails: () async {
                          final result = await Navigator.of(context).push<bool>(
                            MaterialPageRoute(
                              builder: (newContext) => BlocProvider.value(
                                value: context.read<BookingBloc>(),
                                child: ProviderBookingDetailsScreen(
                                  booking: booking,
                                ),
                              ),
                            ),
                          );

                          // Refresh if booking was updated
                          if (result == true && mounted) {
                            _fetchCompletedBookings();
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildSummarySection(int totalServices, double totalAmount) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.gold.withValues(alpha: 0.1),
            AppColors.gold.withValues(alpha: 0.05),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Total Services Card
          Expanded(
            child: Container(
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
              child: Column(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.gold,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$totalServices',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'خدمة مكتملة',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Total Amount Card
          Expanded(
            child: Container(
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
              child: Column(
                children: [
                  const Icon(
                    Icons.payments,
                    color: Colors.green,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${totalAmount.toStringAsFixed(0)} ج.م',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'إجمالي الإيرادات',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
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
                Icons.check_circle_outline,
                size: 80,
                color: AppColors.gold.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 32),

            // Title
            const Text(
              'لا توجد حجوزات مكتملة',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              'لم تكتمل أي حجوزات بعد',
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
                      'الحجوزات المكتملة ستظهر في هذه القائمة',
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
