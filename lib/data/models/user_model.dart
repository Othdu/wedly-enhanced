import 'package:equatable/equatable.dart';
import 'package:wedly/core/utils/enums.dart';

class UserModel extends Equatable {
  final String id;
  final String email;
  final String name;
  final UserRole role;
  final Gender? gender;
  final String? profileImageUrl;

  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.gender,
    this.profileImageUrl,
  });

  @override
  List<Object?> get props => [id, email, name, role, gender, profileImageUrl];

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    UserRole? role,
    Gender? gender,
    String? profileImageUrl,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      gender: gender ?? this.gender,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
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

