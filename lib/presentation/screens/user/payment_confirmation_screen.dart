// FULL UPDATED FILE WITH CLEAN APPOINTMENT FORMAT

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wedly/data/models/cart_item_model.dart';
import 'package:wedly/data/repositories/booking_repository.dart';
import 'package:wedly/data/repositories/auth_repository.dart';
import 'package:wedly/data/services/api_exceptions.dart';
import 'package:wedly/logic/blocs/auth/auth_bloc.dart';
import 'package:wedly/logic/blocs/auth/auth_event.dart';
import 'package:wedly/logic/blocs/auth/auth_state.dart';
import 'package:wedly/logic/blocs/cart/cart_bloc.dart';
import 'package:wedly/logic/blocs/cart/cart_event.dart';
import 'package:wedly/logic/blocs/home/home_bloc.dart';
import 'package:wedly/logic/blocs/home/home_event.dart';
import 'package:wedly/presentation/screens/user/user_navigation_wrapper.dart';
import 'package:wedly/core/di/injection_container.dart';
import 'package:intl/intl.dart';

class PaymentConfirmationScreen extends StatefulWidget {
  final String paymentMethod;
  final List<CartItemModel> cartItems;
  final double totalAmount;

  const PaymentConfirmationScreen({
    super.key,
    required this.paymentMethod,
    required this.cartItems,
    required this.totalAmount,
  });

  @override
  State<PaymentConfirmationScreen> createState() =>
      _PaymentConfirmationScreenState();
}

class _PaymentConfirmationScreenState extends State<PaymentConfirmationScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _specialRequestsController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      _nameController.text = authState.user.name;
      _emailController.text = authState.user.email;
      _phoneController.text = authState.user.phone ?? '';
      _addressController.text = authState.user.city ?? '';
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _notesController.dispose();
    _specialRequestsController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // Clean appointment formatter added here
  String _formatAppointment() {
    if (widget.cartItems.isEmpty) return '';
    final item = widget.cartItems.first;
    final date = _formatDate(item.date);
    return '$date - ${item.time}';
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final user = authState is AuthAuthenticated ? authState.user : null;

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          backgroundColor: const Color(0xFFD4AF37),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: const Text(
            'الدفع الإلكتروني',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('وسيلة الدفع:'),
                      const SizedBox(height: 12),
                      _buildPaymentMethodSection(),
                      const SizedBox(height: 24),

                      _buildSectionTitle('بيانات العميل', isBold: true),
                      const SizedBox(height: 16),
                      _buildCustomerDetails(user),
                      const SizedBox(height: 24),

                      // Notes and Special Requests section
                      _buildSectionTitle('ملاحظات وطلبات خاصة', isBold: true),
                      const SizedBox(height: 16),
                      _buildNotesSection(),
                      const SizedBox(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'القيمة',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildItemizedCosts(),
                      const SizedBox(height: 12),
                      Divider(color: Colors.grey[300], thickness: 1),
                      const SizedBox(height: 12),

                      _buildTotalAmount(),
                    ],
                  ),
                ),
              ),
            ),

            _buildPayButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, {bool isBold = false}) {
    return Text(
      title,
      style: TextStyle(
        fontSize: isBold ? 16 : 14,
        fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
        color: isBold ? Colors.black : const Color(0xFFD4AF37),
      ),
      textAlign: TextAlign.right,
    );
  }

  Widget _buildPaymentMethodSection() {
    String paymentMethodName = '';
    IconData paymentIcon = Icons.account_balance_wallet;

    switch (widget.paymentMethod) {
      case 'wallet':
        paymentMethodName = 'محفظة إلكترونية (Vodafone Cash)';
        paymentIcon = Icons.account_balance_wallet;
        break;
      case 'visa':
        paymentMethodName = 'فيزا';
        paymentIcon = Icons.credit_card;
        break;
      case 'cash':
        paymentMethodName = 'نقداً عند التنفيذ';
        paymentIcon = Icons.money;
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              paymentMethodName,
              style: const TextStyle(fontSize: 14, color: Colors.black),
              textAlign: TextAlign.right,
            ),
            const SizedBox(width: 8),
            Icon(paymentIcon, color: Colors.black, size: 20),
          ],
        ),
        if (widget.paymentMethod == 'wallet') ...[
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Flexible(
                flex: 1,
                child: Text(
                  'رقم الهاتف',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFFD4AF37),
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
              const SizedBox(width: 16),
              Flexible(
                flex: 3,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Directionality(
                    textDirection: ui.TextDirection.ltr,
                    child: Text(
                      _phoneController.text.isEmpty
                          ? '+20 100 123 4567'
                          : _phoneController.text,
                      style: const TextStyle(fontSize: 14, color: Colors.black),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildCustomerDetails(user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildEditableDetailRow(
          label: 'الاسم',
          controller: _nameController,
        ),
        _buildEditableDetailRow(
          label: 'البريد الإلكتروني',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
        ),
        _buildEditableDetailRow(
          label: 'رقم الهاتف',
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          isLtr: true,
        ),
        _buildEditableDetailRow(
          label: 'العنوان',
          controller: _addressController,
        ),
      ],
    );
  }

  Widget _buildEditableDetailRow({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool isLtr = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            flex: 1,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFFD4AF37),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            flex: 3,
            child: Directionality(
              textDirection: isLtr ? ui.TextDirection.ltr : ui.TextDirection.rtl,
              child: TextField(
                controller: controller,
                keyboardType: keyboardType,
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 14, color: Colors.black),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(color: Color(0xFFD4AF37)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            flex: 1,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFFD4AF37),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            flex: 3,
            child: Align(
              alignment: Alignment.centerRight,
              child: Directionality(
                textDirection: ui.TextDirection.ltr,
                child: Text(
                  value,
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (_) {
      try {
        if (dateString.contains('/')) {
          final parts = dateString.split('/');
          if (parts.length == 3) {
            final day = int.parse(parts[0]);
            final month = int.parse(parts[1]);
            final year = int.parse(parts[2]);
            final date = DateTime(year, month, day);
            return DateFormat('dd/MM/yyyy').format(date);
          }
        }
      } catch (_) {}
    }
    return dateString;
  }

  Widget _buildItemizedCosts() {
    if (widget.cartItems.isEmpty) {
      return const SizedBox.shrink();
    }

    List<Widget> items = [];

    for (var cartItem in widget.cartItems) {
      items.add(
        _buildDetailRow(
          label: cartItem.service.category,
          value:
              '\u202B${NumberFormat('#,###').format(cartItem.servicePrice.toInt())} جنية\u202C',
        ),
      );

      if (cartItem.photographerPrice > 0) {
        items.add(
          _buildDetailRow(
            label: 'المصور',
            value:
                '\u202B${NumberFormat('#,###').format(cartItem.photographerPrice.toInt())} جنية\u202C',
          ),
        );
      }
    }

    // NEW CLEAN APPOINTMENT INSERTED HERE
    final appointment = _formatAppointment();
    if (appointment.isNotEmpty) {
      items.add(_buildDetailRow(label: 'الموعد', value: appointment));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items,
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Notes field
        const Text(
          'ملاحظات',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFFD4AF37),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _notesController,
          maxLines: 2,
          textDirection: ui.TextDirection.rtl,
          decoration: InputDecoration(
            hintText: 'أضف أي ملاحظات هنا...',
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFD4AF37)),
            ),
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
        const SizedBox(height: 16),

        // Special Requests field
        const Text(
          'طلبات خاصة',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFFD4AF37),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _specialRequestsController,
          maxLines: 2,
          textDirection: ui.TextDirection.rtl,
          decoration: InputDecoration(
            hintText: 'أضف أي طلبات خاصة هنا...',
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFD4AF37)),
            ),
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
      ],
    );
  }

  Widget _buildTotalAmount() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Flexible(
          flex: 1,
          child: Text(
            'المبلغ الإجمالي',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFFD4AF37),
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.right,
          ),
        ),
        const SizedBox(width: 16),
        Flexible(
          flex: 3,
          child: Align(
            alignment: Alignment.centerRight,
            child: Directionality(
              textDirection: ui.TextDirection.ltr,
              child: Text(
                '\u202B${NumberFormat('#,###').format(widget.totalAmount.toInt())} جنية\u202C',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPayButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            onPressed: () {
              _handlePayment();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'دفع',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Parse date string to DateTime
  DateTime _parseBookingDate(String dateString) {
    try {
      // Try parsing as ISO format first
      return DateTime.parse(dateString);
    } catch (_) {
      try {
        // Try DD/MM/YYYY format
        if (dateString.contains('/')) {
          final parts = dateString.split('/');
          if (parts.length == 3) {
            final day = int.parse(parts[0]);
            final month = int.parse(parts[1]);
            final year = int.parse(parts[2]);
            // Create datetime with noon time to avoid timezone issues
            return DateTime(year, month, day, 12, 0, 0);
          }
        }
        // Try Arabic date format like "15 نوفمبر"
        final arabicMonths = {
          'يناير': 1, 'فبراير': 2, 'مارس': 3, 'أبريل': 4,
          'مايو': 5, 'يونيو': 6, 'يوليو': 7, 'أغسطس': 8,
          'سبتمبر': 9, 'أكتوبر': 10, 'نوفمبر': 11, 'ديسمبر': 12,
        };
        final parts = dateString.split(' ');
        if (parts.length >= 2) {
          final day = int.tryParse(parts[0]) ?? 1;
          final monthName = parts[1];
          final month = arabicMonths[monthName] ?? DateTime.now().month;
          final year = DateTime.now().year;
          return DateTime(year, month, day, 12, 0, 0);
        }
      } catch (_) {}
    }
    // Fallback to current date with noon time
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, 12, 0, 0);
  }

  /// Format datetime to ISO 8601 format that the API expects (YYYY-MM-DDTHH:MM:SS.000Z)
  String _formatToIso8601(DateTime date) {
    // Format as UTC ISO 8601 string
    return date.toUtc().toIso8601String();
  }

  /// Validates that booking dates are not in the past
  bool _validateBookingDates() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (final cartItem in widget.cartItems) {
      final bookingDate = _parseBookingDate(cartItem.date);
      final bookingDay = DateTime(bookingDate.year, bookingDate.month, bookingDate.day);

      if (bookingDay.isBefore(today)) {
        showDialog(
          context: context,
          builder: (context) => Directionality(
            textDirection: ui.TextDirection.rtl,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Icon(Icons.event_busy, color: Colors.orange, size: 28),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'تاريخ الحجز منتهي',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'تاريخ حجز "${cartItem.service.name}" (${cartItem.date}) قد مضى.',
                    style: const TextStyle(fontSize: 15, height: 1.5),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'يرجى حذف هذا العنصر من السلة واختيار تاريخ جديد.',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.of(context).pop(); // Go back to cart
                  },
                  child: const Text(
                    'العودة للسلة',
                    style: TextStyle(color: Color(0xFFD4AF37)),
                  ),
                ),
              ],
            ),
          ),
        );
        return false;
      }
    }
    return true;
  }

  /// Validates that all required customer fields are filled
  bool _validateCustomerDetails() {
    final List<String> emptyFields = [];

    if (_nameController.text.trim().isEmpty) {
      emptyFields.add('الاسم');
    }
    if (_emailController.text.trim().isEmpty) {
      emptyFields.add('البريد الإلكتروني');
    }
    if (_phoneController.text.trim().isEmpty) {
      emptyFields.add('رقم الهاتف');
    }
    if (_addressController.text.trim().isEmpty) {
      emptyFields.add('العنوان');
    }

    if (emptyFields.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) => Directionality(
          textDirection: ui.TextDirection.rtl,
          child: AlertDialog(
            title: const Text(
              'بيانات ناقصة',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('يرجى إكمال البيانات التالية قبل المتابعة:'),
                const SizedBox(height: 12),
                ...emptyFields.map((field) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      const Icon(Icons.circle, size: 8, color: Color(0xFFD4AF37)),
                      const SizedBox(width: 8),
                      Text(field),
                    ],
                  ),
                )),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'حسناً',
                  style: TextStyle(color: Color(0xFFD4AF37)),
                ),
              ),
            ],
          ),
        ),
      );
      return false;
    }
    return true;
  }

  Future<void> _handlePayment() async {
    // Validate booking dates are not in the past
    if (!_validateBookingDates()) {
      return;
    }

    // Validate customer details
    if (!_validateCustomerDetails()) {
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Directionality(
          textDirection: ui.TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: Colors.white,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD4AF37)),
                ),
                const SizedBox(height: 20),
                const Text(
                  'جاري معالجة الدفع...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );

    try {
      // Get user info
      final authState = context.read<AuthBloc>().state;
      final user = authState is AuthAuthenticated ? authState.user : null;

      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Get booking repository
      final bookingRepository = getIt<BookingRepository>();

      // Create bookings for each cart item
      for (final cartItem in widget.cartItems) {
        // Parse the date and format to ISO 8601
        final bookingDate = _parseBookingDate(cartItem.date);
        final bookingDateIso = _formatToIso8601(bookingDate);

        // Build booking data matching API spec
        // Use controller values with fallbacks from user object if empty
        debugPrint('🔴 PaymentConfirmation - cartItem.timeSlot: "${cartItem.timeSlot}"');
        debugPrint('🔴 PaymentConfirmation - cartItem.timeSlot.isEmpty: ${cartItem.timeSlot.isEmpty}');
        final timeSlot = cartItem.timeSlot.isNotEmpty ? cartItem.timeSlot : 'morning';
        debugPrint('🔴 PaymentConfirmation - final timeSlot: "$timeSlot"');

        // Get values from controllers, fallback to user data if empty
        final customerName = _nameController.text.trim().isNotEmpty
            ? _nameController.text.trim()
            : user.name;
        final customerEmail = _emailController.text.trim().isNotEmpty
            ? _emailController.text.trim()
            : user.email;
        final customerPhone = _phoneController.text.trim().isNotEmpty
            ? _phoneController.text.trim()
            : (user.phone ?? '+201000000000');
        final eventLocation = _addressController.text.trim().isNotEmpty
            ? _addressController.text.trim()
            : (user.city ?? 'القاهرة');

        // Debug: Print controller values
        debugPrint('Customer name controller: "${_nameController.text}" -> "$customerName"');
        debugPrint('Customer email controller: "${_emailController.text}" -> "$customerEmail"');
        debugPrint('Customer phone controller: "${_phoneController.text}" -> "$customerPhone"');
        debugPrint('Event location controller: "${_addressController.text}" -> "$eventLocation"');
        debugPrint('TimeSlot from cart item: "${cartItem.timeSlot}" -> "$timeSlot"');

        final Map<String, dynamic> bookingData = {
          'service_id': cartItem.service.id,
          'booking_date': bookingDateIso,
          'time_slot': timeSlot, // "morning" or "evening"
          'customer_name': customerName,
          'customer_email': customerEmail,
          'customer_phone': customerPhone,
          'event_type': cartItem.service.category.isNotEmpty ? cartItem.service.category : 'خدمة',
          'guest_count': 1, // Always 1
          'event_location': eventLocation,
          'payment_method': 'cash', // Only cash for now
        };

        // Only add optional fields if they have values
        final notes = _notesController.text.trim();
        debugPrint('Notes controller text: "${_notesController.text}"');
        debugPrint('Notes trimmed: "$notes"');
        debugPrint('Notes isEmpty: ${notes.isEmpty}');
        if (notes.isNotEmpty) {
          bookingData['notes'] = notes;
        }
        final specialRequests = _specialRequestsController.text.trim();
        if (specialRequests.isNotEmpty) {
          bookingData['special_requests'] = specialRequests;
        }

        // Only add section/option IDs if they have values
        if (cartItem.selectedSectionId != null && cartItem.selectedSectionId!.isNotEmpty) {
          bookingData['selected_section_id'] = cartItem.selectedSectionId;
        }
        if (cartItem.selectedOptionIds != null && cartItem.selectedOptionIds!.isNotEmpty) {
          bookingData['selected_option_id'] = cartItem.selectedOptionIds;
        }

        // Debug: Print booking data before sending to API
        debugPrint('Creating booking with data:');
        bookingData.forEach((key, value) {
          debugPrint('  $key: $value');
        });

        // Call booking API
        await bookingRepository.createBooking(bookingData);
      }

      // Clear cart after successful booking
      if (mounted) {
        context.read<CartBloc>().add(CartCleared());
      }

      // Set wedding date if user booked a venue
      // This triggers the countdown timer to appear on home screen
      final venueBooking = widget.cartItems.firstWhere(
        (item) => item.service.category == '2' || // Category ID 2 is venues
                  item.service.category.toLowerCase() == 'venue' ||
                  item.service.category.toLowerCase() == 'venues' ||
                  item.service.category == 'قاعات الأفراح',
        orElse: () => widget.cartItems.first, // fallback (shouldn't happen)
      );

      // Check if we actually found a venue booking
      final isVenueBooking = venueBooking.service.category == '2' ||
                             venueBooking.service.category.toLowerCase() == 'venue' ||
                             venueBooking.service.category.toLowerCase() == 'venues' ||
                             venueBooking.service.category == 'قاعات الأفراح';

      if (isVenueBooking && mounted) {
        final weddingDate = _parseBookingDate(venueBooking.date);
        final authRepository = getIt<AuthRepository>();

        try {
          await authRepository.setWeddingDate(weddingDate);
          debugPrint('✅ Wedding date set successfully: $weddingDate');
        } catch (e) {
          debugPrint('⚠️ Failed to set wedding date: $e');
          // Don't fail the whole booking if setting wedding date fails
        }
      }

      // Update user profile with any edited customer details
      if (mounted) {
        final nameChanged = _nameController.text.trim() != user.name;
        final phoneChanged = _phoneController.text.trim() != (user.phone ?? '');
        final cityChanged = _addressController.text.trim() != (user.city ?? '');

        if (nameChanged || phoneChanged || cityChanged) {
          context.read<AuthBloc>().add(AuthUpdateProfile(
            name: nameChanged ? _nameController.text.trim() : null,
            phone: phoneChanged ? _phoneController.text.trim() : null,
            city: cityChanged ? _addressController.text.trim() : null,
          ));
        }
      }

      // Close loading dialog and show success dialog
      if (mounted) {
        Navigator.of(context).pop();
        _showSuccessDialog();
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();

        // Show user-friendly error dialog based on error type
        _showBookingErrorDialog(e);
      }
    }
  }

  /// Shows success dialog after successful booking
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Directionality(
        textDirection: ui.TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              // Success Icon
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFD4AF37),
                ),
                child: const Icon(
                  Icons.check,
                  size: 60,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              // Success Message
              const Text(
                'تم الحجز بنجاح',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'تمت إضافة الحجز إلى قائمة حجوزاتك',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // Buttons
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    // Navigate to home
                    Navigator.of(context).popUntil((route) => route.isFirst);

                    // Refresh HomeBloc to fetch updated countdown (if venue was booked)
                    final authState = context.read<AuthBloc>().state;
                    String? userId;
                    if (authState is AuthAuthenticated) {
                      userId = authState.user.id;
                    }
                    context.read<HomeBloc>().add(HomeServicesRequested(userId: userId));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'العودة للرئيسية',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    // Navigate to bookings tab
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const UserNavigationWrapper(
                          initialIndex: 2, // Bookings tab
                        ),
                      ),
                      (route) => false,
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(
                      color: Color(0xFFD4AF37),
                      width: 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'عرض حجوزاتي',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFD4AF37),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Shows a user-friendly error dialog based on the type of error
  void _showBookingErrorDialog(dynamic error) {
    String title;
    String message;
    IconData icon;
    Color iconColor;
    List<Widget> actions;

    // Import the API exception to check type
    if (error is ApiException) {
      final statusCode = error.statusCode;

      switch (statusCode) {
        case 409:
          // Conflict - date/time already booked
          title = 'الموعد محجوز';
          message = 'هذا الموعد محجوز بالفعل. يرجى اختيار موعد آخر.';
          icon = Icons.event_busy;
          iconColor = Colors.orange;
          actions = [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Go back to booking screen
              },
              child: const Text(
                'اختر موعداً آخر',
                style: TextStyle(color: Color(0xFFD4AF37)),
              ),
            ),
          ];
          break;
        case 400:
          // Bad request - validation error
          title = 'خطأ في البيانات';
          message = 'يرجى التحقق من البيانات المدخلة والمحاولة مرة أخرى.';
          icon = Icons.error_outline;
          iconColor = Colors.red;
          actions = [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'حسناً',
                style: TextStyle(color: Color(0xFFD4AF37)),
              ),
            ),
          ];
          break;
        case 401:
          // Unauthorized - session expired
          title = 'انتهت الجلسة';
          message = 'انتهت صلاحية جلستك. يرجى تسجيل الدخول مرة أخرى.';
          icon = Icons.lock_outline;
          iconColor = Colors.red;
          actions = [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate to login
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
              },
              child: const Text(
                'تسجيل الدخول',
                style: TextStyle(color: Color(0xFFD4AF37)),
              ),
            ),
          ];
          break;
        case 500:
        case 502:
        case 503:
          // Server error
          title = 'خطأ في الخادم';
          message = 'حدث خطأ في الخادم. يرجى المحاولة مرة أخرى لاحقاً.';
          icon = Icons.cloud_off;
          iconColor = Colors.grey;
          actions = [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'حسناً',
                style: TextStyle(color: Color(0xFFD4AF37)),
              ),
            ),
          ];
          break;
        default:
          // Other API errors - show the message from API if available
          title = 'خطأ في الحجز';
          // Extract just the Arabic message if available
          message = _extractArabicMessage(error.message) ??
              'حدث خطأ أثناء إنشاء الحجز. يرجى المحاولة مرة أخرى.';
          icon = Icons.warning_amber;
          iconColor = Colors.orange;
          actions = [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'حسناً',
                style: TextStyle(color: Color(0xFFD4AF37)),
              ),
            ),
          ];
      }
    } else if (error is NoInternetException) {
      title = 'لا يوجد اتصال';
      message = 'تحقق من اتصالك بالإنترنت وحاول مرة أخرى.';
      icon = Icons.wifi_off;
      iconColor = Colors.grey;
      actions = [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'حسناً',
            style: TextStyle(color: Color(0xFFD4AF37)),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            _handlePayment(); // Retry
          },
          child: const Text(
            'إعادة المحاولة',
            style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold),
          ),
        ),
      ];
    } else {
      // Unknown error
      title = 'خطأ غير متوقع';
      message = 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.';
      icon = Icons.error_outline;
      iconColor = Colors.red;
      actions = [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'حسناً',
            style: TextStyle(color: Color(0xFFD4AF37)),
          ),
        ),
      ];
    }

    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: ui.TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(icon, color: iconColor, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(fontSize: 15, height: 1.5),
          ),
          actions: actions,
        ),
      ),
    );
  }

  /// Extracts the Arabic portion of an error message (before any newline or English text)
  String? _extractArabicMessage(String? message) {
    if (message == null || message.isEmpty) return null;

    // If the message contains a newline, take the first part (usually Arabic)
    if (message.contains('\n')) {
      return message.split('\n').first.trim();
    }

    return message;
  }
}
