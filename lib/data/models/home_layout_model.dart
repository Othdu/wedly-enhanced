import 'package:equatable/equatable.dart';
import 'package:wedly/data/models/widget_config_model.dart';

/// Model representing the layout configuration for a screen
class HomeLayoutModel extends Equatable {
  final String id;
  final String screenName;
  final List<WidgetConfigModel> widgets;
  final Map<String, dynamic>? globalSettings;

  const HomeLayoutModel({
    required this.id,
    required this.screenName,
    required this.widgets,
    this.globalSettings,
  });

  /// Get only visible widgets sorted by order
  List<WidgetConfigModel> get visibleWidgets {
    return widgets
        .where((widget) => widget.isVisible)
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  /// Get widgets by type
  List<WidgetConfigModel> getWidgetsByType(WidgetType type) {
    return widgets.where((widget) => widget.type == type && widget.isVisible).toList();
  }

  /// Check if a widget type is enabled
  bool hasWidgetType(WidgetType type) {
    return widgets.any((widget) => widget.type == type && widget.isVisible);
  }

  @override
  List<Object?> get props => [id, screenName, widgets, globalSettings];

  HomeLayoutModel copyWith({
    String? id,
    String? screenName,
    List<WidgetConfigModel>? widgets,
    Map<String, dynamic>? globalSettings,
  }) {
    return HomeLayoutModel(
      id: id ?? this.id,
      screenName: screenName ?? this.screenName,
      widgets: widgets ?? this.widgets,
      globalSettings: globalSettings ?? this.globalSettings,
    );
  }

  // JSON serialization
  factory HomeLayoutModel.fromJson(Map<String, dynamic> json) {
    return HomeLayoutModel(
      id: json['id']?.toString() ?? '',
      screenName: json['screen_name'] as String? ?? 'home',
      widgets: (json['widgets'] as List<dynamic>?)
              ?.map((w) => WidgetConfigModel.fromJson(w as Map<String, dynamic>))
              .toList() ??
          [],
      globalSettings: json['global_settings'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'screen_name': screenName,
      'widgets': widgets.map((w) => w.toJson()).toList(),
      'global_settings': globalSettings,
    };
  }
}
