import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// A widget that displays network images with skeleton loading and error handling
/// Shows a shimmer effect while loading and handles network/cache errors gracefully
class SkeletonImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? errorWidget;
  final Color? shimmerBaseColor;
  final Color? shimmerHighlightColor;

  const SkeletonImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.errorWidget,
    this.shimmerBaseColor,
    this.shimmerHighlightColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Default shimmer colors based on theme
    final baseColor = shimmerBaseColor ??
        (isDark ? Colors.grey[800]! : Colors.grey[300]!);
    final highlightColor = shimmerHighlightColor ??
        (isDark ? Colors.grey[700]! : Colors.grey[100]!);

    Widget imageWidget = Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child; // Image loaded successfully
        }

        // Show shimmer skeleton while loading
        return Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlightColor,
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: baseColor,
              borderRadius: borderRadius,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        // Show error widget or default placeholder on error
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: borderRadius,
          ),
          child: Center(
            child: errorWidget ??
                Icon(
                  Icons.image_not_supported_outlined,
                  size: 48,
                  color: Colors.grey[400],
                ),
          ),
        );
      },
    );

    // Apply border radius if specified
    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }
}

/// A circular skeleton image widget for avatars and profile pictures
class SkeletonCircleImage extends StatelessWidget {
  final String imageUrl;
  final double size;
  final Widget? errorWidget;
  final Color? shimmerBaseColor;
  final Color? shimmerHighlightColor;

  const SkeletonCircleImage({
    super.key,
    required this.imageUrl,
    required this.size,
    this.errorWidget,
    this.shimmerBaseColor,
    this.shimmerHighlightColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final baseColor = shimmerBaseColor ??
        (isDark ? Colors.grey[800]! : Colors.grey[300]!);
    final highlightColor = shimmerHighlightColor ??
        (isDark ? Colors.grey[700]! : Colors.grey[100]!);

    return ClipOval(
      child: Image.network(
        imageUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }

          return Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: baseColor,
                shape: BoxShape.circle,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: baseColor,
                shape: BoxShape.circle,
              ),
              child: errorWidget,
            ),
          );
        },
      ),
    );
  }
}
