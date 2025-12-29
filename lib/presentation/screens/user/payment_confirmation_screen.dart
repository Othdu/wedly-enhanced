// FULL UPDATED FILE WITH CLEAN APPOINTMENT FORMAT

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wedly/data/models/cart_item_model.dart';
import 'package:wedly/logic/blocs/auth/auth_bloc.dart';
import 'package:wedly/logic/blocs/auth/auth_state.dart';
import 'package:wedly/presentation/screens/user/payment_success_screen.dart';
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

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      _phoneController.text = authState.user.phone ?? '+20 100 123 4567';
    } else {
      _phoneController.text = '+20 100 123 4567';
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
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
        _buildDetailRow(
          label: 'الاسم',
          value: user?.name ?? 'محمد حسام إبراهيم',
        ),
        _buildDetailRow(
          label: 'البريد الإلكتروني',
          value: user?.email ?? 'M.Hossam22@Gmail.Com',
        ),
        _buildDetailRow(
          label: 'رقم الهاتف',
          value: user?.phone ?? '+20 100 123 4567',
        ),
        _buildDetailRow(
          label: 'العنوان',
          value: user?.city ?? 'القاهرة - التجمع الخامس',
        ),
      ],
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

  Future<void> _handlePayment() async {
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

    // Replace this mock implementation with real API call
    //
    // API Endpoint: POST /api/v1/payments/process
    //
    // Request Body:
    // {
    //   "payment_method": widget.paymentMethod,  // "wallet", "visa", or "cash"
    //   "phone_number": _phoneController.text,   // Required for wallet payments
    //   "cart_items": widget.cartItems.map((item) => {
    //     "service_id": item.service.id,
    //     "date": item.date,
    //     "time": item.time,
    //     "service_price": item.servicePrice,
    //     "photographer_price": item.photographerPrice,
    //     "service_charge": item.serviceCharge,
    //   }).toList(),
    //   "total_amount": widget.totalAmount,
    //   "user_id": context.read<AuthBloc>().state is AuthAuthenticated
    //       ? (context.read<AuthBloc>().state as AuthAuthenticated).user.id
    //       : null,
    // }
    //
    // Response:
    // {
    //   "success": true,
    //   "message": "Payment processed successfully",
    //   "transaction_id": "TXN123456789",
    //   "booking_ids": ["BK001", "BK002", ...],
    //   "redirect_url": "https://payment-gateway.com/..." // For visa payments
    // }
    //
    // Error Handling:
    // - Insufficient funds -> Show error dialog
    // - Invalid payment method -> Show error dialog
    // - Payment gateway timeout -> Show error dialog
    // - Booking conflicts -> Show error dialog
    //
    // Steps:
    // 1. Validate payment method and required fields
    // 2. Call payment API with cart items and payment details
    // 3. Handle payment gateway redirect for visa/card payments
    // 4. Wait for payment confirmation
    // 5. Create bookings after successful payment
    // 6. Clear cart after successful booking creation
    // 7. Navigate to success screen with transaction details
    //
    // For now, using mock implementation:

    // Simulate API call delay (replace with real API call)
    await Future.delayed(const Duration(seconds: 2));

    // Generate mock transaction ID
    final mockTransactionId =
        'VC${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    final mockBookingIds = widget.cartItems
        .map((item) => 'BK${item.id}')
        .toList();

    // Close loading dialog
    if (mounted) {
      Navigator.of(context).pop();

      // Navigate to success screen (replace all previous routes)
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => PaymentSuccessScreen(
            transactionId: mockTransactionId,
            bookingIds: mockBookingIds,
          ),
        ),
        (route) => route.isFirst, // Keep only the first route (home)
      );
    }
  }
}
