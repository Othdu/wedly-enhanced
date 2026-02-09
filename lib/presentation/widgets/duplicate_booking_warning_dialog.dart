import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:wedly/core/utils/duplicate_booking_checker.dart';

/// Shows a warning dialog when user tries to book a service they already have booked
class DuplicateBookingWarningDialog extends StatelessWidget {
  final List<Map<String, dynamic>> duplicates;
  final VoidCallback? onViewBookings;
  final String actionButtonText;

  const DuplicateBookingWarningDialog({
    super.key,
    required this.duplicates,
    this.onViewBookings,
    this.actionButtonText = 'متابعة الحجز',
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: AlertDialog(
        backgroundColor: Colors.white,
        elevation: 24,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        titlePadding: EdgeInsets.zero,
        contentPadding: EdgeInsets.zero,
        title: _buildHeader(),
        content: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    _buildHeaderMessage(duplicates),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 18),
                ...duplicates.map((duplicate) => _buildBookingCard(duplicate)),
                const SizedBox(height: 10),
                _buildQuestionRow(),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(child: _cancelButton(context)),
                    const SizedBox(width: 10),
                    Expanded(child: _proceedButton(context)),
                  ],
                ),
                if (onViewBookings != null) ...[
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.center,
                    child: _viewBookingsButton(context),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber.shade400, Colors.amber.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.warning_amber_rounded,
                size: 32,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'تحذير: حجز مكرر',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> duplicate) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        duplicate['service_name'] ?? '',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      if (duplicate['cart_item_name'] != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          duplicate['cart_item_name'],
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black38,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _buildSourceBadge(duplicate),
              ],
            ),
            const SizedBox(height: 12),
            Divider(height: 1, color: Colors.grey.shade200),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.calendar_month_outlined, size: 16, color: Colors.amber.shade700),
                const SizedBox(width: 6),
                Text(
                  duplicate['booking_date'] ?? '',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.access_time_outlined, size: 16, color: Colors.amber.shade700),
                const SizedBox(width: 6),
                Text(
                  _getTimeSlotText(duplicate['time_slot']),
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildStatusBadge(duplicate),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceBadge(Map<String, dynamic> duplicate) {
    final isCart = duplicate['source'] == 'cart';
    final color = isCart ? Colors.blue : Colors.amber;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isCart ? Icons.shopping_cart_outlined : Icons.event_busy,
            size: 13,
            color: color.shade700,
          ),
          const SizedBox(width: 4),
          Text(
            isCart ? 'في السلة' : 'حجز سابق',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(Map<String, dynamic> duplicate) {
    final color = _getStatusColor(duplicate['source'], duplicate['status']);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getStatusIcon(duplicate['source'], duplicate['status']),
            size: 14,
            color: color,
          ),
          const SizedBox(width: 5),
          Text(
            DuplicateBookingChecker.getStatusText(duplicate['status']),
            style: TextStyle(
              fontSize: 13,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.help_outline, size: 16, color: Colors.black38),
        const SizedBox(width: 6),
        const Text(
          'هل تريد المتابعة بالحجز المكرر؟',
          style: TextStyle(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _cancelButton(BuildContext context) {
    return OutlinedButton(
      onPressed: () => Navigator.of(context).pop(false),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: Colors.grey.shade300),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      child: const Text(
        'إلغاء',
        style: TextStyle(color: Colors.black54, fontSize: 15, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _proceedButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () => Navigator.of(context).pop(true),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFD4AF37),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(vertical: 14),
        elevation: 2,
        shadowColor: const Color(0xFFD4AF37).withValues(alpha: 0.4),
      ),
      child: Text(
        actionButtonText,
        style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _viewBookingsButton(BuildContext context) {
    return TextButton.icon(
      onPressed: () {
        Navigator.of(context).pop(false);
        onViewBookings?.call();
      },
      icon: const Icon(Icons.list_alt_outlined, size: 16, color: Color(0xFFD4AF37)),
      label: const Text(
        'عرض حجوزاتي',
        style: TextStyle(color: Color(0xFFD4AF37), fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }

  String _getTimeSlotText(String? timeSlot) {
    if (timeSlot == 'morning') return 'صباحاً';
    if (timeSlot == 'evening') return 'مساءً';
    return timeSlot ?? '';
  }

  IconData _getStatusIcon(String? source, String? status) {
    if (source == 'cart') return Icons.shopping_cart;
    if (status == 'confirmed') return Icons.check_circle;
    if (status == 'pending') return Icons.schedule;
    return Icons.info;
  }

  Color _getStatusColor(String? source, String? status) {
    if (source == 'cart') return Colors.blue.shade700;
    if (status == 'confirmed') return Colors.green.shade700;
    if (status == 'pending') return Colors.orange.shade700;
    return Colors.grey.shade700;
  }

  String _buildHeaderMessage(List<Map<String, dynamic>> dups) {
    final cartItems = dups
        .where((d) => d['cart_item_name'] != null)
        .map((d) => d['cart_item_name'])
        .toSet();

    if (cartItems.length > 1) {
      return 'لديك حجوزات مكررة لـ ${cartItems.length} عناصر في السلة:';
    } else if (dups.length == 1) {
      return 'لديك حجز سابق لنفس الخدمة في نفس التاريخ:';
    } else {
      return 'لديك ${dups.length} حجوزات سابقة لنفس الخدمة في نفس التاريخ:';
    }
  }
}
