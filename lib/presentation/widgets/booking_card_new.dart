import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../data/models/booking_model.dart';
import 'skeleton_image.dart';

class BookingCard extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback? onViewDetails;

  const BookingCard({
    super.key,
    required this.booking,
    this.onViewDetails,
  });

  String _formatDate(DateTime date) {
    // Format date in Arabic using intl package
    final formatter = DateFormat('d MMMM - h:mm a', 'ar');
    return formatter.format(date);
  }

  String _formatNumber(double number) {
    // Format numbers in Arabic locale
    final formatter = NumberFormat('#,###', 'ar');
    return formatter.format(number);
  }

  @override
  Widget build(BuildContext context) {
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
              if (booking.discountPercentage != null && booking.discountPercentage! > 0)
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
                      style: const TextStyle(
                        fontSize: 13,
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
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Customer Name with "اسم العميل:" prefix
                RichText(
                  textDirection: ui.TextDirection.rtl,
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 15,
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
                  _formatDate(booking.bookingDate),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.right,
                  textDirection: ui.TextDirection.rtl,
                ),
                const SizedBox(height: 8),

                // Event Type
                Text(
                  'نوع الخدمة: ${booking.eventType}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.right,
                  textDirection: ui.TextDirection.rtl,
                ),
                const SizedBox(height: 8),

                // Price
                Text(
                  'السعر: ${_formatNumber(booking.totalAmount)} جنيه',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.right,
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
                    child: const Text(
                      'عرض التفاصيل',
                      style: TextStyle(
                        fontSize: 15,
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
