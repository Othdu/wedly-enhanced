import 'package:equatable/equatable.dart';

/// Model representing a wedding service category
class CategoryModel extends Equatable {
  final String id;
  final String name;
  final String nameAr;
  final String imageUrl;
  final int serviceCount;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.imageUrl,
    this.serviceCount = 0,
  });

  @override
  List<Object?> get props => [id, name, nameAr, imageUrl, serviceCount];

  CategoryModel copyWith({
    String? id,
    String? name,
    String? nameAr,
    String? imageUrl,
    int? serviceCount,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      nameAr: nameAr ?? this.nameAr,
      imageUrl: imageUrl ?? this.imageUrl,
      serviceCount: serviceCount ?? this.serviceCount,
    );
  }

  // JSON serialization
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      nameAr: json['name_ar'] as String? ?? json['name'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
      serviceCount: json['service_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_ar': nameAr,
      'image_url': imageUrl,
      'service_count': serviceCount,
    };
  }
}
