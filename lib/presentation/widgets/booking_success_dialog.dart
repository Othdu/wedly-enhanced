import 'package:flutter/material.dart';
import 'package:wedly/routes/app_router.dart';

/// Reusable booking success dialog for all booking screens
/// Shows booking confirmation with navigation options
class BookingSuccessDialog extends StatelessWidget {
  final String serviceName;
  final String date;
  final String? packageName;
  final String? selectedOption;
  final List<String>? additions;
  final double totalPrice;

  const BookingSuccessDialog({
    super.key,
    required this.serviceName,
    required this.date,
    this.packageName,
    this.selectedOption,
    this.additions,
    required this.totalPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success title
            const Text(
              'تمت الإضافة إلى السلة بنجاح!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFD4AF37),
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            // Booking details
            _buildDetailText('تم حجز موعد في $date'),

            if (packageName != null) ...[
              const SizedBox(height: 8),
              _buildDetailText('الباقة: $packageName'),
            ],

            if (selectedOption != null) ...[
              const SizedBox(height: 8),
              _buildDetailText('الخيار: $selectedOption'),
            ],

            if (additions != null && additions!.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildDetailText('الإضافات: ${additions!.join('، ')}'),
            ],

            const SizedBox(height: 8),
            _buildDetailText('السعر: ${totalPrice.toStringAsFixed(0)} جنيه'),

            const SizedBox(height: 20),

            // Helper text
            const Text(
              'يمكنك المتابعة لإتمام الحجز أو إضافة خدمات أخرى',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFFD4AF37),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            // Action buttons (horizontal)
            Row(
              children: [
                // Go to cart button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close dialog
                      Navigator.of(context).pushNamed(AppRouter.userCart);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'الذهاب للسلة',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Done button (go to home)
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close dialog
                      Navigator.of(context).pop(); // Go back to home
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'تم',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailText(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        color: Color(0xFFD4AF37),
        height: 1.5,
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.rtl,
    );
  }
}
