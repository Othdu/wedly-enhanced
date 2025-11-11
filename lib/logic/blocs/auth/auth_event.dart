import 'package:equatable/equatable.dart';
import 'package:wedly/core/utils/enums.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;
  final UserRole? role;

  const AuthLoginRequested({
    required this.email,
    required this.password,
    this.role,
  });

  @override
  List<Object?> get props => [email, password, role];
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

class AuthStatusChecked extends AuthEvent {
  const AuthStatusChecked();
}

class AuthRoleChanged extends AuthEvent {
  final UserRole role;

  const AuthRoleChanged(this.role);

  @override
  List<Object?> get props => [role];
}

class AuthUpdateProfile extends AuthEvent {
  final String? name;
  final String? email;
  final String? profileImageUrl;

  const AuthUpdateProfile({
    this.name,
    this.email,
    this.profileImageUrl,
  });

  @override
  List<Object?> get props => [name, email, profileImageUrl];
}

