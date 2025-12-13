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
    // Handle is_default field - can be bool, int (0/1), or null
    bool parseIsDefault(dynamic value) {
      if (value == null) return false;
      if (value is bool) return value;
      if (value is int) return value == 1;
      if (value is String) return value.toLowerCase() == 'true' || value == '1';
      return false;
    }

    return AddressModel(
      id: json['id']?.toString(),
      city: json['city']?.toString() ?? '',
      district: json['district']?.toString() ?? '',
      buildingNumber: json['building_number']?.toString() ?? json['buildingNumber']?.toString() ?? '',
      isDefault: parseIsDefault(json['is_default'] ?? json['isDefault']),
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
