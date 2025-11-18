import 'package:flutter/material.dart';
import 'package:wedly/data/models/service_model.dart';
import 'package:wedly/presentation/widgets/skeleton_image.dart';

/// Widget that displays a service card for category listings
/// Shows service image, name, rating, price, and CTA button
/// Used for all categories except venues (قاعات الأفراح)
class CategoryServiceCard extends StatelessWidget {
  final ServiceModel service;
  final VoidCallback? onTap;

  const CategoryServiceCard({
    super.key,
    required this.service,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Service Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(16),
            ),
            child: SkeletonImage(
              imageUrl: service.imageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              errorWidget: const Icon(
                Icons.image_not_supported,
                size: 64,
                color: Colors.grey,
              ),
            ),
          ),

          // Service Info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Service Name
                Text(
                  service.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                // Rating and Price Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Price on the left
                    if (service.price != null)
                      Expanded(
                        child: Text(
                          'من ${service.price!.toInt()} جنيه',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.left,
                        ),
                      )
                    else
                      const Expanded(
                        child: Text(
                          'السعر حسب الطلب',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.left,
                        ),
                      ),

                    // Rating on the right
                    if (service.rating != null && service.rating! > 0)
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Icon(
                              Icons.star,
                              color: Color(0xFFFFB400),
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              service.rating!.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      const Expanded(
                        child: Text(
                          'جديد',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.right,
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 16),

                // CTA Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'عرض التفاصيل',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textDirection: TextDirection.rtl,
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
