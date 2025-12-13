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
  final String? phone;
  final String? city;

  const AuthUpdateProfile({
    this.name,
    this.email,
    this.profileImageUrl,
    this.phone,
    this.city,
  });

  @override
  List<Object?> get props => [name, email, profileImageUrl, phone, city];
}

class AuthRegisterRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String phone;
  final UserRole role;

  const AuthRegisterRequested({
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
    required this.role,
  });

  @override
  List<Object?> get props => [name, email, password, phone, role];
}

class AuthOtpVerificationRequested extends AuthEvent {
  final String email;
  final String otp;

  const AuthOtpVerificationRequested({
    required this.email,
    required this.otp,
  });

  @override
  List<Object?> get props => [email, otp];
}

class AuthResendOtpRequested extends AuthEvent {
  final String email;

  const AuthResendOtpRequested({required this.email});

  @override
  List<Object?> get props => [email];
}

class AuthForgotPasswordRequested extends AuthEvent {
  final String email;

  const AuthForgotPasswordRequested({required this.email});

  @override
  List<Object?> get props => [email];
}

class AuthResetPasswordRequested extends AuthEvent {
  final String token;
  final String password;

  const AuthResetPasswordRequested({
    required this.token,
    required this.password,
  });

  @override
  List<Object?> get props => [token, password];
}

/// Event triggered when session expires (refresh token invalid)
class AuthSessionExpired extends AuthEvent {
  const AuthSessionExpired();
}

class AuthChangePasswordRequested extends AuthEvent {
  final String currentPassword;
  final String newPassword;

  const AuthChangePasswordRequested({
    required this.currentPassword,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [currentPassword, newPassword];
}

class AuthUpdateProfileImageRequested extends AuthEvent {
  final String imagePath;

  const AuthUpdateProfileImageRequested({required this.imagePath});

  @override
  List<Object?> get props => [imagePath];
}

class AuthSocialLoginRequested extends AuthEvent {
  final String provider; // 'google' or 'facebook'

  const AuthSocialLoginRequested({required this.provider});

  @override
  List<Object?> get props => [provider];
}

