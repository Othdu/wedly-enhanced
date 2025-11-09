import 'package:equatable/equatable.dart';

class ServiceModel extends Equatable {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final double? price;
  final String category;
  final bool isActive;

  const ServiceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    this.price,
    required this.category,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        imageUrl,
        price,
        category,
        isActive,
      ];

  ServiceModel copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    double? price,
    String? category,
    bool? isActive,
  }) {
    return ServiceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      category: category ?? this.category,
      isActive: isActive ?? this.isActive,
    );
  }

  // JSON serialization
  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'].toString(),
      name: json['name'] as String,
      description: json['description'] as String,
      imageUrl: json['image_url'] as String? ?? json['imageUrl'] as String? ?? '',
      price: json['price'] != null ? (json['price'] as num).toDouble() : null,
      category: json['category'] as String,
      isActive: json['is_active'] as bool? ?? json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'price': price,
      'category': category,
      'is_active': isActive,
    };
  }
}

