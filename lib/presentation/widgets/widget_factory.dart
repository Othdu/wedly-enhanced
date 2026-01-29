import 'package:flutter/material.dart';
import 'package:wedly/data/models/widget_config_model.dart';
import 'package:wedly/data/models/countdown_model.dart';
import 'package:wedly/data/models/category_model.dart';
import 'package:wedly/data/models/service_model.dart';
import 'package:wedly/data/models/offer_model.dart';
import 'package:wedly/presentation/widgets/countdown_timer_widget.dart';
import 'package:wedly/presentation/widgets/offers_carousel_widget.dart';
import 'package:wedly/presentation/widgets/categories_grid_widget.dart';
import 'package:wedly/presentation/widgets/services_list_widget.dart';

/// Factory class to build widgets dynamically from configuration
class WidgetFactory {
  /// Build a widget from configuration
  static Widget? buildWidget({
    required WidgetConfigModel config,
    CountdownModel? countdown,
    List<OfferModel>? offers,
    List<CategoryModel>? categories,
    List<ServiceModel>? services,
    Function(dynamic)? onTap,
    VoidCallback? onSeeAllOffers,
  }) {
    if (!config.isVisible) {
      return null;
    }

    switch (config.type) {
      case WidgetType.countdown:
        return _buildCountdownWidget(config, countdown);

      case WidgetType.offers:
        return _buildOffersWidget(config, offers, onTap, onSeeAllOffers);

      case WidgetType.categories:
        return _buildCategoriesWidget(config, categories, onTap);

      case WidgetType.services:
        return _buildServicesWidget(config, services, onTap);

      case WidgetType.banner:
      case WidgetType.recommendations:
      case WidgetType.custom:
        // Placeholder for future widget types
        return null;
    }
  }

  static Widget? _buildCountdownWidget(
    WidgetConfigModel config,
    CountdownModel? countdown,
  ) {
    if (countdown == null) return null;

    final settings = config.settings ?? {};

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: CountdownTimerWidget(
        countdown: countdown,
        showWeeks: settings['showWeeks'] as bool? ?? true,
        showDays: settings['showDays'] as bool? ?? true,
        showHours: settings['showHours'] as bool? ?? true,
        showMinutes: settings['showMinutes'] as bool? ?? true,
        showSeconds: settings['showSeconds'] as bool? ?? true,
      ),
    );
  }

  static Widget? _buildOffersWidget(
    WidgetConfigModel config,
    List<OfferModel>? offers,
    Function(dynamic)? onTap,
    VoidCallback? onSeeAllOffers,
  ) {
    if (offers == null || offers.isEmpty) return null;

    final settings = config.settings ?? {};

    return OffersCarouselWidget(
      offers: offers,
      onOfferTap: onTap != null ? (offer) => onTap(offer) : null,
      onSeeAllTap: onSeeAllOffers,
      autoplay: settings['autoplay'] as bool? ?? false,
      autoplayDuration: Duration(
        milliseconds: settings['autoplayDuration'] as int? ?? 3000,
      ),
      showIndicators: settings['showIndicators'] as bool? ?? true,
      height: settings['height'] as double?,
      showHeader: true,
    );
  }

  static Widget? _buildCategoriesWidget(
    WidgetConfigModel config,
    List<CategoryModel>? categories,
    Function(dynamic)? onTap,
  ) {
    final settings = config.settings ?? {};

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (config.titleAr.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'الخدمات',
                  style: TextStyle(
                    fontSize: 20,
                    color: Color(0xFFD4AF37),
                    fontWeight: FontWeight.bold,
                  ),
                  textDirection: TextDirection.rtl,
                  selectionColor: Color(0xFFD4AF37),
                ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: (categories == null || categories.isEmpty)
              ? Container(
                  padding: const EdgeInsets.all(48),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.category_outlined,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'لا توجد فئات متاحة حالياً',
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : CategoriesGridWidget(
                  categories: categories,
                  onCategoryTap: onTap != null ? (category) => onTap(category) : null,
                  crossAxisCount: settings['columns'] as int? ?? 2,
                  aspectRatio: settings['aspectRatio'] as double? ?? 1.2,
                  spacing: settings['spacing'] as double? ?? 12.0,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                ),
        ),
      ],
    );
  }

  static Widget? _buildServicesWidget(
    WidgetConfigModel config,
    List<ServiceModel>? services,
    Function(dynamic)? onTap,
  ) {
    if (services == null || services.isEmpty) return null;

    final settings = config.settings ?? {};

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (config.titleAr.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              config.titleAr,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textDirection: TextDirection.rtl,
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ServicesListWidget(
            services: services,
            onServiceTap: onTap != null ? (service) => onTap(service) : null,
            layout: settings['layout'] as String? ?? 'grid',
            limit: settings['limit'] as int?,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
          ),
        ),
      ],
    );
  }
}
