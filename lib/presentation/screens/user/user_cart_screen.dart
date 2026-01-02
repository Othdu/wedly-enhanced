import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wedly/logic/blocs/cart/cart_bloc.dart';
import 'package:wedly/logic/blocs/cart/cart_event.dart';
import 'package:wedly/logic/blocs/cart/cart_state.dart';
import 'package:wedly/data/models/cart_item_model.dart';
import 'package:wedly/presentation/screens/user/payment_method_screen.dart';
import 'package:wedly/presentation/widgets/skeleton_image.dart';
import 'package:intl/intl.dart';

class UserCartScreen extends StatefulWidget {
  const UserCartScreen({super.key});

  @override
  State<UserCartScreen> createState() => _UserCartScreenState();
}

class _UserCartScreenState extends State<UserCartScreen> {
  @override
  void initState() {
    super.initState();
    // Validate prices when cart screen opens
    _validatePrices();
  }

  void _validatePrices() {
    // Trigger price validation after a short delay to let cart load first
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        context.read<CartBloc>().add(const CartPricesValidated(userId: 'current_user'));
      }
    });
  }

  void _showDeleteConfirmationDialog(BuildContext context, CartItemModel item) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Directionality(
          textDirection: ui.TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'تأكيد الحذف',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              textAlign: TextAlign.right,
            ),
            content: Text(
              'هل أنت متأكد من حذف "${item.service.name}" من السلة؟',
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.right,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
                child: Text(
                  'إلغاء',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 16,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  context.read<CartBloc>().add(CartItemRemoved(itemId: item.id));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'حذف',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

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

            // Calculate total for consistency
            double calculatedTotal = 0;
            for (var item in state.items) {
              calculatedTotal += item.servicePrice;
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

                // Bottom button - use calculated total for consistency
                _buildBottomButton(calculatedTotal),
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
    // Safely check priceChanged with null fallback
    final hasPriceChanged = item.priceChanged == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: hasPriceChanged
            ? Border.all(color: const Color(0xFFFFB300), width: 2)
            : null,
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
              _showDeleteConfirmationDialog(context, item);
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
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Service name
                Text(
                  item.service.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD4AF37),
                  ),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 8),

                // Date
                Text(
                  item.date,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 4),

                // Time
                Text(
                  item.time,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 8),

                // Price
                Text(
                  '${NumberFormat('#,###').format(item.servicePrice)} جنيه',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Service image on the right
          SkeletonImage(
            imageUrl: item.service.imageUrl,
            width: 80,
            height: 80,
            fit: BoxFit.cover,
            borderRadius: BorderRadius.circular(8),
            errorWidget: const Icon(
              Icons.image,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceBreakdown(CartLoaded state) {
    // Calculate actual total from items
    double calculatedTotal = 0;
    for (var item in state.items) {
      calculatedTotal += item.servicePrice;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Directionality(
        textDirection: ui.TextDirection.rtl,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Row(
              children: [
                const Icon(
                  Icons.receipt_long_outlined,
                  color: Color(0xFFD4AF37),
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  'ملخص الطلب',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Item rows
            ...state.items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isLast = index == state.items.length - 1;

              return Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Item number badge
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4AF37).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFD4AF37),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Item details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.service.name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF333333),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${item.date} • ${item.time}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Price
                      Text(
                        '${NumberFormat('#,###').format(item.servicePrice)} جنيه',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ],
                  ),
                  if (!isLast) ...[
                    const SizedBox(height: 12),
                    Divider(color: Colors.grey[200], thickness: 1),
                    const SizedBox(height: 12),
                  ],
                ],
              );
            }),

            const SizedBox(height: 16),

            // Total section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFD4AF37).withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.shopping_bag_outlined,
                        color: Color(0xFFD4AF37),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'الإجمالي',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4AF37).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _getItemCountText(state.items.length),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFD4AF37),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${NumberFormat('#,###').format(calculatedTotal)} جنيه',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFD4AF37),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

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
