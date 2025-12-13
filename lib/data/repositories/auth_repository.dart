import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wedly/core/utils/enums.dart';
import 'package:wedly/data/models/user_model.dart';
import 'package:wedly/data/services/api_client.dart';
import 'package:wedly/data/services/api_constants.dart';
import 'package:wedly/data/services/token_manager.dart';

class AuthRepository {
  final ApiClient? _apiClient;
  final TokenManager? _tokenManager;
  final bool useMockData;

  // Mock current user - used when useMockData is true
  UserModel? _currentUser;

  // Stream controller for session expiry events
  final _sessionExpiredController = StreamController<void>.broadcast();

  // Stream for listening to session expiry
  Stream<void> get sessionExpiredStream => _sessionExpiredController.stream;

  // SharedPreferences keys
  static const String _userKey = 'cached_user';
  static const String _isLoggedInKey = 'is_logged_in';

  AuthRepository({
    ApiClient? apiClient,
    TokenManager? tokenManager,
    this.useMockData = true,
  })  : _apiClient = apiClient,
        _tokenManager = tokenManager {
    // Setup session expiry callback if using real API
    if (!useMockData && _apiClient != null) {
      _apiClient.onSessionExpired = _handleSessionExpired;
    }
  }

  /// Called when ApiClient detects expired refresh token
  void _handleSessionExpired() {
    // Perform local logout without calling API
    _performLocalLogout();
    // Notify listeners (AuthBloc) about session expiry
    _sessionExpiredController.add(null);
  }

  /// Dispose method to clean up resources
  void dispose() {
    _sessionExpiredController.close();
  }

  /// Local logout - clears tokens and cache without API call
  Future<void> _performLocalLogout() async {
    _currentUser = null;
    await _clearUserCache();
    if (!useMockData) {
      await _tokenManager?.clearTokens();
    }
  }

  /// Login user with email and password
  Future<UserModel> login({
    required String email,
    required String password,
    UserRole? role,
  }) async {
    if (useMockData) {
      return _mockLogin(email: email, password: password, role: role);
    } else {
      return _apiLogin(email: email, password: password);
    }
  }

  /// Mock login implementation
  Future<UserModel> _mockLogin({
    required String email,
    required String password,
    UserRole? role,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock login - always succeeds
    // Use a fixed user ID for mock data consistency with bookings
    final userRole = role ?? UserRole.user;
    _currentUser = UserModel(
      id: 'user_1763246207853', // Fixed mock user ID
      email: email,
      name: email.split('@')[0],
      role: userRole,
    );

    // Save user data to SharedPreferences
    await _saveUserToCache(_currentUser!);

    return _currentUser!;
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

  /// API login implementation
  Future<UserModel> _apiLogin({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient!.post(
      ApiConstants.login,
      data: {
        'email': email,
        'password': password,
      },
    );

    // Handle nested data structure
    final responseData = response.data['data'] ?? response.data;

    // Save tokens
    final accessToken = responseData['access_token'] ?? responseData['accessToken'] as String;
    final refreshToken = responseData['refresh_token'] ?? responseData['refreshToken'] as String;
    await _tokenManager!.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );

    // Parse user data
    final user = UserModel.fromJson(responseData['user']);
    await _tokenManager?.saveUserRole(user.role.name);

    _currentUser = user;
    return user;
  }

  /// Logout user
  Future<void> logout() async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      await _performLocalLogout();
    } else {
      try {
        // Try to notify server, but don't fail if it errors
        await _apiClient!.post(ApiConstants.logout);
      } catch (e) {
        // Continue with local logout even if API fails
      }
      await _performLocalLogout();
    }
  }

  /// Get current user - checks cache first
  Future<UserModel?> getCurrentUser() async {
    // First check if we have user in memory
    if (_currentUser != null) {
      return _currentUser;
    }

    // Then check cache
    final cachedUser = await _loadUserFromCache();
    if (cachedUser != null) {
      _currentUser = cachedUser;
      return _currentUser;
    }

    // Finally, try API if not using mock data
    if (!useMockData) {
      try {
        final response = await _apiClient!.get(ApiConstants.getCurrentUser);
        final responseData = response.data['data'] ?? response.data;
        _currentUser = UserModel.fromJson(responseData['user'] ?? responseData);
        await _saveUserToCache(_currentUser!);
        return _currentUser;
      } catch (e) {
        return null;
      }
    }

    return null;
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    if (useMockData) {
      return _currentUser != null;
    } else {
      return await _tokenManager!.hasValidToken();
    }
  }

  /// Set user role (for testing in mock mode)
  Future<void> setUserRole(UserRole role) async {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(role: role);
      // Save updated user to cache
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
    if (useMockData || _apiClient == null) {
      return _mockUpdateProfile(
        name: name,
        phone: phone,
        city: city,
        profileImageUrl: profileImageUrl,
      );
    } else {
      return _apiUpdateProfile(
        name: name,
        phone: phone,
        city: city,
        profileImageUrl: profileImageUrl,
      );
    }
  }

  Future<UserModel> _mockUpdateProfile({
    String? name,
    String? phone,
    String? city,
    String? profileImageUrl,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    if (_currentUser == null) {
      throw Exception('No user logged in');
    }

    // Update user with new values
    _currentUser = _currentUser!.copyWith(
      name: name ?? _currentUser!.name,
      phone: phone ?? _currentUser!.phone,
      city: city ?? _currentUser!.city,
      profileImageUrl: profileImageUrl ?? _currentUser!.profileImageUrl,
    );

    // Save to cache
    await _saveUserToCache(_currentUser!);

    return _currentUser!;
  }

  Future<UserModel> _apiUpdateProfile({
    String? name,
    String? phone,
    String? city,
    String? profileImageUrl,
  }) async {
    try {
      final response = await _apiClient!.put(
        ApiConstants.updateUserProfile,
        data: {
          if (name != null) 'name': name,
          if (phone != null) 'phone': phone,
          if (city != null) 'city': city,
          if (profileImageUrl != null) 'profile_image_url': profileImageUrl,
        },
      );

      print('📦 Update Profile Response: ${response.data}');
      final responseData = response.data['data'] ?? response.data;
      print('📦 Response Data: $responseData');
      final userData = responseData['user'] ?? responseData;
      print('📦 User Data: $userData');

      final user = UserModel.fromJson(userData);
      _currentUser = user;
      await _saveUserToCache(user);
      return user;
    } catch (e) {
      print('❌ Error in _apiUpdateProfile: $e');
      rethrow;
    }
  }

  /// Upload profile image
  Future<String> uploadProfileImage(String imagePath) async {
    if (useMockData || _apiClient == null) {
      return _mockUploadProfileImage();
    } else {
      return _apiUploadProfileImage(imagePath);
    }
  }

  Future<String> _mockUploadProfileImage() async {
    await Future.delayed(const Duration(milliseconds: 800));
    // Return a mock avatar URL
    return 'https://i.pravatar.cc/150?img=${DateTime.now().millisecondsSinceEpoch % 70}';
  }

  Future<String> _apiUploadProfileImage(String imagePath) async {
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(
        imagePath,
        filename: 'profile.jpg',
      ),
    });

    final response = await _apiClient!.post(
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
    if (useMockData || _apiClient == null) {
      return _mockChangePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
    } else {
      return _apiChangePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
    }
  }

  Future<Map<String, dynamic>> _mockChangePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    // Mock validation: check if current password is at least 6 chars
    if (currentPassword.length < 6) {
      throw Exception('كلمة المرور الحالية غير صحيحة');
    }

    if (newPassword.length < 6) {
      throw Exception('كلمة المرور الجديدة يجب أن تكون 6 أحرف على الأقل');
    }

    return {
      'success': true,
      'message': 'تم تغيير كلمة المرور بنجاح',
    };
  }

  Future<Map<String, dynamic>> _apiChangePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final response = await _apiClient!.post(
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
    if (useMockData || _apiClient == null) {
      return _mockSwitchRole(newRole);
    } else {
      return _apiSwitchRole(newRole);
    }
  }

  Future<UserModel> _mockSwitchRole(UserRole newRole) async {
    await Future.delayed(const Duration(milliseconds: 800));

    if (_currentUser == null) {
      throw Exception('No user logged in');
    }

    // Update role
    _currentUser = _currentUser!.copyWith(role: newRole);
    await _saveUserToCache(_currentUser!);

    return _currentUser!;
  }

  Future<UserModel> _apiSwitchRole(UserRole newRole) async {
    final response = await _apiClient!.post(
      ApiConstants.switchRole,
      data: {'role': newRole.name},
    );

    final responseData = response.data['data'] ?? response.data;
    final user = UserModel.fromJson(responseData['user'] ?? responseData);
    _currentUser = user;
    await _saveUserToCache(user);
    await _tokenManager?.saveUserRole(user.role.name);
    return user;
  }

  /// Set wedding date
  /// Note: This API endpoint sets the wedding date on the server.
  /// The wedding date is tracked separately in the CountdownModel.
  Future<Map<String, dynamic>> setWeddingDate(DateTime weddingDate) async {
    if (useMockData || _apiClient == null) {
      return _mockSetWeddingDate(weddingDate);
    } else {
      return _apiSetWeddingDate(weddingDate);
    }
  }

  Future<Map<String, dynamic>> _mockSetWeddingDate(DateTime weddingDate) async {
    await Future.delayed(const Duration(milliseconds: 600));

    if (_currentUser == null) {
      throw Exception('No user logged in');
    }

    return {
      'success': true,
      'message': 'تم حفظ تاريخ الزفاف بنجاح',
      'wedding_date': weddingDate.toIso8601String(),
    };
  }

  Future<Map<String, dynamic>> _apiSetWeddingDate(DateTime weddingDate) async {
    final response = await _apiClient!.post(
      ApiConstants.setWeddingDate,
      data: {
        'wedding_date': weddingDate.toIso8601String(),
      },
    );

    final responseData = response.data['data'] ?? response.data;
    return {
      'success': responseData['success'] ?? true,
      'message': responseData['message'] ?? 'تم حفظ تاريخ الزفاف بنجاح',
      'wedding_date': weddingDate.toIso8601String(),
    };
  }

  /// Register new user
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required UserRole role,
  }) async {
    if (useMockData) {
      return _mockRegister(name: name, email: email, password: password, phone: phone, role: role);
    } else {
      return _apiRegister(name: name, email: email, password: password, phone: phone, role: role);
    }
  }

  Future<Map<String, dynamic>> _mockRegister({
    required String name,
    required String email,
    required String password,
    required String phone,
    required UserRole role,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    // Mock registration - always succeeds
    return {
      'success': true,
      'message': 'تم إرسال كود التحقق إلى بريدك الإلكتروني',
      'email': email,
    };
  }

  Future<Map<String, dynamic>> _apiRegister({
    required String name,
    required String email,
    required String password,
    required String phone,
    required UserRole role,
  }) async {
    final response = await _apiClient!.post(
      ApiConstants.register,
      data: {
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
        'role': role.name,
      },
    );

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
  }) async {
    if (useMockData) {
      return _mockVerifyOtp(email: email, otp: otp);
    } else {
      return _apiVerifyOtp(email: email, otp: otp);
    }
  }

  Future<UserModel> _mockVerifyOtp({
    required String email,
    required String otp,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    // Mock OTP verification - always succeeds
    _currentUser = UserModel(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      name: email.split('@')[0],
      role: UserRole.user, // Default to user role
    );

    await _saveUserToCache(_currentUser!);
    return _currentUser!;
  }

  Future<UserModel> _apiVerifyOtp({
    required String email,
    required String otp,
  }) async {
    final response = await _apiClient!.post(
      ApiConstants.verifyOtp,
      data: {
        'email': email,
        'otp': otp,
      },
    );

    final responseData = response.data['data'] ?? response.data;

    // Save tokens if provided
    final accessToken = responseData['access_token'] ?? responseData['accessToken'];
    final refreshToken = responseData['refresh_token'] ?? responseData['refreshToken'];
    if (accessToken != null && refreshToken != null) {
      await _tokenManager!.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
    }

    // Parse user data
    final user = UserModel.fromJson(responseData['user'] ?? responseData);
    await _tokenManager?.saveUserRole(user.role.name);

    _currentUser = user;
    await _saveUserToCache(_currentUser!);
    return user;
  }

  /// Resend OTP
  Future<Map<String, dynamic>> resendOtp({
    required String email,
  }) async {
    if (useMockData) {
      return _mockResendOtp(email: email);
    } else {
      return _apiResendOtp(email: email);
    }
  }

  Future<Map<String, dynamic>> _mockResendOtp({
    required String email,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return {
      'success': true,
      'message': 'تم إعادة إرسال الكود بنجاح',
    };
  }

  Future<Map<String, dynamic>> _apiResendOtp({
    required String email,
  }) async {
    final response = await _apiClient!.post(
      ApiConstants.resendOtp,
      data: {'email': email},
    );

    final responseData = response.data['data'] ?? response.data;
    return {
      'success': responseData['success'] ?? true,
      'message': responseData['message'] ?? 'تم إعادة إرسال الكود',
    };
  }

  /// Request password reset
  Future<Map<String, dynamic>> forgotPassword({
    required String email,
  }) async {
    if (useMockData) {
      return _mockForgotPassword(email: email);
    } else {
      return _apiForgotPassword(email: email);
    }
  }

  Future<Map<String, dynamic>> _mockForgotPassword({
    required String email,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return {
      'success': true,
      'message': 'تم إرسال رمز التحقق إلى بريدك الإلكتروني',
      'email': email,
    };
  }

  Future<Map<String, dynamic>> _apiForgotPassword({
    required String email,
  }) async {
    final response = await _apiClient!.post(
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

  /// Reset password with token/OTP
  Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String password,
  }) async {
    if (useMockData) {
      return _mockResetPassword(token: token, password: password);
    } else {
      return _apiResetPassword(token: token, password: password);
    }
  }

  /// Social login (Google/Facebook)
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
    if (useMockData) {
      return _mockSocialLogin(
        email: email,
        name: name,
        profileImageUrl: profileImageUrl,
      );
    } else {
      return _apiSocialLogin(
        provider: provider,
        email: email,
        name: name,
        providerId: providerId,
        profileImageUrl: profileImageUrl,
        firebaseToken: firebaseToken,
        accessToken: accessToken,
        idToken: idToken,
      );
    }
  }

  Future<Map<String, dynamic>> _mockResetPassword({
    required String token,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return {
      'success': true,
      'message': 'تم تغيير كلمة المرور بنجاح',
    };
  }

  Future<Map<String, dynamic>> _apiResetPassword({
    required String token,
    required String password,
  }) async {
    final response = await _apiClient!.post(
      ApiConstants.resetPassword,
      data: {
        'token': token,
        'password': password,
      },
    );

    final responseData = response.data['data'] ?? response.data;
    return {
      'success': responseData['success'] ?? true,
      'message': responseData['message'] ?? 'تم تغيير كلمة المرور بنجاح',
    };
  }

  /// Mock social login implementation
  Future<UserModel> _mockSocialLogin({
    required String email,
    required String name,
    String? profileImageUrl,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    // Mock social login - always succeeds
    _currentUser = UserModel(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      name: name,
      role: UserRole.user,
      profileImageUrl: profileImageUrl,
    );

    await _saveUserToCache(_currentUser!);
    return _currentUser!;
  }

  /// API social login implementation
  Future<UserModel> _apiSocialLogin({
    required String provider,
    required String email,
    required String name,
    required String providerId,
    String? profileImageUrl,
    String? firebaseToken,
    String? accessToken,
    String? idToken,
  }) async {
    final response = await _apiClient!.post(
      ApiConstants.socialLogin,
      data: {
        'provider': provider, // 'google' or 'facebook'
        'provider_id': providerId,
        'email': email,
        'name': name,
        if (profileImageUrl != null) 'profile_image_url': profileImageUrl,
        if (firebaseToken != null) 'firebase_token': firebaseToken,
        if (accessToken != null) 'access_token': accessToken,
        if (idToken != null) 'id_token': idToken,
      },
    );

    // Handle nested data structure
    final responseData = response.data['data'] ?? response.data;

    // Save tokens
    final accessTokenFromResponse =
        responseData['access_token'] ?? responseData['accessToken'] as String;
    final refreshToken =
        responseData['refresh_token'] ?? responseData['refreshToken'] as String;
    await _tokenManager!.saveTokens(
      accessToken: accessTokenFromResponse,
      refreshToken: refreshToken,
    );

    // Parse user data
    final user = UserModel.fromJson(responseData['user']);
    await _tokenManager?.saveUserRole(user.role.name);

    _currentUser = user;
    await _saveUserToCache(_currentUser!);
    return user;
  }
}

