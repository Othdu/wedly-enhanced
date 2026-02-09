import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../data/models/booking_model.dart';
import 'skeleton_image.dart';

class BookingCard extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback? onViewDetails;

  const BookingCard({super.key, required this.booking, this.onViewDetails});

  String _formatDate(DateTime date) {
    // Debug: Print the raw date to see what we're getting
    debugPrint('📅 BookingCard: Raw date = $date (isUtc: ${date.isUtc})');
    debugPrint('📅 BookingCard: Year=${date.year}, Month=${date.month}, Day=${date.day}, Hour=${date.hour}');

    // Manual Arabic month names to avoid intl package issues
    const arabicMonths = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];

    // Format manually: day + month + time
    final day = date.day;
    final month = arabicMonths[date.month - 1];
    final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'م' : 'ص';

    final formatted = '$day $month - الساعة $hour:$minute $period';
    debugPrint('📅 BookingCard: Formatted date = $formatted');
    return formatted;
  }

  String _formatNumber(double number) {
    // Format numbers in Arabic locale
    final formatter = NumberFormat('#,###', 'ar');
    return formatter.format(number);
  }

  @override
  Widget build(BuildContext context) {
    // Get screen width for responsive sizing
    final screenWidth = MediaQuery.of(context).size.width;
    final scaleFactor = (screenWidth / 375).clamp(0.9, 1.4);

    // Responsive font sizes with minimum values
    final titleFontSize = (17 * scaleFactor).clamp(15.0, 20.0);
    final detailFontSize = (16 * scaleFactor).clamp(14.0, 19.0);
    final badgeFontSize = (15 * scaleFactor).clamp(14.0, 18.0);
    final buttonFontSize = (17 * scaleFactor).clamp(15.0, 20.0);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Service Image with Discount Badge
          Stack(
            children: [
              SkeletonImage(
                imageUrl: booking.serviceImage,
                width: double.infinity,
                height: 160,
                fit: BoxFit.cover,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                errorWidget: const Icon(
                  Icons.event,
                  size: 60,
                  color: AppColors.gold,
                ),
              ),
              // Display discount badge if booking has discount
              if (booking.discountPercentage != null &&
                  booking.discountPercentage! > 0)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '-${booking.discountPercentage!.toInt()}%',
                      style: TextStyle(
                        fontSize: badgeFontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          // Service Details
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Customer Name with "اسم العميل:" prefix
                RichText(
                  textDirection: ui.TextDirection.rtl,
                  textAlign: TextAlign.left,
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gold,
                    ),
                    children: [
                      const TextSpan(text: 'اسم العميل: '),
                      TextSpan(text: booking.customerName),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Date and Time
                Text(
                  'التاريخ: ${_formatDate(booking.bookingDate)}',
                  style: TextStyle(
                    fontSize: detailFontSize,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.left,
                  textDirection: ui.TextDirection.rtl,
                ),
                const SizedBox(height: 8),

                // Service Name
                Text(
                  'نوع الخدمة: ${booking.serviceName}',
                  style: TextStyle(
                    fontSize: detailFontSize,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.left,
                  textDirection: ui.TextDirection.rtl,
                ),
                const SizedBox(height: 8),

                // Price
                Text(
                  'السعر: ${_formatNumber(booking.totalAmount)} جنيه',
                  style: TextStyle(
                    fontSize: detailFontSize,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.left,
                  textDirection: ui.TextDirection.rtl,
                ),
                const SizedBox(height: 16),

                // View Details Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onViewDetails,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'عرض التفاصيل',
                      style: TextStyle(
                        fontSize: buttonFontSize,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
