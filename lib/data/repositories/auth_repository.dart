import 'dart:async';
import 'dart:convert';
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

  // SharedPreferences keys
  static const String _userKey = 'cached_user';
  static const String _isLoggedInKey = 'is_logged_in';

  AuthRepository({
    ApiClient? apiClient,
    TokenManager? tokenManager,
    this.useMockData = true,
  })  : _apiClient = apiClient,
        _tokenManager = tokenManager;

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
    final userRole = role ?? UserRole.user;
    _currentUser = UserModel(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
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

    print('🔍 _loadUserFromCache: isLoggedIn = $isLoggedIn');

    if (!isLoggedIn) return null;

    final userJson = prefs.getString(_userKey);
    print('🔍 _loadUserFromCache: userJson = $userJson');

    if (userJson == null) return null;

    try {
      final user = UserModel.fromJson(jsonDecode(userJson));
      print('✅ Successfully loaded user from cache: ${user.email} (${user.role})');
      return user;
    } catch (e) {
      print('❌ Error parsing cached user: $e');
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

    // Save tokens
    final accessToken = response.data['access_token'] as String;
    final refreshToken = response.data['refresh_token'] as String;
    await _tokenManager!.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );

    // Parse user data
    final user = UserModel.fromJson(response.data['user']);
    await _tokenManager?.saveUserRole(user.role.name);

    _currentUser = user;
    return user;
  }

  /// Logout user
  Future<void> logout() async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      _currentUser = null;
      await _clearUserCache();
    } else {
      try {
        await _apiClient!.post(ApiConstants.logout);
      } catch (e) {
        // Continue with logout even if API call fails
      }
      await _tokenManager!.clearTokens();
      _currentUser = null;
      await _clearUserCache();
    }
  }

  /// Get current user - checks cache first
  Future<UserModel?> getCurrentUser() async {
    print('🔍 AuthRepository.getCurrentUser() called');

    // First check if we have user in memory
    if (_currentUser != null) {
      print('✅ Found user in memory: ${_currentUser!.email} (${_currentUser!.role})');
      return _currentUser;
    }

    print('⚠️ No user in memory, checking SharedPreferences cache...');

    // Then check cache
    final cachedUser = await _loadUserFromCache();
    if (cachedUser != null) {
      print('✅ Found user in cache: ${cachedUser.email} (${cachedUser.role})');
      _currentUser = cachedUser;
      return _currentUser;
    }

    print('❌ No cached user found');

    // Finally, try API if not using mock data
    if (!useMockData) {
      try {
        final response = await _apiClient!.get(ApiConstants.getCurrentUser);
        _currentUser = UserModel.fromJson(response.data['user']);
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
}

