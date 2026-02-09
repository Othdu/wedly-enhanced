import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wedly/core/utils/app_logger.dart';
import 'package:wedly/core/utils/error_handler.dart';
import 'package:wedly/data/repositories/auth_repository.dart';
import 'package:wedly/data/services/social_auth_service.dart';
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
    on<AuthRegisterRequested>(_onAuthRegisterRequested);
    on<AuthOtpVerificationRequested>(_onAuthOtpVerificationRequested);
    on<AuthResendOtpRequested>(_onAuthResendOtpRequested);
    on<AuthForgotPasswordRequested>(_onAuthForgotPasswordRequested);
    on<AuthResetPasswordRequested>(_onAuthResetPasswordRequested);
    on<AuthSessionExpired>(_onAuthSessionExpired);
    on<AuthChangePasswordRequested>(_onAuthChangePasswordRequested);
    on<AuthUpdateProfileImageRequested>(_onAuthUpdateProfileImageRequested);
    on<AuthSocialLoginRequested>(_onAuthSocialLoginRequested);
    on<AuthSetWeddingDateRequested>(_onAuthSetWeddingDateRequested);
    on<AuthGetWeddingDateRequested>(_onAuthGetWeddingDateRequested);
    on<AuthSetEventRequested>(_onAuthSetEventRequested);
    on<AuthDeleteEventRequested>(_onAuthDeleteEventRequested);

    // Listen to session expiry events from repository
    authRepository.sessionExpiredStream.listen((_) {
      add(const AuthSessionExpired());
    });

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
      emit(AuthError(ErrorHandler.getContextualMessage(e, 'login')));
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
      emit(AuthError(ErrorHandler.getContextualMessage(e, 'logout')));
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

    AppLogger.debug('Starting profile update...', tag: 'AuthBloc');
    emit(const AuthLoading());
    try {
      // Call repository to update profile via API
      final updatedUser = await authRepository.updateProfile(
        name: event.name,
        phone: event.phone,
        city: event.city,
        profileImageUrl: event.profileImageUrl,
      );

      AppLogger.success('Profile update successful', tag: 'AuthBloc');
      // Emit success state with updated user
      emit(AuthProfileUpdateSuccess(
        user: updatedUser,
        message: 'تم تحديث البيانات بنجاح',
      ));
      // Emit the updated authenticated state
      emit(AuthAuthenticated(updatedUser));
    } catch (e) {
      AppLogger.error('Profile update failed', tag: 'AuthBloc', error: e);
      // If update fails, emit error but keep current state
      emit(AuthError(ErrorHandler.getContextualMessage(e, 'profile_update')));
      // Re-emit current authenticated state after error
      emit(currentState);
    }
  }

  Future<void> _onAuthRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final result = await authRepository.register(
        name: event.name,
        email: event.email,
        password: event.password,
        phone: event.phone,
        role: event.role,
      );
      emit(AuthRegistrationSuccess(
        email: result['email'],
        message: result['message'] ?? 'تم إرسال كود التحقق إلى بريدك الإلكتروني',
      ));
    } catch (e) {
      emit(AuthError(ErrorHandler.getContextualMessage(e, 'registration')));
    }
  }

  Future<void> _onAuthOtpVerificationRequested(
    AuthOtpVerificationRequested event,
    Emitter<AuthState> emit,
  ) async {
    AppLogger.auth('Starting OTP verification...');
    emit(const AuthLoading());
    try {
      final user = await authRepository.verifyOtp(
        email: event.email,
        otp: event.otp,
        name: event.name,
        password: event.password,
        phone: event.phone,
        role: event.role,
      );

      AppLogger.success('OTP verified successfully', tag: 'AuthBloc');
      AppLogger.debug('User: ${user.name}, ${user.email}, ${user.role}', tag: 'AuthBloc');

      // Emit success state for UI navigation
      emit(AuthOtpVerificationSuccess(user));

      // CRITICAL: Also emit AuthAuthenticated so all screens get updated user data
      // This ensures profile and other screens show correct data immediately
      emit(AuthAuthenticated(user));
    } catch (e) {
      AppLogger.error('OTP verification failed', tag: 'AuthBloc', error: e);
      emit(AuthError(ErrorHandler.getContextualMessage(e, 'otp_verification')));
    }
  }

  Future<void> _onAuthResendOtpRequested(
    AuthResendOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final result = await authRepository.resendOtp(
        email: event.email,
      );
      emit(AuthResendOtpSuccess(
        result['message'] ?? 'تم إعادة إرسال الكود',
      ));
    } catch (e) {
      emit(AuthError(ErrorHandler.getContextualMessage(e, 'resend_otp')));
    }
  }

  Future<void> _onAuthForgotPasswordRequested(
    AuthForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final result = await authRepository.forgotPassword(
        email: event.email,
      );
      emit(AuthForgotPasswordSuccess(
        email: result['email'],
        message: result['message'] ?? 'تم إرسال رمز التحقق إلى بريدك الإلكتروني',
      ));
    } catch (e) {
      emit(AuthError(ErrorHandler.getContextualMessage(e, 'forgot_password')));
    }
  }

  Future<void> _onAuthResetPasswordRequested(
    AuthResetPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final result = await authRepository.resetPassword(
        email: event.email,
        otp: event.otp,
        password: event.password,
      );  
      emit(AuthResetPasswordSuccess(
        result['message'] ?? 'تم تغيير كلمة المرور بنجاح',
      ));
    } catch (e) {
      emit(AuthError(ErrorHandler.getContextualMessage(e, 'reset_password')));
    }
  }

  /// Handle session expiry (triggered by ApiClient via AuthRepository callback)
  Future<void> _onAuthSessionExpired(
    AuthSessionExpired event,
    Emitter<AuthState> emit,
  ) async {
    AppLogger.warning('Session expired, logging out', tag: 'AuthBloc');
    // Directly emit unauthenticated state
    // No API call needed - already handled by ApiClient
    emit(const AuthUnauthenticated());
  }

  Future<void> _onAuthChangePasswordRequested(
    AuthChangePasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AuthAuthenticated) return;

    emit(const AuthLoading());
    try {
      final result = await authRepository.changePassword(
        currentPassword: event.currentPassword,
        newPassword: event.newPassword,
      );
      emit(AuthChangePasswordSuccess(
        result['message'] ?? 'تم تغيير كلمة المرور بنجاح',
      ));
      // Re-emit authenticated state after success
      emit(currentState);
    } catch (e) {
      emit(AuthError(ErrorHandler.getContextualMessage(e, 'change_password')));
      // Re-emit current authenticated state after error
      emit(currentState);
    }
  }

  Future<void> _onAuthUpdateProfileImageRequested(
    AuthUpdateProfileImageRequested event,
    Emitter<AuthState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AuthAuthenticated) return;

    emit(const AuthLoading());
    try {
      // Upload image and get URL
      final imageUrl = await authRepository.uploadProfileImage(event.imagePath);

      // Update user profile with new image URL
      final updatedUser = await authRepository.updateProfile(
        profileImageUrl: imageUrl,
      );

      emit(AuthProfileImageUpdateSuccess(
        user: updatedUser,
        message: 'تم تحديث الصورة بنجاح',
      ));
      // Emit updated authenticated state
      emit(AuthAuthenticated(updatedUser));
    } catch (e) {
      emit(AuthError(ErrorHandler.getContextualMessage(e, 'profile_image_update')));
      // Re-emit current authenticated state after error
      emit(currentState);
    }
  }

  Future<void> _onAuthSocialLoginRequested(
    AuthSocialLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final socialAuthService = SocialAuthService();
      Map<String, dynamic> socialData;

      if (event.provider == 'google') {
        socialData = await socialAuthService.signInWithGoogle();
      } else if (event.provider == 'apple') {
        socialData = await socialAuthService.signInWithApple();
      } else {
        throw Exception('مزود غير مدعوم');
      }

      // Send social login data to backend
      // Apple uses identity_token instead of id_token
      final user = await authRepository.socialLogin(
        provider: socialData['provider'],
        email: socialData['email'],
        name: socialData['name'],
        providerId: socialData['provider_id'],
        profileImageUrl: socialData['profile_image_url'],
        accessToken: socialData['access_token'],
        idToken: socialData['id_token'] ?? socialData['identity_token'],
      );

      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(ErrorHandler.getContextualMessage(e, 'social_login')));
    }
  }

  Future<void> _onAuthSetWeddingDateRequested(
    AuthSetWeddingDateRequested event,
    Emitter<AuthState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AuthAuthenticated) return;

    emit(const AuthLoading());
    try {
      final result = await authRepository.setWeddingDate(event.weddingDate);

      // Update user with new wedding date
      final updatedUser = currentState.user.copyWith(weddingDate: event.weddingDate);

      emit(AuthSetWeddingDateSuccess(
        result['message'] ?? 'تم حفظ تاريخ الزفاف بنجاح',
      ));
      // Emit updated authenticated state with new wedding date
      emit(AuthAuthenticated(updatedUser));
    } catch (e) {
      emit(AuthError(ErrorHandler.getContextualMessage(e, 'set_wedding_date')));
      // Re-emit current authenticated state after error
      emit(currentState);
    }
  }

  Future<void> _onAuthGetWeddingDateRequested(
    AuthGetWeddingDateRequested event,
    Emitter<AuthState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AuthAuthenticated) return;

    emit(const AuthLoading());
    try {
      final result = await authRepository.getWeddingDate();

      DateTime? weddingDate;
      if (result['wedding_date'] != null) {
        weddingDate = DateTime.parse(result['wedding_date'] as String);
      }

      emit(AuthGetWeddingDateSuccess(
        weddingDate: weddingDate,
        daysRemaining: result['days_remaining'] as int?,
        message: result['message'] ?? 'تم جلب تاريخ الزفاف بنجاح',
      ));
      // Re-emit current authenticated state
      emit(currentState);
    } catch (e) {
      emit(AuthError(ErrorHandler.getContextualMessage(e, 'get_wedding_date')));
      // Re-emit current authenticated state after error
      emit(currentState);
    }
  }

  Future<void> _onAuthSetEventRequested(
    AuthSetEventRequested event,
    Emitter<AuthState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AuthAuthenticated) return;

    emit(const AuthLoading());
    try {
      final result = await authRepository.setEvent(
        eventName: event.eventName,
        eventDate: event.eventDate,
      );

      // Update user with new event date and name
      final updatedUser = currentState.user.copyWith(
        weddingDate: event.eventDate,
        eventName: event.eventName,
      );

      emit(AuthEventUpdateSuccess(
        user: updatedUser,
        message: result['message'] ?? 'تم حفظ مناسبتك بنجاح',
      ));
      // Emit updated authenticated state with new event date
      emit(AuthAuthenticated(updatedUser));
    } catch (e) {
      emit(AuthError(ErrorHandler.getContextualMessage(e, 'set_event')));
      // Re-emit current authenticated state after error
      emit(currentState);
    }
  }

  Future<void> _onAuthDeleteEventRequested(
    AuthDeleteEventRequested event,
    Emitter<AuthState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AuthAuthenticated) return;

    emit(const AuthLoading());
    try {
      final result = await authRepository.deleteEvent();

      // Update user with past date to hide countdown
      final pastDate = DateTime(2020, 12, 12);
      final updatedUser = currentState.user.copyWith(weddingDate: pastDate);

      emit(AuthEventUpdateSuccess(
        user: updatedUser,
        message: result['message'] ?? 'تم حذف المناسبة بنجاح',
      ));
      // Emit updated authenticated state
      emit(AuthAuthenticated(updatedUser));
    } catch (e) {
      emit(AuthError(ErrorHandler.getContextualMessage(e, 'delete_event')));
      // Re-emit current authenticated state after error
      emit(currentState);
    }
  }
}

