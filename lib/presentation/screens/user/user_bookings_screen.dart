import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wedly/core/constants/app_colors.dart';
import 'package:wedly/core/utils/enums.dart';
import 'package:wedly/logic/blocs/auth/auth_bloc.dart';
import 'package:wedly/logic/blocs/auth/auth_state.dart';
import 'package:wedly/logic/blocs/booking/booking_bloc.dart';
import 'package:wedly/logic/blocs/booking/booking_event.dart';
import 'package:wedly/logic/blocs/booking/booking_state.dart';
import 'package:wedly/data/models/booking_model.dart';
import 'package:wedly/presentation/widgets/error_view.dart';
import 'package:wedly/presentation/widgets/review_bottom_sheet.dart';
import 'package:wedly/presentation/screens/user/user_navigation_wrapper.dart';

class UserBookingsScreen extends StatefulWidget {
  const UserBookingsScreen({super.key});

  @override
  State<UserBookingsScreen> createState() => _UserBookingsScreenState();
}

class _UserBookingsScreenState extends State<UserBookingsScreen> {
  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  void _loadBookings() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<BookingBloc>().add(FetchUserBookings(authState.user.id));
    }
  }

  void _showReviewBottomSheet(BookingModel booking) {
    ReviewBottomSheet.show(
      context: context,
      targetId: booking.serviceId,
      targetType: booking.reviewTargetType, // Auto-detects 'venue' or 'service' based on category
      serviceName: booking.serviceName,
      onReviewSubmitted: () {
        // Reload bookings to update the hasReviewed status
        _loadBookings();
      },
    );
  }

  void _showEditReviewBottomSheet(BookingModel booking) {
    if (booking.reviewId == null) return;

    ReviewBottomSheet.showEdit(
      context: context,
      targetId: booking.serviceId,
      targetType: booking.reviewTargetType, // Auto-detects 'venue' or 'service' based on category
      serviceName: booking.serviceName,
      reviewId: booking.reviewId!,
      existingRating: booking.reviewRating ?? 5.0,
      existingComment: booking.reviewComment ?? '',
      onReviewSubmitted: () {
        // Reload bookings to update the review data
        _loadBookings();
      },
    );
  }

  String _formatDate(DateTime date) {
    final formatter = DateFormat('d نوفمبر - الساعة h:mm a', 'ar');
    return formatter.format(date);
  }

  String _formatNumber(double number) {
    final formatter = NumberFormat('#,###', 'ar');
    return formatter.format(number);
  }

  String _formatPhoneNumber(String phone) {
    // Remove all non-digit characters
    String digitsOnly = phone.replaceAll(RegExp(r'[^\d+]'), '');

    // Format as: 4567 123 100 20+ (reversed for RTL display)
    if (digitsOnly.startsWith('+20')) {
      String withoutCountryCode = digitsOnly.substring(3);
      if (withoutCountryCode.length == 10) {
        String last4 = withoutCountryCode.substring(6);
        String middle3 = withoutCountryCode.substring(3, 6);
        String first3 = withoutCountryCode.substring(0, 3);
        return '$last4 $middle3 $first3 20+';
      }
    }

    // Return original if format doesn't match
    return phone;
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return const Color(0xFFFFF8E1);
      case BookingStatus.confirmed:
        return const Color(0xFFE3F2FD);
      case BookingStatus.completed:
        return const Color(0xFFE8F5E9);
      case BookingStatus.cancelled:
        return const Color(0xFFFFEBEE);
    }
  }

  Color _getStatusTextColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return const Color(0xFFF57C00);
      case BookingStatus.confirmed:
        return const Color(0xFF1976D2);
      case BookingStatus.completed:
        return const Color(0xFF388E3C);
      case BookingStatus.cancelled:
        return const Color(0xFFD32F2F);
    }
  }

  String _getStatusText(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return 'قيد الانتظار';
      case BookingStatus.confirmed:
        return 'مؤكد';
      case BookingStatus.completed:
        return 'مكتمل';
      case BookingStatus.cancelled:
        return 'ملغي';
    }
  }

  String _getStatusTextAr(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return 'قيد الانتظار';
      case BookingStatus.confirmed:
        return 'مؤكد';
      case BookingStatus.completed:
        return 'مكتمل';
      case BookingStatus.cancelled:
        return 'ملغي';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: BlocConsumer<BookingBloc, BookingState>(
                listener: (context, state) {
                  // When booking status is updated, reload the bookings list
                  if (state is BookingStatusUpdated) {
                    _loadBookings();
                  }
                },
                builder: (context, state) {
                  if (state is BookingInitial || state is BookingLoading || state is BookingStatusUpdated) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.gold),
                    );
                  }

                  if (state is BookingError) {
                    return ErrorView(
                      error: state.error,
                      onRetry: _loadBookings,
                    );
                  }

                  if (state is BookingsEmpty) {
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
                                Icons.event_available_outlined,
                                size: 80,
                                color: AppColors.gold.withValues(alpha: 0.7),
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Title
                            const Text(
                              'لا توجد حجوزات بعد',
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
                              'ابدأ باستكشاف خدماتنا المميزة\nواحجز ما يناسب احتياجاتك',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey.shade600,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),

                            // Action Button
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  // Navigate to home/services tab (index 0)
                                  UserNavigationWrapper.navigateToTab(context, 0);
                                },
                                icon: const Icon(Icons.search_rounded),
                                label: const Text(
                                  'استكشف الخدمات',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.gold,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

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
                                      'ستظهر جميع حجوزاتك هنا بمجرد إتمام أول حجز',
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

                  if (state is BookingsLoaded) {
                    return RefreshIndicator(
                      onRefresh: () async {
                        _loadBookings();
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        itemCount: state.bookings.length,
                        itemBuilder: (context, index) {
                          final booking = state.bookings[index];
                          return _BookingCard(
                            booking: booking,
                            formatDate: _formatDate,
                            formatNumber: _formatNumber,
                            formatPhoneNumber: _formatPhoneNumber,
                            getStatusColor: _getStatusColor,
                            getStatusTextColor: _getStatusTextColor,
                            getStatusText: _getStatusText,
                            getStatusTextAr: _getStatusTextAr,
                            onReviewTap: (booking.status == BookingStatus.completed || booking.status == BookingStatus.confirmed) && !booking.hasReviewed
                                ? () => _showReviewBottomSheet(booking)
                                : null,
                            onEditReviewTap: (booking.status == BookingStatus.completed || booking.status == BookingStatus.confirmed) && booking.hasReviewed
                                ? () => _showEditReviewBottomSheet(booking)
                                : null,
                          );
                        },
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final BookingModel booking;
  final String Function(DateTime) formatDate;
  final String Function(double) formatNumber;
  final String Function(String) formatPhoneNumber;
  final Color Function(BookingStatus) getStatusColor;
  final Color Function(BookingStatus) getStatusTextColor;
  final String Function(BookingStatus) getStatusText;
  final String Function(BookingStatus) getStatusTextAr;
  final VoidCallback? onReviewTap;
  final VoidCallback? onEditReviewTap;

  const _BookingCard({
    required this.booking,
    required this.formatDate,
    required this.formatNumber,
    required this.formatPhoneNumber,
    required this.getStatusColor,
    required this.getStatusTextColor,
    required this.getStatusText,
    required this.getStatusTextAr,
    this.onReviewTap,
    this.onEditReviewTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    booking.serviceName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: getStatusColor(booking.status),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                getStatusText(booking.status),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: getStatusTextColor(booking.status),
                ),
              ),
            ),

            const SizedBox(height: 12),

            _buildInfoRow(
              label: 'الاسم',
              value: booking.serviceName,
              valueColor: Colors.black87,
            ),

            _buildInfoRow(
              label: 'السعر',
              value: '${formatNumber(booking.totalAmount)} جنيه',
              valueColor: Colors.black87,
            ),

            _buildInfoRow(
              label: 'التاريخ',
              value: formatDate(booking.bookingDate),
              valueColor: Colors.black87,
            ),

            _buildInfoRow(
              label: 'للتواصل',
              value: formatPhoneNumber(booking.customerPhone),
              valueColor: Colors.black,
            ),

            // Review button - show for completed and confirmed bookings that haven't been reviewed
            if ((booking.status == BookingStatus.completed || booking.status == BookingStatus.confirmed) && !booking.hasReviewed) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onReviewTap,
                  icon: const Icon(Icons.star_rounded, size: 20),
                  label: const Text(
                    'قيّم الخدمة',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],

            // Show "Edit Review" button for reviewed bookings
            if ((booking.status == BookingStatus.completed || booking.status == BookingStatus.confirmed) && booking.hasReviewed) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onEditReviewTap,
                  icon: const Icon(Icons.edit_rounded, size: 18),
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'تعديل التقييم',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Show current rating stars
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(5, (index) {
                          final starIndex = index + 1;
                          return Icon(
                            starIndex <= (booking.reviewRating ?? 0)
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            size: 16,
                            color: starIndex <= (booking.reviewRating ?? 0)
                                ? AppColors.gold
                                : Colors.grey.shade300,
                          );
                        }),
                      ),
                    ],
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.green.shade700,
                    side: BorderSide(color: Colors.green.shade300),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.gold,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
