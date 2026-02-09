// FULL UPDATED FILE WITH CLEAN APPOINTMENT FORMAT

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wedly/data/models/cart_item_model.dart';
import 'package:wedly/data/repositories/booking_repository.dart';
import 'package:wedly/data/repositories/auth_repository.dart';
import 'package:wedly/data/repositories/payment_repository.dart';
import 'package:wedly/data/services/api_exceptions.dart';
import 'package:wedly/presentation/screens/user/paymob_webview_screen.dart';
import 'package:wedly/logic/blocs/auth/auth_bloc.dart';
import 'package:wedly/logic/blocs/auth/auth_event.dart';
import 'package:wedly/logic/blocs/auth/auth_state.dart';
import 'package:wedly/logic/blocs/cart/cart_bloc.dart';
import 'package:wedly/logic/blocs/cart/cart_event.dart';
import 'package:wedly/logic/blocs/home/home_bloc.dart';
import 'package:wedly/logic/blocs/home/home_event.dart';
import 'package:wedly/presentation/screens/user/user_navigation_wrapper.dart';
import 'package:wedly/core/di/injection_container.dart';
import 'package:wedly/core/utils/enums.dart';
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
  final TextEditingController _specialRequestsController =
      TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  // Billing fields for Paymob
  final TextEditingController _billingStreetController = TextEditingController();
  final TextEditingController _billingBuildingController = TextEditingController();
  final TextEditingController _billingFloorController = TextEditingController();
  final TextEditingController _billingApartmentController = TextEditingController();
  final TextEditingController _billingPostalCodeController = TextEditingController();
  final TextEditingController _billingCountryController = TextEditingController(text: 'EG');

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
    _billingStreetController.dispose();
    _billingBuildingController.dispose();
    _billingFloorController.dispose();
    _billingApartmentController.dispose();
    _billingPostalCodeController.dispose();
    _billingCountryController.dispose();
    super.dispose();
  }

  // Clean appointment formatter added here
  String _formatAppointment() {
    if (widget.cartItems.isEmpty) return '';
    final item = widget.cartItems.first;
    final date = _formatDate(item.date);
    return '$date - ${item.time}';
  }

  // Helper to get Arabic item count text
  String _getItemCountText(int count) {
    if (count == 1) {
      return 'عنصر واحد';
    } else if (count == 2) {
      return 'عنصران';
    } else if (count >= 3 && count <= 10) {
      return '$count عناصر';
    } else {
      return '$count عنصر';
    }
  }

  // Calculate subtotal (sum of all items before any discounts)
  double _calculateSubtotal() {
    double subtotal = 0;
    for (var item in widget.cartItems) {
      subtotal += item.servicePrice + item.photographerPrice;
    }
    return subtotal;
  }

  // Check if any item has a discount (excluding venues)
  bool _hasAnyDiscount() {
    for (var item in widget.cartItems) {
      // Check if this is a venue
      final isVenue =
          item.service.category == '2' ||
          item.service.category.toLowerCase() == 'venue' ||
          item.service.category.toLowerCase() == 'venues' ||
          item.service.category == 'قاعات الأفراح' ||
          item.service.category == 'قاعة أفراح';

      // Only consider non-venue items for discount
      if (!isVenue &&
          item.service.hasApprovedOffer &&
          item.service.discountPercentage != null &&
          item.service.discountPercentage! > 0) {
        return true;
      }
    }
    return false;
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
            'الدفع',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Column(
          children: [
            // Progress indicator
            _buildProgressIndicator(),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Order Summary Header
                    _buildOrderSummaryHeader(),
                    const SizedBox(height: 16),

                    // Deposit info banner for Visa payments
                    if (widget.paymentMethod == 'visa')
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFFD4AF37).withValues(alpha: 0.15),
                              const Color(0xFFD4AF37).withValues(alpha: 0.05),
                            ],
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD4AF37),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.payment,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'دفع مرن وآمن',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFD4AF37),
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'ادفع 60% الآن والباقي نقداً عند التنفيذ',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black87,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                    Container(
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

                          // Billing Information section (only for Visa payment)
                          if (widget.paymentMethod == 'visa') ...{
                            _buildSectionTitle('معلومات الفوترة', isBold: true),
                            const SizedBox(height: 16),
                            _buildBillingDetails(),
                            const SizedBox(height: 24),
                          },

                          // Notes and Special Requests section
                          _buildSectionTitle(
                            'ملاحظات وطلبات خاصة',
                            isBold: true,
                          ),
                          const SizedBox(height: 16),
                          _buildNotesSection(),
                          const SizedBox(height: 24),

                          // Order details section with edit button
                          _buildOrderDetailsHeader(),
                          const SizedBox(height: 12),
                          _buildItemizedCosts(),
                          const SizedBox(height: 12),
                          Divider(color: Colors.grey[300], thickness: 1),
                          const SizedBox(height: 12),

                          // Subtotal row (if there are discounts)
                          if (_hasAnyDiscount()) ...[
                            _buildSubtotalRow(),
                            const SizedBox(height: 8),
                          ],

                          _buildTotalAmount(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            _buildPayButton(),
          ],
        ),
      ),
    );
  }

  // Progress indicator widget (● ● ○)
  Widget _buildProgressIndicator() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Calculate line width based on available space
          // Total width = 3 dots (24px each) + 2 lines + spacing
          final availableWidth =
              constraints.maxWidth - (3 * 24) - 32; // 32 for padding
          final lineWidth = (availableWidth / 2).clamp(20.0, 50.0);

          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildProgressDot(isActive: true, label: 'السلة'),
              _buildProgressLine(isActive: true, width: lineWidth),
              _buildProgressDot(isActive: true, label: 'الدفع'),
              _buildProgressLine(isActive: true, width: lineWidth),
              _buildProgressDot(
                isActive: true,
                isCurrent: true,
                label: 'التأكيد',
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProgressDot({
    required bool isActive,
    bool isCurrent = false,
    required String label,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? const Color(0xFFD4AF37) : Colors.grey[300],
            border: isCurrent
                ? Border.all(color: const Color(0xFFD4AF37), width: 3)
                : null,
          ),
          child: isActive && !isCurrent
              ? const Icon(Icons.check, color: Colors.white, size: 14)
              : null,
        ),
        const SizedBox(height: 4),
        Builder(
          builder: (context) {
            final scaleFactor = (MediaQuery.of(context).size.width / 375).clamp(0.9, 1.3);
            return Text(
              label,
              style: TextStyle(
                fontSize: (11 * scaleFactor).clamp(10.0, 14.0),
                color: isActive ? const Color(0xFFD4AF37) : Colors.grey[400],
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildProgressLine({required bool isActive, double width = 40}) {
    return Container(
      width: width,
      height: 2,
      margin: const EdgeInsets.only(bottom: 16),
      color: isActive ? const Color(0xFFD4AF37) : Colors.grey[300],
    );
  }

  // Order summary header with item count
  Widget _buildOrderSummaryHeader() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFD4AF37).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.shopping_bag_outlined,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ملخص الطلب',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  _getItemCountText(widget.cartItems.length),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFD4AF37),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${NumberFormat('#,###').format(widget.totalAmount.toInt())} جنيه',
                style: TextStyle(
                  fontSize: (14 * MediaQuery.of(context).size.width / 375).clamp(13.0, 17.0),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Order details header with edit button
  Widget _buildOrderDetailsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            'تفاصيل الطلب',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        InkWell(
          onTap: () {
            // Go back to cart screen to edit
            Navigator.pop(context); // Pop payment confirmation
            Navigator.pop(context); // Pop payment method screen
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.edit_outlined,
                  size: 14,
                  color: Color(0xFFD4AF37),
                ),
                const SizedBox(width: 4),
                const Text(
                  'تعديل',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFFD4AF37),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Subtotal row
  Widget _buildSubtotalRow() {
    final subtotal = _calculateSubtotal();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            'المجموع الفرعي',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            '\u202B${NumberFormat('#,###').format(subtotal.toInt())} جنية\u202C',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.left,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
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
        _buildEditableDetailRow(label: 'الاسم', controller: _nameController),
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

  Widget _buildBillingDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildEditableDetailRow(
          label: 'الشارع',
          controller: _billingStreetController,
        ),
        _buildEditableDetailRow(
          label: 'المبنى',
          controller: _billingBuildingController,
        ),
        _buildEditableDetailRow(
          label: 'الطابق',
          controller: _billingFloorController,
          keyboardType: TextInputType.number,
        ),
        _buildEditableDetailRow(
          label: 'الشقة',
          controller: _billingApartmentController,
        ),
        _buildEditableDetailRow(
          label: 'الرمز البريدي',
          controller: _billingPostalCodeController,
          keyboardType: TextInputType.number,
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
              textDirection: isLtr
                  ? ui.TextDirection.ltr
                  : ui.TextDirection.rtl,
              child: TextField(
                controller: controller,
                keyboardType: keyboardType,
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 14, color: Colors.black),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
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
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFFD4AF37),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          const SizedBox(width: 12),
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

  /// Format conflict date from API response (handles ISO and DD/MM/YYYY formats)
  String _formatConflictDate(String dateString) {
    try {
      DateTime date;
      if (dateString.contains('T')) {
        // ISO format
        date = DateTime.parse(dateString);
      } else if (dateString.contains('/')) {
        // DD/MM/YYYY format
        final parts = dateString.split('/');
        date = DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      } else {
        return dateString; // Return as-is if unrecognized
      }
      return DateFormat('dd/MM/yyyy', 'ar').format(date);
    } catch (_) {
      return dateString;
    }
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
      // Check if this is a venue (venues use morningPrice/eveningPrice, not price field)
      // Also check by timeSlot which is only set for venue bookings
      final isVenue =
          cartItem.service.category == '2' ||
          cartItem.service.category.toLowerCase() == 'venue' ||
          cartItem.service.category.toLowerCase() == 'venues' ||
          cartItem.service.category == 'قاعات الأفراح' ||
          cartItem.service.category == 'قاعة أفراح' ||
          cartItem.timeSlot.isNotEmpty; // timeSlot is only set for venues

      // For venues: just show name and price, NO discount info
      // Venues use morning/evening pricing, not the offer system
      if (isVenue) {
        items.add(
          _buildSimplePriceRow(
            label: cartItem.service.name,
            price: cartItem.servicePrice,
            timeSlot: cartItem.time, // "صباحي" or "مسائي"
          ),
        );
      } else {
        // For other services, check for discounts
        final displayName = cartItem.service.name.isNotEmpty
            ? cartItem.service.name
            : 'خدمة';

        final hasDiscount =
            cartItem.service.hasApprovedOffer &&
            cartItem.service.discountPercentage != null &&
            cartItem.service.discountPercentage! > 0;

        final originalPrice = hasDiscount && cartItem.service.price != null
            ? cartItem.service.price!
            : null;

        items.add(
          _buildPriceRow(
            label: displayName,
            currentPrice: cartItem.servicePrice,
            originalPrice: originalPrice,
            discountPercentage: hasDiscount
                ? cartItem.service.discountPercentage
                : null,
          ),
        );

        if (cartItem.photographerPrice > 0) {
          items.add(
            _buildPriceRow(
              label: 'المصور',
              currentPrice: cartItem.photographerPrice,
            ),
          );
        }
      }
    }

    // Appointment row
    final appointment = _formatAppointment();
    if (appointment.isNotEmpty) {
      items.add(_buildDetailRow(label: 'الموعد', value: appointment));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items,
    );
  }

  // Simple price row for venues - just name, time slot, and price (like in cart)
  Widget _buildSimplePriceRow({
    required String label,
    required double price,
    required String timeSlot,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Venue name
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFFD4AF37),
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 4),
          // Time slot and price row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Price on left
              Text(
                '${NumberFormat('#,###').format(price.toInt())} جنية',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Time slot on right
              if (timeSlot.isNotEmpty)
                Text(
                  timeSlot,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // Price row with optional original price strikethrough and discount badge
  Widget _buildPriceRow({
    required String label,
    required double currentPrice,
    double? originalPrice,
    double? discountPercentage,
  }) {
    final hasDiscount =
        originalPrice != null &&
        discountPercentage != null &&
        discountPercentage > 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            flex: 2,
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFFD4AF37),
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (hasDiscount) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Builder(
                      builder: (context) {
                        final scaleFactor = (MediaQuery.of(context).size.width / 375).clamp(0.9, 1.3);
                        return Text(
                          '-${discountPercentage.toInt()}%',
                          style: TextStyle(
                            fontSize: (11 * scaleFactor).clamp(10.0, 14.0),
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              child: Directionality(
                textDirection: ui.TextDirection.ltr,
                child: hasDiscount
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Original price with strikethrough
                          Text(
                            '\u202B${NumberFormat('#,###').format(originalPrice.toInt())} جنية\u202C',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                              decoration: TextDecoration.lineThrough,
                              decorationColor: Colors.grey[500],
                            ),
                            textAlign: TextAlign.right,
                          ),
                          // Current discounted price
                          Text(
                            '\u202B${NumberFormat('#,###').format(currentPrice.toInt())} جنية\u202C',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ],
                      )
                    : Text(
                        '\u202B${NumberFormat('#,###').format(currentPrice.toInt())} جنية\u202C',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.right,
                      ),
              ),
            ),
          ),
        ],
      ),
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
    final depositAmount = widget.totalAmount * 0.6; // 60% deposit
    final remainingAmount = widget.totalAmount * 0.4; // 40% remaining
    final isVisaPayment = widget.paymentMethod == 'visa';

    return Column(
      children: [
        // Total Amount Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              flex: 1,
              child: Text(
                'المبلغ الإجمالي',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFFD4AF37),
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              flex: 2,
              child: Directionality(
                textDirection: ui.TextDirection.ltr,
                child: Text(
                  '\u202B${NumberFormat('#,###').format(widget.totalAmount.toInt())} جنية\u202C',
                  style: TextStyle(
                    fontSize: (17 * MediaQuery.of(context).size.width / 375).clamp(15.0, 20.0),
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ),
          ],
        ),

        // Show deposit breakdown for Visa payments
        if (isVisaPayment) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              children: [
                // Info icon and title
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: const Color(0xFFD4AF37),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'نظام الدفع بالعربون',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFD4AF37),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Deposit amount
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'العربون المطلوب الآن (60%)',
                      style: TextStyle(fontSize: 13, color: Colors.black87),
                    ),
                    Directionality(
                      textDirection: ui.TextDirection.ltr,
                      child: Text(
                        '\u202B${NumberFormat('#,###').format(depositAmount.toInt())} جنية\u202C',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFD4AF37),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Remaining amount
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'المتبقي نقداً عند التنفيذ (40%)',
                      style: TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                    Directionality(
                      textDirection: ui.TextDirection.ltr,
                      child: Text(
                        '\u202B${NumberFormat('#,###').format(remainingAmount.toInt())} جنية\u202C',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                Divider(color: const Color(0xFFD4AF37).withValues(alpha: 0.3)),
                const SizedBox(height: 8),

                // Explanation text
                const Text(
                  'قم بدفع العربون الآن لتأكيد حجزك، وسيتم دفع المبلغ المتبقي نقداً عند تنفيذ الخدمة',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
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
            child: Text(
              widget.paymentMethod == 'visa'
                ? 'دفع العربون (${NumberFormat('#,###').format((widget.totalAmount * 0.6).toInt())} جنية)'
                : 'تأكيد الحجز',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
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
          'يناير': 1,
          'فبراير': 2,
          'مارس': 3,
          'أبريل': 4,
          'مايو': 5,
          'يونيو': 6,
          'يوليو': 7,
          'أغسطس': 8,
          'سبتمبر': 9,
          'أكتوبر': 10,
          'نوفمبر': 11,
          'ديسمبر': 12,
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
      final bookingDay = DateTime(
        bookingDate.year,
        bookingDate.month,
        bookingDate.day,
      );

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
                ...emptyFields.map(
                  (field) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.circle,
                          size: 8,
                          color: Color(0xFFD4AF37),
                        ),
                        const SizedBox(width: 8),
                        Text(field),
                      ],
                    ),
                  ),
                ),
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

    // Validate billing details for Visa payment
    if (widget.paymentMethod == 'visa' && !_validateBillingDetails()) {
      return;
    }

    // Handle payment based on method
    if (widget.paymentMethod == 'visa') {
      await _handleVisaPayment();
    } else {
      await _handleCashPayment();
    }
  }

  /// Validates billing details for Visa/card payments
  bool _validateBillingDetails() {
    final List<String> emptyFields = [];

    if (_billingStreetController.text.trim().isEmpty) {
      emptyFields.add('الشارع');
    }
    if (_billingBuildingController.text.trim().isEmpty) {
      emptyFields.add('المبنى');
    }
    if (_billingFloorController.text.trim().isEmpty) {
      emptyFields.add('الطابق');
    }
    if (_billingApartmentController.text.trim().isEmpty) {
      emptyFields.add('الشقة');
    }
    if (_billingPostalCodeController.text.trim().isEmpty) {
      emptyFields.add('الرمز البريدي');
    }

    if (emptyFields.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) => Directionality(
          textDirection: ui.TextDirection.rtl,
          child: AlertDialog(
            title: const Text(
              'بيانات الفوترة ناقصة',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('يرجى إكمال معلومات الفوترة التالية:'),
                const SizedBox(height: 12),
                ...emptyFields.map(
                  (field) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.circle,
                          size: 8,
                          color: Color(0xFFD4AF37),
                        ),
                        const SizedBox(width: 8),
                        Text(field),
                      ],
                    ),
                  ),
                ),
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

  /// Handle Visa/card payment via Paymob
  Future<void> _handleVisaPayment() async {
    // Check for duplicate bookings first
    final duplicates = await _checkForDuplicateBookings();
    if (!mounted) return;

    if (duplicates.isNotEmpty) {
      final shouldProceed = await _showDuplicateWarningDialog(duplicates);
      if (!shouldProceed) {
        return; // User cancelled
      }
    }
    if (!mounted) return;

    // Pre-compute venue booking info BEFORE opening WebView
    // This is needed because we need to set the wedding date after successful payment
    // Venues are identified by having a timeSlot (morning/evening)
    DateTime? venueWeddingDate;
    final venueBooking = widget.cartItems.firstWhere(
      (item) => item.timeSlot.isNotEmpty, // Only venues have morning/evening timeSlots
      orElse: () => widget.cartItems.first,
    );

    final isVenueBooking = venueBooking.timeSlot.isNotEmpty;

    if (isVenueBooking) {
      venueWeddingDate = _parseBookingDate(venueBooking.date);
      debugPrint('🎯 VISA: Venue booking detected (timeSlot: ${venueBooking.timeSlot}), wedding date: $venueWeddingDate');
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
                  'جاري تجهيز صفحة الدفع...',
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
      // Get payment repository
      final paymentRepository = getIt<PaymentRepository>();

      // Split name into first and last name
      final nameParts = _nameController.text.trim().split(' ');
      final firstName = nameParts.isNotEmpty ? nameParts[0] : 'User';
      final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : 'Name';

      // Initiate payment with Paymob
      final paymentData = await paymentRepository.initiateCartPayment(
        billingFirstName: firstName,
        billingLastName: lastName,
        billingEmail: _emailController.text.trim(),
        billingPhone: _phoneController.text.trim(),
        billingCity: _addressController.text.trim(),
        billingCountry: _billingCountryController.text.trim(),
        billingStreet: _billingStreetController.text.trim(),
        billingBuilding: _billingBuildingController.text.trim(),
        billingFloor: _billingFloorController.text.trim(),
        billingApartment: _billingApartmentController.text.trim(),
        billingPostalCode: _billingPostalCodeController.text.trim(),
      );

      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }

      // Open Paymob WebView
      if (mounted) {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PaymobWebViewScreen(
              iframeUrl: paymentData['iframe_url'],
              onPaymentComplete: (success, message) async {
                Navigator.of(context).pop(); // Close WebView

                if (success) {
                  // Payment successful - backend webhook will create bookings
                  // Clear cart and show success
                  context.read<CartBloc>().add(CartCleared());

                  // Set wedding date if user booked a venue (VISA payment)
                  if (venueWeddingDate != null) {
                    debugPrint('🎯 VISA PAYMENT SUCCESS - Setting wedding date to: $venueWeddingDate');
                    try {
                      final authRepository = getIt<AuthRepository>();
                      final result = await authRepository.setWeddingDate(venueWeddingDate);
                      debugPrint('✅ VISA: Wedding date set successfully: $venueWeddingDate');
                      debugPrint('✅ VISA: Server response: $result');
                    } catch (e) {
                      debugPrint('❌ VISA: Failed to set wedding date: $e');
                      // Don't fail the whole flow if setting wedding date fails
                    }
                  }

                  _showSuccessDialog();
                } else {
                  // Payment failed
                  _showPaymentFailedDialog(message ?? 'فشل الدفع');
                }
              },
            ),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }

      // Show error dialog
      if (mounted) {
        _showBookingErrorDialog(e);
      }
    }
  }

  /// Check if user is trying to book a service they already have booked for the same date
  Future<List<Map<String, dynamic>>> _checkForDuplicateBookings() async {
    try {
      final authState = context.read<AuthBloc>().state;
      final user = authState is AuthAuthenticated ? authState.user : null;
      if (user == null) return [];

      final bookingRepository = getIt<BookingRepository>();
      final existingBookings = await bookingRepository.getUserBookings(user.id);

      final duplicates = <Map<String, dynamic>>[];

      for (var cartItem in widget.cartItems) {
        final cartDate = _parseBookingDate(cartItem.date);
        debugPrint('🔍 DupCheck: cart service.id="${cartItem.service.id}" date="${cartItem.date}" parsed=$cartDate');

        for (var booking in existingBookings) {
          // Only check pending and confirmed bookings (not cancelled or completed)
          if (booking.status == BookingStatus.cancelled ||
              booking.status == BookingStatus.completed) {
            continue;
          }

          debugPrint('🔍 DupCheck: existing booking.serviceId="${booking.serviceId}" date=${booking.bookingDate} status=${booking.status}');

          // Check if same service and same date
          if (booking.serviceId == cartItem.service.id) {
            // Compare dates (ignoring time)
            final bookingDate = DateTime(
              booking.bookingDate.year,
              booking.bookingDate.month,
              booking.bookingDate.day,
            );
            final newBookingDate = DateTime(
              cartDate.year,
              cartDate.month,
              cartDate.day,
            );

            if (bookingDate == newBookingDate) {
              duplicates.add({
                'cart_item_name': cartItem.service.name, // The item in cart
                'service_name': booking.serviceName, // The existing booking
                'booking_date': DateFormat('dd/MM/yyyy', 'ar').format(booking.bookingDate),
                'time_slot': booking.timeSlot,
                'status': booking.status.name,
                'source': 'existing_booking',
              });
            }
          }
        }
      }

      return duplicates;
    } catch (e) {
      debugPrint('Error checking for duplicate bookings: $e');
      return [];
    }
  }

  /// Show duplicate booking warning dialog
  Future<bool> _showDuplicateWarningDialog(List<Map<String, dynamic>> duplicates) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Directionality(
        textDirection: ui.TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
              const SizedBox(width: 8),
              const Text(
                'تحذير: حجز مكرر',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'لديك حجز سابق لنفس الخدمة في نفس التاريخ:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              ...duplicates.map((duplicate) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.event, size: 18, color: Colors.orange),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            duplicate['service_name'] ?? '',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '📅 ${duplicate['booking_date']} - ${duplicate['time_slot'] == 'morning' ? 'صباحاً' : 'مساءً'}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                    Text(
                      '📌 الحالة: ${_getStatusText(duplicate['status'])}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              )),
              const SizedBox(height: 12),
              const Text(
                'هل تريد المتابعة بالحجز المكرر؟',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Don't proceed
              },
              child: const Text(
                'إلغاء',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Don't proceed
                // Navigate to bookings
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const UserNavigationWrapper(initialIndex: 2),
                  ),
                  (route) => false,
                );
              },
              child: const Text(
                'عرض حجوزاتي',
                style: TextStyle(
                  color: Color(0xFFD4AF37),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Proceed anyway
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'متابعة الحجز',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
    return result ?? false;
  }

  /// Get Arabic text for booking status
  String _getStatusText(String? status) {
    switch (status) {
      case 'pending':
        return 'قيد الانتظار';
      case 'confirmed':
        return 'مؤكد';
      case 'completed':
        return 'مكتمل';
      case 'cancelled':
        return 'ملغي';
      default:
        return status ?? '';
    }
  }

  /// Handle cash on delivery payment (original flow)
  Future<void> _handleCashPayment() async {
    // Check for duplicate bookings first
    final duplicates = await _checkForDuplicateBookings();
    if (!mounted) return;

    if (duplicates.isNotEmpty) {
      final shouldProceed = await _showDuplicateWarningDialog(duplicates);
      if (!shouldProceed) {
        return; // User cancelled
      }
    }
    if (!mounted) return;

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
        debugPrint(
          '🔴 PaymentConfirmation - cartItem.timeSlot: "${cartItem.timeSlot}"',
        );
        debugPrint(
          '🔴 PaymentConfirmation - cartItem.timeSlot.isEmpty: ${cartItem.timeSlot.isEmpty}',
        );
        final timeSlot = cartItem.timeSlot.isNotEmpty
            ? cartItem.timeSlot
            : 'morning';
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
        debugPrint(
          'Customer name controller: "${_nameController.text}" -> "$customerName"',
        );
        debugPrint(
          'Customer email controller: "${_emailController.text}" -> "$customerEmail"',
        );
        debugPrint(
          'Customer phone controller: "${_phoneController.text}" -> "$customerPhone"',
        );
        debugPrint(
          'Event location controller: "${_addressController.text}" -> "$eventLocation"',
        );
        debugPrint(
          'TimeSlot from cart item: "${cartItem.timeSlot}" -> "$timeSlot"',
        );

        final Map<String, dynamic> bookingData = {
          'service_id': cartItem.service.id,
          'booking_date': bookingDateIso,
          'time_slot': timeSlot, // "morning" or "evening"
          'customer_name': customerName,
          'customer_email': customerEmail,
          'customer_phone': customerPhone,
          'event_type': cartItem.service.category.isNotEmpty
              ? cartItem.service.category
              : 'خدمة',
          'guest_count': 1, // Always 1
          'event_location': eventLocation,
          'payment_method': 'cash', // Only cash for now
          'status': 'pending', // New bookings should be pending for provider review
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
        if (cartItem.selectedSectionId != null &&
            cartItem.selectedSectionId!.isNotEmpty) {
          bookingData['selected_section_id'] = cartItem.selectedSectionId;
        }
        if (cartItem.selectedOptionIds != null &&
            cartItem.selectedOptionIds!.isNotEmpty) {
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
      // Check for venue booking - venues are identified by having a timeSlot (morning/evening)
      final venueBooking = widget.cartItems.firstWhere(
        (item) => item.timeSlot.isNotEmpty, // Only venues have morning/evening timeSlots
        orElse: () => widget.cartItems.first,
      );

      final isVenueBooking = venueBooking.timeSlot.isNotEmpty;

      debugPrint('🔍 CASH: Venue detection - isVenueBooking=$isVenueBooking, timeSlot="${venueBooking.timeSlot}"');

      if (isVenueBooking && mounted) {
        final weddingDate = _parseBookingDate(venueBooking.date);
        final authRepository = getIt<AuthRepository>();

        debugPrint('🎯 VENUE BOOKING DETECTED (timeSlot: ${venueBooking.timeSlot}) - Setting wedding date to: $weddingDate');
        try {
          final result = await authRepository.setWeddingDate(weddingDate);
          debugPrint('✅ Wedding date set successfully: $weddingDate');
          debugPrint('✅ Server response: $result');
        } catch (e, stackTrace) {
          debugPrint('❌ FAILED to set wedding date: $e');
          debugPrint('❌ Stack trace: $stackTrace');
          // Don't fail the whole booking if setting wedding date fails
        }
      }

      // Update user profile with any edited customer details
      if (mounted) {
        final nameChanged = _nameController.text.trim() != user.name;
        final phoneChanged = _phoneController.text.trim() != (user.phone ?? '');
        final cityChanged = _addressController.text.trim() != (user.city ?? '');

        if (nameChanged || phoneChanged || cityChanged) {
          context.read<AuthBloc>().add(
            AuthUpdateProfile(
              name: nameChanged ? _nameController.text.trim() : null,
              phone: phoneChanged ? _phoneController.text.trim() : null,
              city: cityChanged ? _addressController.text.trim() : null,
            ),
          );
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
                child: const Icon(Icons.check, size: 60, color: Colors.white),
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
              Text(
                widget.paymentMethod == 'visa'
                    ? 'تم دفع العربون بنجاح! تذكر دفع المبلغ المتبقي نقداً عند تنفيذ الخدمة'
                    : 'تمت إضافة الحجز إلى قائمة حجوزاتك',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              if (widget.paymentMethod == 'visa') ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Color(0xFFD4AF37),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'المبلغ المتبقي: ${NumberFormat('#,###').format((widget.totalAmount * 0.4).toInt())} جنية',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFFD4AF37),
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              // Buttons
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    // Navigate to home
                    Navigator.of(context).popUntil((route) => route.isFirst);

                    // Get auth state and HomeBloc before async gap
                    final authState = context.read<AuthBloc>().state;
                    final homeBloc = context.read<HomeBloc>();
                    String? userId;
                    if (authState is AuthAuthenticated) {
                      userId = authState.user.id;
                    }

                    // Refresh HomeBloc with 2-second delay to ensure backend processed wedding date
                    // Backend needs time to save the date before we fetch it again
                    Future.delayed(const Duration(milliseconds: 2000), () {
                      if (mounted) {
                        debugPrint('🔄 Triggering home refresh after booking...');
                        homeBloc.add(HomeServicesRequested(userId: userId));
                      }
                    });
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
                    side: const BorderSide(color: Color(0xFFD4AF37), width: 2),
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

  /// Shows payment failed dialog
  void _showPaymentFailedDialog(String message) {
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
              // Failed Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red.shade100,
                ),
                child: Icon(Icons.close, size: 60, color: Colors.red.shade700),
              ),
              const SizedBox(height: 24),
              // Failed Message
              const Text(
                'فشل الدفع',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // Buttons
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'حاول مرة أخرى',
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
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.of(context).pop(); // Go back to payment method
                  },
                  child: const Text(
                    'تغيير طريقة الدفع',
                    style: TextStyle(
                      fontSize: 16,
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
          // Extract conflicting booking details from API response
          String? conflictingServiceName;
          String? conflictingDate;

          if (error.data != null) {
            final data = error.data is Map ? error.data as Map<String, dynamic> : null;
            if (data != null) {
              final conflictingBooking = data['conflicting_booking'] ?? data['conflict'];
              if (conflictingBooking != null && conflictingBooking is Map) {
                conflictingServiceName = conflictingBooking['service_name'] ?? conflictingBooking['serviceName'];
                conflictingDate = conflictingBooking['booking_date'] ?? conflictingBooking['bookingDate'];
              }
            }
          }

          title = 'الموعد محجوز';

          // Build detailed message if we have conflicting booking info
          if (conflictingServiceName != null && conflictingDate != null) {
            final formattedDate = _formatConflictDate(conflictingDate);
            message = 'لديك حجز آخر في نفس التاريخ:\n\n'
                      '📅 الخدمة: $conflictingServiceName\n'
                      '🗓️ التاريخ: $formattedDate\n\n'
                      'يرجى اختيار موعد آخر أو إلغاء الحجز السابق.';
          } else {
            message = 'هذا الموعد محجوز بالفعل. يرجى اختيار موعد آخر.';
          }

          icon = Icons.event_busy;
          iconColor = Colors.orange;
          actions = [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                // Navigate to user bookings screen
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const UserNavigationWrapper(initialIndex: 2), // Bookings tab
                  ),
                  (route) => false,
                );
              },
              child: const Text(
                'عرض حجوزاتي',
                style: TextStyle(color: Color(0xFFD4AF37)),
              ),
            ),
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
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/login', (route) => false);
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
          message =
              _extractArabicMessage(error.message) ??
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
            style: TextStyle(
              color: Color(0xFFD4AF37),
              fontWeight: FontWeight.bold,
            ),
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
