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
              child: BlocBuilder<BookingBloc, BookingState>(
                builder: (context, state) {
                  if (state is BookingLoading) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.gold),
                    );
                  }

                  if (state is BookingError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          Text(state.message, textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadBookings,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.gold,
                            ),
                            child: const Text('إعادة المحاولة'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is BookingsEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 80,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'لا توجد حجوزات',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'ابدأ باستكشاف الخدمات واحجز أول خدمة لك',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
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

  const _BookingCard({
    required this.booking,
    required this.formatDate,
    required this.formatNumber,
    required this.formatPhoneNumber,
    required this.getStatusColor,
    required this.getStatusTextColor,
    required this.getStatusText,
    required this.getStatusTextAr,
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
