import 'package:equatable/equatable.dart';
import 'package:wedly/core/utils/enums.dart';

class UserModel extends Equatable {
  final String id;
  final String email;
  final String name;
  final UserRole role;
  final Gender? gender;
  final String? profileImageUrl;
  final String? phone; // Phone number field
  final String? city; // City field
  final DateTime? weddingDate; // Wedding date field
  final String? eventName; // Custom event name field

  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.gender,
    this.profileImageUrl,
    this.phone,
    this.city,
    this.weddingDate,
    this.eventName,
  });

  @override
  List<Object?> get props => [id, email, name, role, gender, profileImageUrl, phone, city, weddingDate, eventName];

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    UserRole? role,
    Gender? gender,
    String? profileImageUrl,
    String? phone,
    String? city,
    DateTime? weddingDate,
    String? eventName,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      gender: gender ?? this.gender,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      weddingDate: weddingDate ?? this.weddingDate,
      eventName: eventName ?? this.eventName,
    );
  }

  // JSON serialization
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      role: _userRoleFromString(json['role'] as String),
      gender: json['gender'] != null
          ? Gender.fromString(json['gender'] as String)
          : null,
      profileImageUrl: json['profile_image_url'] as String?,
      phone: json['phone'] as String?,
      city: json['city'] as String?,
      weddingDate: json['wedding_date'] != null
          ? DateTime.parse(json['wedding_date'] as String)
          : null,
      eventName: json['event_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role.name,
      'gender': gender?.value,
      'profile_image_url': profileImageUrl,
      'phone': phone,
      'city': city,
      'wedding_date': weddingDate?.toIso8601String(),
      'event_name': eventName,
    };
  }

  static UserRole _userRoleFromString(String role) {
    switch (role.toLowerCase()) {
      case 'provider':
        return UserRole.provider;
      case 'user':
      default:
        return UserRole.user;
    }
  }
}

