import 'package:flutter/material.dart';
import 'package:wedly/data/models/service_model.dart';
import 'package:wedly/presentation/widgets/skeleton_image.dart';
import 'package:wedly/core/utils/city_translator.dart';

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

  // Format price with thousand separators
  String _formatPrice(double price) {
    final intPrice = price.toInt();
    return intPrice.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  // Build price widget based on service type
  Widget _buildPriceWidget() {
    // For venues: show minimum of morning/evening price
    if (service.morningPrice != null || service.eveningPrice != null) {
      final morningPrice = service.morningPrice ?? double.infinity;
      final eveningPrice = service.eveningPrice ?? double.infinity;
      final minPrice = morningPrice < eveningPrice ? morningPrice : eveningPrice;

      if (minPrice == double.infinity) {
        return const Text(
          'السعر غير متاح حالياً',
          style: TextStyle(
            fontSize: 14,
            color: Colors.black54,
          ),
          textDirection: TextDirection.rtl,
        );
      }

      return Text(
        'من ${_formatPrice(minPrice)} جنيه',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        textDirection: TextDirection.rtl,
      );
    }

    // For other services: show price or unavailable message
    if (service.price != null && service.price! > 0) {
      // Check for discount
      if (service.hasApprovedOffer && service.finalPrice != null) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'من ${_formatPrice(service.finalPrice!)} جنيه',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFFD4AF37),
              ),
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(width: 8),
            Text(
              '${_formatPrice(service.price!)} جنيه',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[500],
                decoration: TextDecoration.lineThrough,
              ),
              textDirection: TextDirection.rtl,
            ),
          ],
        );
      }

      return Text(
        'من ${_formatPrice(service.price!)} جنيه',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        textDirection: TextDirection.rtl,
      );
    }

    // No price available
    return const Text(
      'السعر غير متاح حالياً',
      style: TextStyle(
        fontSize: 14,
        color: Colors.black54,
      ),
      textDirection: TextDirection.rtl,
    );
  }

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
          // Service Image with Discount Badge and Rating
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
              // Rating Badge (top-left for RTL)
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (service.rating != null && service.rating! > 0) ...[
                        Text(
                          '(${service.reviewCount ?? 0})',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
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
                        const SizedBox(width: 2),
                        const Icon(
                          Icons.star_rounded,
                          color: Color(0xFFFFB400),
                          size: 18,
                        ),
                      ] else ...[
                        Text(
                          'جديد',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
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

                const SizedBox(height: 8),

                // Venue-specific details (if chairCount exists)
                if (service.chairCount != null) ...[
                  // Chair count for venues
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'السعة: ${service.chairCount} كرسي',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.event_seat,
                        size: 18,
                        color: Colors.grey[600],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // City for venues
                  if (service.city != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Text(
                            CityTranslator.translate(service.city!),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                            textDirection: TextDirection.rtl,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.location_on,
                          size: 18,
                          color: Colors.grey[600],
                        ),
                      ],
                    ),
                  const SizedBox(height: 8),
                ],

                // Price Row
                _buildPriceWidget(),

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
