import 'package:flutter/material.dart';
import 'package:wedly/data/models/cart_item_model.dart';
import 'package:wedly/data/repositories/booking_repository.dart';
import 'package:wedly/core/utils/enums.dart';
import 'package:intl/intl.dart';

/// Helper class for checking duplicate bookings across cart and existing bookings
class DuplicateBookingChecker {
  final BookingRepository bookingRepository;

  DuplicateBookingChecker({required this.bookingRepository});

  /// Check if the service and date combination already exists in user's bookings or cart
  /// Returns a list of duplicate info maps
  Future<List<Map<String, dynamic>>> checkForDuplicates({
    required String userId,
    required String serviceId,
    required String serviceName,
    required DateTime bookingDate,
    List<CartItemModel>? currentCartItems,
  }) async {
    final duplicates = <Map<String, dynamic>>[];

    try {
      // Check existing bookings from API
      final existingBookings = await bookingRepository.getUserBookings(userId);

      for (var booking in existingBookings) {
        // Only check pending and confirmed bookings (not cancelled or completed)
        if (booking.status == BookingStatus.cancelled ||
            booking.status == BookingStatus.completed) {
          continue;
        }

        // Check if same service and same date
        if (booking.serviceId == serviceId) {
          // Compare dates (ignoring time)
          final existingDate = DateTime(
            booking.bookingDate.year,
            booking.bookingDate.month,
            booking.bookingDate.day,
          );
          final newDate = DateTime(
            bookingDate.year,
            bookingDate.month,
            bookingDate.day,
          );

          if (existingDate == newDate) {
            duplicates.add({
              'source': 'existing_booking',
              'service_name': booking.serviceName,
              'booking_date': DateFormat('dd/MM/yyyy', 'ar').format(booking.bookingDate),
              'time_slot': booking.timeSlot,
              'status': booking.status.name,
            });
          }
        }
      }

      // Check cart items if provided
      if (currentCartItems != null) {
        for (var cartItem in currentCartItems) {
          if (cartItem.service.id == serviceId) {
            // Parse cart item date
            final cartDate = _parseDate(cartItem.date);
            final cartDateOnly = DateTime(
              cartDate.year,
              cartDate.month,
              cartDate.day,
            );
            final newDateOnly = DateTime(
              bookingDate.year,
              bookingDate.month,
              bookingDate.day,
            );

            if (cartDateOnly == newDateOnly) {
              duplicates.add({
                'source': 'cart',
                'service_name': cartItem.service.name,
                'booking_date': cartItem.date,
                'time_slot': cartItem.timeSlot,
                'status': 'في السلة',
              });
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error checking for duplicates: $e');
    }

    return duplicates;
  }

  /// Parse date string to DateTime
  DateTime _parseDate(String dateString) {
    try {
      // Try parsing as ISO format first
      return DateTime.parse(dateString);
    } catch (_) {
      try {
        // Try DD/MM/YYYY format
        if (dateString.contains('/')) {
          final parts = dateString.split('/');
          if (parts.length == 3) {
            return DateTime(
              int.parse(parts[2]), // year
              int.parse(parts[1]), // month
              int.parse(parts[0]), // day
            );
          }
        }
      } catch (_) {}
      return DateTime.now();
    }
  }

  /// Get Arabic text for booking status
  static String getStatusText(String? status) {
    switch (status) {
      case 'pending':
        return 'قيد الانتظار';
      case 'confirmed':
        return 'مؤكد';
      case 'completed':
        return 'مكتمل';
      case 'cancelled':
        return 'ملغي';
      case 'في السلة':
        return 'في السلة';
      default:
        return status ?? '';
    }
  }

  /// Format date from various formats
  static String formatDate(String dateString) {
    try {
      DateTime date;
      if (dateString.contains('T')) {
        date = DateTime.parse(dateString);
      } else if (dateString.contains('/')) {
        final parts = dateString.split('/');
        date = DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      } else {
        return dateString;
      }
      return DateFormat('dd/MM/yyyy', 'ar').format(date);
    } catch (_) {
      return dateString;
    }
  }
}
