import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_constants.dart';

/// TokenManager handles secure storage and retrieval of authentication tokens.
/// Uses flutter_secure_storage for encrypted storage on device.
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

  /// ✅ FIX: Check token existence AND actual JWT expiry.
  ///
  /// Previously this only checked if the string was non-empty, so an expired
  /// token was treated as "valid" — causing the app to send it, get a 401,
  /// try to refresh, fail (because the refresh token was also old), and then
  /// kick the user out with "session expired".
  ///
  /// Now we decode the JWT payload and check the `exp` claim directly.
  /// A 60-second buffer is added so we proactively refresh just before expiry.
  Future<bool> hasValidToken() async {
    final token = await getAccessToken();
    if (token == null || token.isEmpty) return false;

    try {
      final expiry = _getTokenExpiry(token);
      if (expiry == null) {
        // Token has no exp claim — treat as valid (non-standard JWT)
        return true;
      }
      // Add 60s buffer: if token expires within 60 seconds, treat as expired
      // so the caller has time to refresh before the server rejects it
      final bufferExpiry = expiry.subtract(const Duration(seconds: 60));
      return DateTime.now().isBefore(bufferExpiry);
    } catch (_) {
      // If we can't decode the token for any reason, assume it might be valid
      // and let the server decide — don't kick the user preemptively
      return true;
    }
  }

  /// ✅ NEW: Check if the refresh token itself is still valid.
  ///
  /// This lets api_client.dart skip the refresh attempt entirely when it knows
  /// the refresh token has already expired, instead of making a doomed request
  /// that returns 401 and triggers an unnecessary logout.
  Future<bool> hasValidRefreshToken() async {
    final token = await getRefreshToken();
    if (token == null || token.isEmpty) return false;

    try {
      final expiry = _getTokenExpiry(token);
      if (expiry == null) return true;
      return DateTime.now().isBefore(expiry);
    } catch (_) {
      return true;
    }
  }

  /// ✅ NEW: Decode a JWT and return its expiry DateTime, or null if missing.
  ///
  /// JWT format: header.payload.signature (all base64url encoded)
  /// The payload is a JSON object; we read the `exp` field (Unix timestamp).
  DateTime? _getTokenExpiry(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      // Base64url → base64 (add padding if needed)
      String payload = parts[1];
      payload = payload.replaceAll('-', '+').replaceAll('_', '/');
      switch (payload.length % 4) {
        case 2:
          payload += '==';
          break;
        case 3:
          payload += '=';
          break;
      }

      final decoded = utf8.decode(base64.decode(payload));
      final Map<String, dynamic> claims = json.decode(decoded);

      if (!claims.containsKey('exp')) return null;

      final exp = claims['exp'];
      if (exp is int) {
        return DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      }
      return null;
    } catch (_) {
      return null;
    }
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