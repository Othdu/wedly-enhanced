import 'package:equatable/equatable.dart';
import 'package:wedly/data/models/user_model.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final UserModel user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

class AuthRegistrationSuccess extends AuthState {
  final String email;
  final String message;

  const AuthRegistrationSuccess({
    required this.email,
    required this.message,
  });

  @override
  List<Object?> get props => [email, message];
}

class AuthOtpVerificationSuccess extends AuthState {
  final UserModel user;

  const AuthOtpVerificationSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthResendOtpSuccess extends AuthState {
  final String message;

  const AuthResendOtpSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class AuthForgotPasswordSuccess extends AuthState {
  final String email;
  final String message;

  const AuthForgotPasswordSuccess({
    required this.email,
    required this.message,
  });

  @override
  List<Object?> get props => [email, message];
}

class AuthResetPasswordSuccess extends AuthState {
  final String message;

  const AuthResetPasswordSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class AuthChangePasswordSuccess extends AuthState {
  final String message;

  const AuthChangePasswordSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class AuthProfileImageUpdateSuccess extends AuthState {
  final UserModel user;
  final String message;

  const AuthProfileImageUpdateSuccess({
    required this.user,
    required this.message,
  });

  @override
  List<Object?> get props => [user, message];
}

class AuthProfileUpdateSuccess extends AuthState {
  final UserModel user;
  final String message;

  const AuthProfileUpdateSuccess({
    required this.user,
    required this.message,
  });

  @override
  List<Object?> get props => [user, message];
}

class AuthSetWeddingDateSuccess extends AuthState {
  final String message;

  const AuthSetWeddingDateSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class AuthGetWeddingDateSuccess extends AuthState {
  final DateTime? weddingDate;
  final int? daysRemaining;
  final String message;

  const AuthGetWeddingDateSuccess({
    required this.weddingDate,
    required this.daysRemaining,
    required this.message,
  });

  @override
  List<Object?> get props => [weddingDate, daysRemaining, message];
}

