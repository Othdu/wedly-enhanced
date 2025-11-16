import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wedly/data/repositories/auth_repository.dart';
import 'package:wedly/logic/blocs/auth/auth_event.dart';
import 'package:wedly/logic/blocs/auth/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(const AuthInitial()) {
    on<AuthStatusChecked>(_onAuthStatusChecked);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
    on<AuthRoleChanged>(_onAuthRoleChanged);
    on<AuthUpdateProfile>(_onAuthUpdateProfile);

    // Check initial auth status
    add(const AuthStatusChecked());
  }

  Future<void> _onAuthStatusChecked(
    AuthStatusChecked event,
    Emitter<AuthState> emit,
  ) async {
    final user = await authRepository.getCurrentUser();
    if (user != null) {
      emit(AuthAuthenticated(user));
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await authRepository.login(
        email: event.email,
        password: event.password,
        role: event.role,
      );
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await authRepository.logout();
      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onAuthRoleChanged(
    AuthRoleChanged event,
    Emitter<AuthState> emit,
  ) async {
    await authRepository.setUserRole(event.role);
    final user = await authRepository.getCurrentUser();
    if (user != null) {
      emit(AuthAuthenticated(user));
    }
  }

  Future<void> _onAuthUpdateProfile(
    AuthUpdateProfile event,
    Emitter<AuthState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AuthAuthenticated) return;

    // Update the user with new data
    final updatedUser = currentState.user.copyWith(
      name: event.name,
      email: event.email,
      profileImageUrl: event.profileImageUrl,
      phone: event.phone,
      city: event.city,
    );

    // TODO: Call authRepository.updateProfile(updatedUser) when API is ready
    // For now, just emit the updated state
    emit(AuthAuthenticated(updatedUser));
  }
}

