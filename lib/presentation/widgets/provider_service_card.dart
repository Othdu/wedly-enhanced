import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/service_model.dart';
import 'skeleton_image.dart';

class ProviderServiceCard extends StatelessWidget {
  final ServiceModel service;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleStatus;
  final bool showActions;

  const ProviderServiceCard({
    super.key,
    required this.service,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onToggleStatus,
    this.showActions = true,
  });

  String _formatNumber(double number) {
    // Format without decimal places for cleaner display
    return number
        .toInt()
        .toString()
        .replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  /// Check if this service is a venue (has morning/evening prices)
  bool get _isVenue => service.morningPrice != null || service.eveningPrice != null;

  /// Get the display price text based on service type
  String get _priceDisplayText {
    if (_isVenue) {
      // For venues, show the minimum of morning/evening price
      final morningPrice = service.morningPrice ?? double.infinity;
      final eveningPrice = service.eveningPrice ?? double.infinity;
      final minPrice = morningPrice < eveningPrice ? morningPrice : eveningPrice;
      if (minPrice == double.infinity) {
        return 'السعر غير محدد';
      }
      return 'من ${_formatNumber(minPrice)} جنيه';
    } else {
      // For non-venues, show the regular price
      final price = service.price;
      if (price == null || price <= 0) {
        return 'السعر غير محدد';
      }
      return 'من ${_formatNumber(price)} جنيه';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen width for responsive sizing
    final screenWidth = MediaQuery.of(context).size.width;
    final scaleFactor = (screenWidth / 375).clamp(0.9, 1.4);

    // Responsive font sizes with minimum values to prevent tiny text
    final nameFontSize = (15 * scaleFactor).clamp(14.0, 18.0);
    final priceFontSize = (14 * scaleFactor).clamp(13.0, 17.0);
    final ratingFontSize = (14 * scaleFactor).clamp(13.0, 17.0);
    final reviewFontSize = (12 * scaleFactor).clamp(11.0, 15.0);
    final badgeFontSize = (12 * scaleFactor).clamp(11.0, 14.0);
    final buttonFontSize = (15 * scaleFactor).clamp(14.0, 18.0);
    final badgeIconSize = (14 * scaleFactor).clamp(12.0, 16.0);
    final starIconSize = (18 * scaleFactor).clamp(16.0, 22.0);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Service Image with Status Badges
          Expanded(
            child: Stack(
              children: [
                SkeletonImage(
                  imageUrl: service.imageUrl,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  errorWidget: const Icon(
                    Icons.event,
                    color: AppColors.gold,
                    size: 40,
                  ),
                ),
                // Inactive overlay when service is deactivated
                if (!service.isActive)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.visibility_off,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                // Pending Approval Badge
                if (service.isPendingApproval)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.schedule, color: Colors.white, size: badgeIconSize),
                          const SizedBox(width: 4),
                          Text(
                            'تحت المراجعة',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: badgeFontSize,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                // Active/Inactive Status Badge (top left)
                Positioned(
                  top: 8,
                  left: 8,
                  child: GestureDetector(
                    onTap: onToggleStatus,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: service.isActive ? Colors.green : Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            service.isActive ? Icons.visibility : Icons.visibility_off,
                            color: Colors.white,
                            size: badgeIconSize,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            service.isActive ? 'مفعّل' : 'معطّل',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: badgeFontSize,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Service Info Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Service Name
                Text(
                  service.name,
                  style: TextStyle(
                    fontSize: nameFontSize,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),

                // Rating and Price Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Price
                    Flexible(
                      child: Text(
                        _priceDisplayText,
                        style: TextStyle(
                          fontSize: priceFontSize,
                          fontWeight: FontWeight.w500,
                          color: Colors.black54,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Rating
                    if (service.rating != null && service.rating! > 0)
                      Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              service.rating!.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: ratingFontSize,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.star,
                              color: AppColors.gold,
                              size: starIconSize,
                            ),
                            if (service.reviewCount != null)
                              Flexible(
                                child: Text(
                                  ' (${service.reviewCount})',
                                  style: TextStyle(
                                    fontSize: reviewFontSize,
                                    color: Colors.black54,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                        ),
                      )
                    else
                      Flexible(
                        child: Text(
                          'لا توجد تقييمات',
                          style: TextStyle(fontSize: priceFontSize, color: Colors.black38),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 6),

                // Edit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onEdit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Text(
                      'تعديل',
                      style: TextStyle(
                        fontSize: buttonFontSize,
                        fontWeight: FontWeight.w600,
                      ),
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
