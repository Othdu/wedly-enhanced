import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/enums.dart';
import '../../../data/models/booking_model.dart';
import '../../../logic/blocs/booking/booking_bloc.dart';
import '../../../logic/blocs/booking/booking_event.dart';
import '../../../logic/blocs/booking/booking_state.dart';

class ProviderBookingDetailsScreen extends StatelessWidget {
  final BookingModel booking;

  const ProviderBookingDetailsScreen({
    super.key,
    required this.booking,
  });

  String _formatDate(DateTime date) {
    // Format date in Arabic
    final formatter = DateFormat('d MMMM', 'ar');
    return formatter.format(date);
  }

  String _formatTime(DateTime date) {
    // Format time in Arabic
    final formatter = DateFormat('h:mm a', 'ar');
    return formatter.format(date);
  }

  String _formatNumber(double number) {
    // Format numbers in Arabic locale
    final formatter = NumberFormat('#,###', 'ar');
    return formatter.format(number);
  }

  void _showConfirmDialog(BuildContext context, bool isApproval) {
    // Capture the bloc reference before showing dialog to avoid accessing deactivated widget
    final bookingBloc = context.read<BookingBloc>();

    showDialog(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: ui.TextDirection.rtl,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isApproval ? 'تم تأكيد الحجز بنجاح!' : 'هل أنت متأكد من رفض الحجز؟',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 24),
              if (isApproval)
                // Success button - only show for approval
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      Navigator.of(context).pop(); // Go back to bookings list
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'موافق',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
              else
                // Reject confirmation buttons
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Confirm rejection
                          Navigator.of(dialogContext).pop();
                          bookingBloc.add(
                            UpdateBookingStatus(
                              booking.id,
                              BookingStatus.cancelled,
                            ),
                          );
                          Navigator.of(context).pop(); // Go back to bookings list
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.gold,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'نعم',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.gold,
                          side: const BorderSide(color: AppColors.gold, width: 2),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'لا',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  void _handleApproval(BuildContext context) {
    // TODO: API Integration - Send approval request to backend
    // Endpoint: PUT /api/bookings/{bookingId}/approve
    // Body: { "status": "confirmed" }
    context.read<BookingBloc>().add(
          UpdateBookingStatus(
            booking.id,
            BookingStatus.confirmed,
          ),
        );
    _showConfirmDialog(context, true);
  }

  void _handleRejection(BuildContext context) {
    // TODO: API Integration - Send rejection request to backend
    // Endpoint: PUT /api/bookings/{bookingId}/reject
    // Body: { "status": "cancelled" }
    _showConfirmDialog(context, false);
  }


  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.greyBackground,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: AppBar(
            backgroundColor: AppColors.gold,
            elevation: 0,
            centerTitle: true,
            title: const Text(
              'تفاصيل الحجز',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
          ),
        ),
        body: BlocListener<BookingBloc, BookingState>(
          listener: (context, state) {
            if (state is BookingError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Main content card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Client Details Section
                    _buildSectionHeader('بيانات العميل'),
                    _buildInfoRow('اسم العميل', booking.customerName),
                    const Divider(height: 1, indent: 20, endIndent: 20),

                    // Service Details Section
                    _buildSectionHeader('تفاصيل الخدمة'),
                    _buildInfoRow('نوع الخدمة', booking.eventType),
                    _buildInfoRow('التاريخ', '${_formatDate(booking.bookingDate)}: ${_formatTime(booking.bookingDate)}'),
                    _buildInfoRow('السعر', '${_formatNumber(booking.totalAmount)} جنيه'),
                    _buildInfoRow('الوقت', '${_formatTime(booking.bookingDate)} مساءً'),
                    const Divider(height: 1, indent: 20, endIndent: 20),

                    // Special Requests Section
                    _buildSectionHeader('ملاحظات العميل'),
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                      alignment: Alignment.centerRight,
                      child: Text(
                        booking.specialRequests ?? 'لا توجد ملاحظات خاصة',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Action Buttons (only show for pending bookings)
              if (booking.status == BookingStatus.pending)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // Approve Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _handleApproval(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.gold,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 2,
                          ),
                          child: const Text(
                            'تأكيد الحجز',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Reject Button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => _handleRejection(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red, width: 2),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'إلغاء الحجز',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Status indicator for non-pending bookings
              if (booking.status != BookingStatus.pending)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: booking.status == BookingStatus.confirmed
                          ? Colors.green.shade50
                          : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: booking.status == BookingStatus.confirmed
                            ? Colors.green
                            : Colors.red,
                        width: 2,
                      ),
                    ),
                    child: Text(
                      booking.status == BookingStatus.confirmed
                          ? 'تم تأكيد الحجز'
                          : 'تم إلغاء الحجز',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: booking.status == BookingStatus.confirmed
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      alignment: Alignment.centerRight,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.gold,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Row(
        children: [
          Text(
            '$label:',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
