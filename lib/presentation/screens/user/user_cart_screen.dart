import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wedly/logic/blocs/cart/cart_bloc.dart';
import 'package:wedly/logic/blocs/cart/cart_event.dart';
import 'package:wedly/logic/blocs/cart/cart_state.dart';
import 'package:wedly/data/models/cart_item_model.dart';
import 'package:wedly/presentation/screens/user/payment_method_screen.dart';
import 'package:intl/intl.dart';

class UserCartScreen extends StatefulWidget {
  const UserCartScreen({super.key});

  @override
  State<UserCartScreen> createState() => _UserCartScreenState();
}

class _UserCartScreenState extends State<UserCartScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'السلة',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state is CartLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CartError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Directionality(
                    textDirection: ui.TextDirection.rtl,
                    child: Text(state.message, textAlign: TextAlign.center),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<CartBloc>().add(
                        const CartInitializeMockData(),
                      );
                    },
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          if (state is CartLoaded) {
            if (state.items.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Directionality(
                      textDirection: ui.TextDirection.rtl,
                      child: Text(
                        'السلة فارغة',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Directionality(
                      textDirection: ui.TextDirection.rtl,
                      child: Text(
                        'ابدأ بإضافة خدمات لسلتك',
                        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                      ),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Cart items
                      ...state.items.map((item) => _buildCartItem(item)),

                      const SizedBox(height: 16),

                      // Price breakdown
                      _buildPriceBreakdown(state),
                    ],
                  ),
                ),

                // Bottom button
                _buildBottomButton(state.totalPrice),
              ],
            );
          }

          return Center(
            child: Directionality(
              textDirection: ui.TextDirection.rtl,
              child: const Text('لا توجد بيانات'),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCartItem(CartItemModel item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Delete button on the left
          InkWell(
            onTap: () {
              context.read<CartBloc>().add(CartItemRemoved(itemId: item.id));
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.delete_outline,
                color: Colors.red,
                size: 20,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Service details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Service name
                Directionality(
                  textDirection: ui.TextDirection.rtl,
                  child: Text(
                    item.service.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFD4AF37),
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(height: 8),

                // Date
                Directionality(
                  textDirection: ui.TextDirection.rtl,
                  child: Text(
                    item.date,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(height: 4),

                // Time
                Directionality(
                  textDirection: ui.TextDirection.rtl,
                  child: Text(
                    item.time,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(height: 8),

                // Price
                Directionality(
                  textDirection: ui.TextDirection.rtl,
                  child: Text(
                    '${NumberFormat('#,###').format(item.servicePrice)} جنيه',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Service image on the right
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              item.service.imageUrl,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image, color: Colors.grey),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceBreakdown(CartLoaded state) {
    // Group items by category and calculate totals
    final Map<String, double> categoryTotals = {};
    for (var item in state.items) {
      final category = item.service.category;
      categoryTotals[category] =
          (categoryTotals[category] ?? 0.0) + item.servicePrice;
    }

    // Calculate total service charge
    final serviceChargeTotalPrice = state.items.fold<double>(
      0.0,
      (sum, item) => sum + item.serviceCharge,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            textDirection: ui.TextDirection.rtl,
            children: [
              Text(
                'البند',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              Text(
                'القيمة',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Category rows - dynamically generated
          ...categoryTotals.entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildPriceRow(
                entry.key,
                entry.value,
                const Color(0xFFD4AF37),
              ),
            ),
          ),

          // Service charge row
          _buildPriceRow(
            'الضريبة',
            serviceChargeTotalPrice,
            const Color(0xFFD4AF37),
          ),

          const SizedBox(height: 8),

          // Date row (using first item's date as example)
          if (state.items.isNotEmpty)
            _buildPriceRow(
              'الموعد',
              null,
              Colors.grey[700]!,
              customValue:
                  state.items.first.date + ' - ' + state.items.first.time,
            ),

          const SizedBox(height: 12),

          // Divider
          Divider(color: Colors.grey[300], thickness: 1),

          const SizedBox(height: 12),

          // Total row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            textDirection: ui.TextDirection.rtl,
            children: [
              Text(
                'المبلغ الإجمالي',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                '${NumberFormat('#,###').format(state.totalPrice)} جنيه',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(
    String label,
    double? value,
    Color labelColor, {
    String? customValue,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      textDirection: ui.TextDirection.rtl,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: labelColor)),
        Text(
          customValue ?? '${NumberFormat('#,###').format(value)} جنيه',
          style: TextStyle(fontSize: 14, color: Colors.grey[800]),
        ),
      ],
    );
  }

  Widget _buildBottomButton(double totalPrice) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      PaymentMethodScreen(totalAmount: totalPrice),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'متابعة',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
