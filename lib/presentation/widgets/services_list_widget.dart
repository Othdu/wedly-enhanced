import 'package:flutter/material.dart';
import 'package:wedly/data/models/service_model.dart';
import 'package:wedly/presentation/widgets/service_card.dart';

/// Responsive widget for displaying services in grid or list layout
/// Reusable across different screens with configurable settings
class ServicesListWidget extends StatelessWidget {
  final List<ServiceModel> services;
  final Function(ServiceModel)? onServiceTap;
  final String layout; // 'grid' or 'list'
  final int? limit;
  final int crossAxisCount;
  final double aspectRatio;
  final double spacing;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const ServicesListWidget({
    super.key,
    required this.services,
    this.onServiceTap,
    this.layout = 'grid',
    this.limit,
    this.crossAxisCount = 2,
    this.aspectRatio = 0.75,
    this.spacing = 16.0,
    this.shrinkWrap = false,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    if (services.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.search_off, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'لا توجد خدمات متاحة',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textDirection: TextDirection.rtl,
              ),
            ],
          ),
        ),
      );
    }

    final displayServices = limit != null && limit! < services.length
        ? services.sublist(0, limit)
        : services;

    if (layout == 'list') {
      return _buildListView(displayServices);
    }

    return _buildGridView(displayServices);
  }

  Widget _buildGridView(List<ServiceModel> services) {
    return LayoutBuilder(
      builder: (context, constraints) {
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
          itemCount: services.length,
          itemBuilder: (context, index) {
            final service = services[index];
            return ServiceCard(
              service: service,
              onTap: () => onServiceTap?.call(service),
            );
          },
        );
      },
    );
  }

  Widget _buildListView(List<ServiceModel> services) {
    return ListView.separated(
      shrinkWrap: shrinkWrap,
      physics: physics,
      itemCount: services.length,
      separatorBuilder: (context, index) => SizedBox(height: spacing),
      itemBuilder: (context, index) {
        final service = services[index];
        return ServiceCard(
          service: service,
          onTap: () => onServiceTap?.call(service),
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
