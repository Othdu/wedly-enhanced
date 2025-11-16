import 'package:equatable/equatable.dart';

/// Enum for available widget types
enum WidgetType {
  countdown,
  offers,
  categories,
  services,
  banner,
  recommendations,
  custom;

  static WidgetType fromString(String type) {
    switch (type.toLowerCase()) {
      case 'countdown':
        return WidgetType.countdown;
      case 'offers':
        return WidgetType.offers;
      case 'categories':
        return WidgetType.categories;
      case 'services':
        return WidgetType.services;
      case 'banner':
        return WidgetType.banner;
      case 'recommendations':
        return WidgetType.recommendations;
      default:
        return WidgetType.custom;
    }
  }

  String get value {
    switch (this) {
      case WidgetType.countdown:
        return 'countdown';
      case WidgetType.offers:
        return 'offers';
      case WidgetType.categories:
        return 'categories';
      case WidgetType.services:
        return 'services';
      case WidgetType.banner:
        return 'banner';
      case WidgetType.recommendations:
        return 'recommendations';
      case WidgetType.custom:
        return 'custom';
    }
  }
}

/// Model for configuring individual widgets on a screen
class WidgetConfigModel extends Equatable {
  final String id;
  final WidgetType type;
  final String title;
  final String titleAr;
  final bool isVisible;
  final int order;
  final Map<String, dynamic>? settings;

  const WidgetConfigModel({
    required this.id,
    required this.type,
    this.title = '',
    this.titleAr = '',
    this.isVisible = true,
    this.order = 0,
    this.settings,
  });

  @override
  List<Object?> get props => [id, type, title, titleAr, isVisible, order, settings];

  WidgetConfigModel copyWith({
    String? id,
    WidgetType? type,
    String? title,
    String? titleAr,
    bool? isVisible,
    int? order,
    Map<String, dynamic>? settings,
  }) {
    return WidgetConfigModel(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      titleAr: titleAr ?? this.titleAr,
      isVisible: isVisible ?? this.isVisible,
      order: order ?? this.order,
      settings: settings ?? this.settings,
    );
  }

  // JSON serialization
  factory WidgetConfigModel.fromJson(Map<String, dynamic> json) {
    return WidgetConfigModel(
      id: json['id']?.toString() ?? '',
      type: WidgetType.fromString(json['type'] as String? ?? 'custom'),
      title: json['title'] as String? ?? '',
      titleAr: json['title_ar'] as String? ?? json['title'] as String? ?? '',
      isVisible: json['is_visible'] as bool? ?? true,
      order: json['order'] as int? ?? 0,
      settings: json['settings'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.value,
      'title': title,
      'title_ar': titleAr,
      'is_visible': isVisible,
      'order': order,
      'settings': settings,
    };
  }
}
