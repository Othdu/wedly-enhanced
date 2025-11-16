import 'package:flutter/material.dart';
import 'package:wedly/data/models/category_model.dart';
import 'package:wedly/presentation/widgets/category_card_widget.dart';

/// Responsive grid widget for displaying categories
/// Reusable across different screens with configurable layout
class CategoriesGridWidget extends StatelessWidget {
  final List<CategoryModel> categories;
  final Function(CategoryModel)? onCategoryTap;
  final int crossAxisCount;
  final double aspectRatio;
  final double spacing;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const CategoriesGridWidget({
    super.key,
    required this.categories,
    this.onCategoryTap,
    this.crossAxisCount = 2,
    this.aspectRatio = 1.2,
    this.spacing = 12.0,
    this.shrinkWrap = false,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive column count based on screen width
        final responsiveColumns = _getResponsiveColumns(constraints.maxWidth);

        return GridView.builder(
          shrinkWrap: shrinkWrap,
          physics: physics,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: responsiveColumns,
            childAspectRatio: aspectRatio,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return CategoryCardWidget(
              category: category,
              onTap: () => onCategoryTap?.call(category),
            );
          },
        );
      },
    );
  }

  /// Calculate responsive column count based on screen width
  int _getResponsiveColumns(double width) {
    if (width > 1200) return 4; // Desktop/Large tablet
    if (width > 800) return 3;  // Tablet
    if (width > 600) return crossAxisCount; // Small tablet
    return crossAxisCount; // Mobile
  }
}
