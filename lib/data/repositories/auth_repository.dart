import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wedly/core/utils/app_logger.dart';
import 'package:wedly/core/utils/enums.dart';
import 'package:wedly/data/models/user_model.dart';
import 'package:wedly/data/services/api_client.dart';
import 'package:wedly/data/services/api_constants.dart';
import 'package:wedly/data/services/api_exceptions.dart';
import 'package:wedly/data/services/token_manager.dart';
import 'package:wedly/data/services/social_auth_service.dart';

class AuthRepository {
  final ApiClient _apiClient;
  final TokenManager _tokenManager;

  UserModel? _currentUser;

  final _sessionExpiredController = StreamController<void>.broadcast();

  Stream<void> get sessionExpiredStream => _sessionExpiredController.stream;

  static const String _userKey = 'cached_user';
  static const String _isLoggedInKey = 'is_logged_in';

  AuthRepository({
    required ApiClient apiClient,
    required TokenManager tokenManager,
  })  : _apiClient = apiClient,
        _tokenManager = tokenManager {
    _apiClient.onSessionExpired = _handleSessionExpired;
  }

  void _handleSessionExpired() {
    _performLocalLogout();
    _sessionExpiredController.add(null);
  }

  void dispose() {
    _sessionExpiredController.close();
  }

  Future<void> _performLocalLogout() async {
    _currentUser = null;
    await _clearUserCache();
    await _tokenManager.clearTokens();
  }

  /// Login user with email and password
  Future<UserModel> login({
    required String email,
    required String password,
    UserRole? role,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.login,
      data: {
        'email': email,
        'password': password,
      },
    );

    final responseData = response.data['data'] ?? response.data;
    AppLogger.auth('Login response received');

    // Check if provider account is pending approval
    final isPending = responseData['pending'] == true ||
                      responseData['status'] == 'pending' ||
                      responseData['approval_status'] == 'pending';
    if (isPending) {
      final message = responseData['message'] as String? ??
          'حسابك قيد المراجعة. يرجى الانتظار حتى يتم الموافقة على حسابك.';
      throw ProviderPendingApprovalException(message: message);
    }

    // Save tokens
    final accessToken = (responseData['access_token'] ?? responseData['accessToken']) as String?;
    final refreshToken = (responseData['refresh_token'] ?? responseData['refreshToken']) as String?;

    if (accessToken == null || refreshToken == null) {
      throw Exception('فشل في الحصول على رموز المصادقة من الخادم');
    }

    AppLogger.success('Tokens extracted from response', tag: 'AuthRepo');

    await _tokenManager.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );

    // Parse user data
    final user = UserModel.fromJson(responseData['user']);
    await _tokenManager.saveUserRole(user.role.name);

    _currentUser = user;
    await _saveUserToCache(_currentUser!);
    AppLogger.auth('User logged in: ${user.email} (${user.role.name})');
    return user;
  }

  /// Save user to SharedPreferences
  Future<void> _saveUserToCache(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
    await prefs.setBool(_isLoggedInKey, true);
  }

  /// Load user from SharedPreferences
  Future<UserModel?> _loadUserFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;

    if (!isLoggedIn) return null;

    final userJson = prefs.getString(_userKey);

    if (userJson == null) return null;

    try {
      final user = UserModel.fromJson(jsonDecode(userJson));
      return user;
    } catch (e) {
      return null;
    }
  }

  /// Clear cached user data
  Future<void> _clearUserCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.setBool(_isLoggedInKey, false);
  }

  /// Logout user
  Future<void> logout() async {
    try {
      await _apiClient.post(ApiConstants.logout);
    } catch (e) {
      // Continue with local logout even if API fails
    }
    await _performLocalLogout();

    // Sign out from Google to clear cached account
    try {
      final socialAuthService = SocialAuthService();
      await socialAuthService.signOut();
    } catch (e) {
      AppLogger.warning('Social sign out error: $e', tag: 'AuthRepo');
    }
  }

  /// Get current user - checks cache first
  Future<UserModel?> getCurrentUser() async {
    if (_currentUser != null) {
      return _currentUser;
    }

    final cachedUser = await _loadUserFromCache();
    if (cachedUser != null) {
      _currentUser = cachedUser;
      return _currentUser;
    }

    try {
      final response = await _apiClient.get(ApiConstants.getCurrentUser);
      final responseData = response.data['data'] ?? response.data;
      _currentUser = UserModel.fromJson(responseData['user'] ?? responseData);
      await _saveUserToCache(_currentUser!);
      return _currentUser;
    } catch (e) {
      return null;
    }
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    return await _tokenManager.hasValidToken();
  }

  /// Set user role
  Future<void> setUserRole(UserRole role) async {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(role: role);
      await _saveUserToCache(_currentUser!);
    }
  }

  /// Update user profile
  Future<UserModel> updateProfile({
    String? name,
    String? phone,
    String? city,
    String? profileImageUrl,
  }) async {
    try {
      final response = await _apiClient.put(
        ApiConstants.updateUserProfile,
        data: {
          if (name != null) 'name': name,
          if (phone != null) 'phone': phone,
          if (city != null) 'city': city,
          if (profileImageUrl != null) 'profile_image_url': profileImageUrl,
        },
      );

      final responseData = response.data['data'] ?? response.data;
      final userData = responseData['user'] ?? responseData;

      final user = UserModel.fromJson(userData);
      _currentUser = user;
      await _saveUserToCache(user);
      return user;
    } catch (e) {
      AppLogger.error('Error in updateProfile', tag: 'AuthRepo', error: e);
      rethrow;
    }
  }

  /// Upload profile image
  Future<String> uploadProfileImage(String imagePath) async {
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(
        imagePath,
        filename: 'profile.jpg',
      ),
    });

    final response = await _apiClient.post(
      ApiConstants.uploadProfileImage,
      data: formData,
    );

    final responseData = response.data['data'] ?? response.data;
    final imageUrl = responseData['profile_image_url'] ??
                     responseData['image_url'] ??
                     responseData['imageUrl'] ??
                     responseData['url'];

    if (imageUrl == null) {
      throw Exception('Image URL not found in response: ${response.data}');
    }

    return imageUrl as String;
  }

  /// Change password
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.changePassword,
      data: {
        'current_password': currentPassword,
        'new_password': newPassword,
      },
    );

    final responseData = response.data['data'] ?? response.data;
    return {
      'success': responseData['success'] ?? true,
      'message': responseData['message'] ?? 'تم تغيير كلمة المرور بنجاح',
    };
  }

  /// Switch user role (user <-> provider)
  Future<UserModel> switchRole(UserRole newRole) async {
    final response = await _apiClient.post(
      ApiConstants.switchRole,
      data: {'role': newRole.name},
    );

    final responseData = response.data['data'] ?? response.data;
    final user = UserModel.fromJson(responseData['user'] ?? responseData);
    _currentUser = user;
    await _saveUserToCache(user);
    await _tokenManager.saveUserRole(user.role.name);
    return user;
  }

  /// Set wedding date
  Future<Map<String, dynamic>> setWeddingDate(DateTime weddingDate) async {
    final response = await _apiClient.post(
      ApiConstants.setWeddingDate,
      data: {
        'wedding_date': weddingDate.toIso8601String(),
      },
    );

    final responseData = response.data['data'] ?? response.data;

    // Update local user with wedding date
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(weddingDate: weddingDate);
      await _saveUserToCache(_currentUser!);
    }

    return {
      'success': responseData['success'] ?? true,
      'message': responseData['message'] ?? 'تم حفظ تاريخ الزفاف بنجاح',
      'wedding_date': weddingDate.toIso8601String(),
    };
  }

  /// Get wedding date
  Future<Map<String, dynamic>> getWeddingDate() async {
    final response = await _apiClient.get(ApiConstants.getWeddingDate);

    final responseData = response.data['data'] ?? response.data;
    return {
      'success': responseData['success'] ?? true,
      'message': responseData['message'] ?? 'تم جلب تاريخ الزفاف بنجاح',
      'wedding_date': responseData['wedding_date'],
      'days_remaining': responseData['days_remaining'],
    };
  }

  /// Register new user
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    String? city,
    required UserRole role,
  }) async {
    AppLogger.auth('Registering user with email: $email');
    final response = await _apiClient.post(
      ApiConstants.register,
      data: {
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
        if (city != null && city.isNotEmpty) 'city': city,
        'role': role.name,
      },
    );

    AppLogger.success('Registration response received', tag: 'AuthRepo');

    final responseData = response.data['data'] ?? response.data;
    return {
      'success': responseData['success'] ?? true,
      'message': responseData['message'] ?? 'تم إرسال كود التحقق',
      'email': email,
    };
  }

  /// Verify OTP for registration
  Future<UserModel> verifyOtp({
    required String email,
    required String otp,
    String? name,
    String? password,
    String? phone,
    UserRole? role,
  }) async {
    final requestData = {
      'email': email,
      'otp': otp.toString(),
    };

    AppLogger.auth('Sending verifyOtp request');

    final response = await _apiClient.post(
      ApiConstants.verifyOtp,
      data: requestData,
    );

    AppLogger.success('OTP Verification successful', tag: 'AuthRepo');

    final responseData = response.data['data'] ?? response.data;

    // Backend only returns {verified: true}, not user data or tokens
    if (responseData['verified'] == true) {
      AppLogger.auth('Account verified! Now logging in automatically...');

      if (password != null && email.isNotEmpty) {
        final loginUser = await login(
          email: email,
          password: password,
          role: role,
        );
        AppLogger.success('Auto-login successful', tag: 'AuthRepo');
        return loginUser;
      } else {
        throw Exception('لا يمكن تسجيل الدخول تلقائياً. الرجاء تسجيل الدخول يدوياً.');
      }
    }

    // Legacy flow: If backend returns user data directly
    final accessToken = responseData['access_token'] ?? responseData['accessToken'];
    final refreshToken = responseData['refresh_token'] ?? responseData['refreshToken'];
    if (accessToken != null && refreshToken != null) {
      await _tokenManager.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
    }

    final user = UserModel.fromJson(responseData['user'] ?? responseData);
    await _tokenManager.saveUserRole(user.role.name);

    _currentUser = user;
    await _saveUserToCache(_currentUser!);
    return user;
  }

  /// Resend OTP
  Future<Map<String, dynamic>> resendOtp({
    required String email,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.resendOtp,
      data: {'email': email},
    );

    final responseData = response.data['data'] ?? response.data;
    return {
      'success': responseData['success'] ?? true,
      'message': responseData['message'] ?? 'تم إعادة إرسال الكود',
    };
  }

  /// Register provider with documents
  Future<Map<String, dynamic>> registerProvider({
    required String email,
    required String password,
    required String name,
    String? phone,
    String? city,
    required String idFrontPath,
    required String idBackPath,
    String? commercialRegisterPath,
    String? taxCardPath,
  }) async {
    final formData = FormData();

    formData.fields.add(MapEntry('email', email));
    formData.fields.add(MapEntry('password', password));
    formData.fields.add(MapEntry('name', name));

    if (phone != null && phone.isNotEmpty) {
      formData.fields.add(MapEntry('phone', phone));
    }
    if (city != null && city.isNotEmpty) {
      formData.fields.add(MapEntry('city', city));
    }

    formData.files.add(MapEntry(
      'id_front',
      await MultipartFile.fromFile(idFrontPath, filename: 'id_front.jpg'),
    ));
    formData.files.add(MapEntry(
      'id_back',
      await MultipartFile.fromFile(idBackPath, filename: 'id_back.jpg'),
    ));

    if (commercialRegisterPath != null) {
      formData.files.add(MapEntry(
        'commercial_register',
        await MultipartFile.fromFile(commercialRegisterPath, filename: 'commercial_register.jpg'),
      ));
    }
    if (taxCardPath != null) {
      formData.files.add(MapEntry(
        'tax_card',
        await MultipartFile.fromFile(taxCardPath, filename: 'tax_card.jpg'),
      ));
    }

    AppLogger.auth('Registering provider with documents');
    final response = await _apiClient.post(
      ApiConstants.registerProvider,
      data: formData,
    );

    AppLogger.success('Provider registration response received', tag: 'AuthRepo');
    final responseData = response.data['data'] ?? response.data;
    return {
      'success': responseData['success'] ?? true,
      'message': responseData['message'] ?? 'تم إرسال طلبك للمراجعة بنجاح',
    };
  }

  /// Request password reset
  Future<Map<String, dynamic>> forgotPassword({
    required String email,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.forgotPassword,
      data: {'email': email},
    );

    final responseData = response.data['data'] ?? response.data;
    return {
      'success': responseData['success'] ?? true,
      'message': responseData['message'] ?? 'تم إرسال رمز التحقق',
      'email': email,
    };
  }

  /// Reset password with email, OTP and new password
  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String otp,
    required String password,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.resetPassword,
      data: {
        'email': email,
        'otp': otp,
        'new_password': password,
      },
    );

    final responseData = response.data['data'] ?? response.data;
    return {
      'success': responseData['success'] ?? true,
      'message': responseData['message'] ?? 'تم تغيير كلمة المرور بنجاح',
    };
  }

  /// Social login (Google)
  Future<UserModel> socialLogin({
    required String provider,
    required String email,
    required String name,
    required String providerId,
    String? profileImageUrl,
    String? firebaseToken,
    String? accessToken,
    String? idToken,
  }) async {
    if (idToken == null || idToken.isEmpty) {
      throw ValidationException(
        message: 'Google ID token is required for authentication',
      );
    }

    final response = await _apiClient.post(
      ApiConstants.googleLogin,
      data: {
        'id_token': idToken,
      },
    );

    final responseData = response.data['data'] ?? response.data;

    final accessTokenFromResponse =
        (responseData['access_token'] ?? responseData['accessToken']) as String?;
    final refreshToken =
        (responseData['refresh_token'] ?? responseData['refreshToken']) as String?;

    if (accessTokenFromResponse == null || refreshToken == null) {
      throw Exception('فشل في الحصول على رموز المصادقة من الخادم');
    }

    await _tokenManager.saveTokens(
      accessToken: accessTokenFromResponse,
      refreshToken: refreshToken,
    );

    final user = UserModel.fromJson(responseData['user']);
    await _tokenManager.saveUserRole(user.role.name);

    _currentUser = user;
    await _saveUserToCache(_currentUser!);
    return user;
  }
}
