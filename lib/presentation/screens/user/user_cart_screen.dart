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

  /// Check if cart contains duplicate bookings (same service, same date)
  Future<Map<String, List<CartItemModel>>> _findDuplicatesInCart(
    List<CartItemModel> items,
  ) async {
    final duplicateGroups = <String, List<CartItemModel>>{};

    for (int i = 0; i < items.length; i++) {
      for (int j = i + 1; j < items.length; j++) {
        final item1 = items[i];
        final item2 = items[j];

        // Check if same service and same date
        if (item1.service.id == item2.service.id && item1.date == item2.date) {
          final key = '${item1.service.id}_${item1.date}';
          final existing = duplicateGroups[key] ?? [];
          if (!existing.contains(item1)) existing.add(item1);
          if (!existing.contains(item2)) existing.add(item2);
          duplicateGroups[key] = existing;
        }
      }
    }

    return duplicateGroups;
  }

  /// Build duplicate warning banner widget
  Widget _buildDuplicateWarningBanner(Map<String, List<CartItemModel>> duplicates) {
    if (duplicates.isEmpty) return const SizedBox.shrink();

    final totalDuplicates = duplicates.values.fold<int>(
      0,
      (sum, group) => sum + (group.length > 1 ? group.length : 0),
    );

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade300, width: 2),
      ),
      child: Directionality(
        textDirection: ui.TextDirection.rtl,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'تحذير: لديك حجوزات مكررة في السلة',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'وجدنا $totalDuplicates عنصر مكرر (نفس الخدمة ونفس التاريخ). يرجى مراجعة حجوزاتك قبل المتابعة.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade800,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            ...duplicates.entries.map((entry) {
              final items = entry.value;
              if (items.isEmpty) return const SizedBox.shrink();

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.copy, size: 16, color: Colors.orange.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${items.first.service.name} - ${items.first.date} (${items.length}x)',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 8),
            Text(
              '💡 يمكنك حذف العناصر المكررة باستخدام زر الحذف أو المتابعة إذا كنت ترغب في حجزها جميعاً.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
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
      body: BlocConsumer<CartBloc, CartState>(
        listener: (context, state) {
          // Show error as a snackbar instead of replacing the entire screen
          if (state is CartError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Directionality(
                  textDirection: ui.TextDirection.rtl,
                  child: Text(
                    state.message,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                backgroundColor: Colors.red.shade700,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 4),
                action: SnackBarAction(
                  label: 'إعادة تحميل',
                  textColor: Colors.white,
                  onPressed: () {
                    context.read<CartBloc>().add(
                      const CartItemsRequested(userId: 'current_user'),
                    );
                  },
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is CartLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Show cart items for both CartLoaded and CartError states
          // This way errors don't break the UI, they just show as snackbars
          final CartLoaded? loadedState = state is CartLoaded ? state : null;

          if (loadedState != null) {
            if (loadedState.items.isEmpty) {
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
            for (var item in loadedState.items) {
              calculatedTotal += item.servicePrice;
            }

            return Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Duplicate warning banner
                      FutureBuilder<Map<String, List<CartItemModel>>>(
                        future: _findDuplicatesInCart(loadedState.items),
                        builder: (context, snapshot) {
                          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                            return _buildDuplicateWarningBanner(snapshot.data!);
                          }
                          return const SizedBox.shrink();
                        },
                      ),

                      // Cart items
                      ...loadedState.items.map((item) => _buildCartItem(item)),

                      const SizedBox(height: 16),

                      // Price breakdown
                      _buildPriceBreakdown(loadedState),
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
                            style: TextStyle(
                              fontSize: (12 * (MediaQuery.of(context).size.width / 375)).clamp(11.0, 15.0),
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFD4AF37),
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
                                fontSize: (12 * (MediaQuery.of(context).size.width / 375)).clamp(11.0, 15.0),
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Price
                      Flexible(
                        flex: 0,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '${NumberFormat('#,###').format(item.servicePrice)} جنيه',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF333333),
                            ),
                          ),
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
                          style: TextStyle(
                            fontSize: (11 * (MediaQuery.of(context).size.width / 375)).clamp(11.0, 14.0),
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFD4AF37),
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
