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
          // Service Image with Discount Badge
          Stack(
            children: [
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
              // Discount Badge (if service has approved offer)
              if (service.hasApprovedOffer && service.discountPercentage != null)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4AF37),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Text(
                      'خصم ${service.discountPercentage!.toInt()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                ),
            ],
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

                // Rating Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Empty spacer for alignment
                    const Expanded(child: SizedBox()),

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

                const SizedBox(height: 8),

                // Price Row (shows discount if available)
                if (service.price != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      // Discounted Price (if offer exists)
                      if (service.hasApprovedOffer && service.finalPrice != null)
                        Text(
                          'من ${service.finalPrice!.toInt()} جنيه',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFD4AF37),
                          ),
                          textDirection: TextDirection.rtl,
                        )
                      else
                        Text(
                          'من ${service.price!.toInt()} جنيه',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                      // Original Price (strikethrough if offer exists)
                      if (service.hasApprovedOffer) ...[
                        const SizedBox(width: 8),
                        Text(
                          '${service.price!.toInt()} جنيه',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[500],
                            decoration: TextDecoration.lineThrough,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                      ],
                    ],
                  )
                else
                  const Text(
                    'السعر حسب الطلب',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.left,
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
