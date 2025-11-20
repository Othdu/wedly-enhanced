import 'package:equatable/equatable.dart';

class AddressModel extends Equatable {
  final String? id;
  final String city;
  final String district;
  final String buildingNumber;
  final bool isDefault;

  const AddressModel({
    this.id,
    required this.city,
    required this.district,
    required this.buildingNumber,
    this.isDefault = false,
  });

  @override
  List<Object?> get props => [id, city, district, buildingNumber, isDefault];

  AddressModel copyWith({
    String? id,
    String? city,
    String? district,
    String? buildingNumber,
    bool? isDefault,
  }) {
    return AddressModel(
      id: id ?? this.id,
      city: city ?? this.city,
      district: district ?? this.district,
      buildingNumber: buildingNumber ?? this.buildingNumber,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  // JSON serialization
  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'] as String?,
      city: json['city'] as String,
      district: json['district'] as String,
      buildingNumber: json['building_number'] as String,
      isDefault: json['is_default'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'city': city,
      'district': district,
      'building_number': buildingNumber,
      'is_default': isDefault,
    };
  }

  // Format address as a single string
  String get fullAddress => '$city - $district - $buildingNumber';
}
