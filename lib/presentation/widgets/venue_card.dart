import 'package:flutter/material.dart';
import 'package:wedly/data/models/venue_model.dart';
import 'package:wedly/presentation/widgets/skeleton_image.dart';

/// Widget that displays a venue card matching the screenshot design
/// Shows venue image, name, rating, capacity, price, and CTA button
class VenueCard extends StatelessWidget {
  final VenueModel venue;
  final VoidCallback? onTap;

  const VenueCard({
    super.key,
    required this.venue,
    this.onTap,
  });

  // Helper method to build price text showing lowest of morning/evening
  Widget _buildPriceText(double fontSize) {
    // Calculate the lowest price between morning and evening
    final morningPrice = venue.morningPrice ?? double.infinity;
    final eveningPrice = venue.eveningPrice ?? double.infinity;
    final minPrice = morningPrice < eveningPrice ? morningPrice : eveningPrice;

    // If both prices are unavailable, use pricePerPerson as fallback
    if (minPrice == double.infinity) {
      return Text(
        'من ${venue.pricePerPerson.toInt()} جنيه',
        style: TextStyle(
          fontSize: fontSize,
          color: Colors.black87,
        ),
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.left,
      );
    }

    // Show the minimum price
    return Text(
      'من ${minPrice.toInt()} جنيه',
      style: TextStyle(
        fontSize: fontSize,
        color: Colors.black87,
      ),
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.left,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get screen width for responsive sizing
    final screenWidth = MediaQuery.of(context).size.width;
    final scaleFactor = (screenWidth / 375).clamp(0.9, 1.4);

    // Responsive font sizes with minimum values
    final nameFontSize = (18 * scaleFactor).clamp(16.0, 22.0);
    final detailFontSize = (16 * scaleFactor).clamp(14.0, 20.0);
    final buttonFontSize = (17 * scaleFactor).clamp(16.0, 20.0);
    final iconSize = (22 * scaleFactor).clamp(20.0, 26.0);

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
          // Venue Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(16),
            ),
            child: SkeletonImage(
              imageUrl: venue.imageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              errorWidget: const Icon(
                Icons.villa,
                size: 64,
                color: Colors.grey,
              ),
            ),
          ),

          // Venue Info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Venue Name
                Text(
                  venue.name,
                  style: TextStyle(
                    fontSize: nameFontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                // Rating, Capacity, and Price Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Price on the left (showing lowest of morning/evening)
                    Expanded(
                      child: _buildPriceText(detailFontSize),
                    ),

                    // Capacity in the middle
                    Expanded(
                      child: Text(
                        'السعة: ${venue.capacity} فرد',
                        style: TextStyle(
                          fontSize: detailFontSize,
                          color: Colors.black87,
                        ),
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.center,
                      ),
                    ),

                    // Rating on the right
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(
                            Icons.star,
                            color: const Color(0xFFFFB400),
                            size: iconSize,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            venue.rating.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: detailFontSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
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
                    child: Text(
                      'عرض التفاصيل',
                      style: TextStyle(
                        fontSize: buttonFontSize,
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
