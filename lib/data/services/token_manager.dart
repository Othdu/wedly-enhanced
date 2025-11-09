import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_constants.dart';

/// TokenManager handles secure storage and retrieval of authentication tokens
/// Uses flutter_secure_storage for encrypted storage on device
class TokenManager {
  final FlutterSecureStorage _secureStorage;

  TokenManager(this._secureStorage);

  /// Save access token securely
  Future<void> saveAccessToken(String token) async {
    await _secureStorage.write(
      key: ApiConstants.accessTokenKey,
      value: token,
    );
  }

  /// Get access token
  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: ApiConstants.accessTokenKey);
  }

  /// Save refresh token securely
  Future<void> saveRefreshToken(String token) async {
    await _secureStorage.write(
      key: ApiConstants.refreshTokenKey,
      value: token,
    );
  }

  /// Get refresh token
  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: ApiConstants.refreshTokenKey);
  }

  /// Save user role
  Future<void> saveUserRole(String role) async {
    await _secureStorage.write(
      key: ApiConstants.userRoleKey,
      value: role,
    );
  }

  /// Get user role
  Future<String?> getUserRole() async {
    return await _secureStorage.read(key: ApiConstants.userRoleKey);
  }

  /// Save both tokens at once
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      saveAccessToken(accessToken),
      saveRefreshToken(refreshToken),
    ]);
  }

  /// Check if user has valid access token
  Future<bool> hasValidToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  /// Clear all stored tokens (logout)
  Future<void> clearTokens() async {
    await Future.wait([
      _secureStorage.delete(key: ApiConstants.accessTokenKey),
      _secureStorage.delete(key: ApiConstants.refreshTokenKey),
      _secureStorage.delete(key: ApiConstants.userRoleKey),
    ]);
  }

  /// Clear all secure storage
  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
  }
}
