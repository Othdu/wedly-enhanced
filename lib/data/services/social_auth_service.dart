import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Service for handling social authentication (Google & Apple)
/// This service works with native SDKs and sends tokens to backend
class SocialAuthService {
  // TODO: Replace with your actual iOS client ID from Google Cloud Console
  // Go to: https://console.cloud.google.com/ > APIs & Credentials > Create OAuth Client ID (iOS)
  // Bundle ID: com.wedly.wedding
  static const String _iosClientId =
      'YOUR_IOS_CLIENT_ID_HERE.apps.googleusercontent.com';

  // Server client ID for backend verification (to get idToken)
  static const String _serverClientId =
      '258355634687-t6lurbfodd4jg3dsipdgtsj06a0glkq2.apps.googleusercontent.com';

  late final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    // iOS needs an explicit clientId; Android gets it from google-services.json
    clientId: Platform.isIOS ? _iosClientId : null,
    serverClientId: _serverClientId,
  );

  /// Sign in with Google using native Google Sign-In
  /// Returns user data and tokens to be sent to backend
  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      // Disconnect completely to clear cached account and force account picker
      // disconnect() revokes access and clears the account, unlike signOut()
      try {
        await _googleSignIn.disconnect();
      } catch (e) {
        // Ignore error if not connected (first time sign in)
        // This is expected behavior
      }

      // Trigger the authentication flow - will now show account picker
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the sign-in
        throw Exception('تم إلغاء تسجيل الدخول');
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Return user data to be sent to your backend
      return {
        'provider': 'google',
        'provider_id': googleUser.id,
        'email': googleUser.email,
        'name': googleUser.displayName ?? '',
        'profile_image_url': googleUser.photoUrl,
        'access_token': googleAuth.accessToken,
        'id_token': googleAuth.idToken,
      };
    } catch (e) {
      debugPrint('❌ Google Sign In Error: $e');
      if (e.toString().contains('network_error')) {
        throw Exception('خطأ في الاتصال بالإنترنت');
      } else if (e.toString().contains('sign_in_canceled')) {
        throw Exception('تم إلغاء تسجيل الدخول');
      } else if (e.toString().contains('تم إلغاء')) {
        rethrow;
      }
      throw Exception('فشل تسجيل الدخول بواسطة Google');
    }
  }

  /// Sign in with Apple using native Sign in with Apple
  /// Returns user data and tokens to be sent to backend
  /// Note: Apple only provides name/email on FIRST sign-in
  Future<Map<String, dynamic>> signInWithApple() async {
    try {
      // Generate nonce for security
      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);

      // Request credentials from Apple
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      // Build name from Apple's response (may be null after first sign-in)
      String? fullName;
      if (credential.givenName != null || credential.familyName != null) {
        fullName = [
          credential.givenName,
          credential.familyName,
        ].where((name) => name != null && name.isNotEmpty).join(' ');
      }

      // Return user data to be sent to your backend
      return {
        'provider': 'apple',
        'provider_id': credential.userIdentifier,
        'email': credential.email,
        'name': fullName ?? '',
        'profile_image_url': null, // Apple doesn't provide profile image
        'identity_token': credential.identityToken,
        'authorization_code': credential.authorizationCode,
        'nonce': rawNonce, // Send raw nonce for backend verification
      };
    } on SignInWithAppleAuthorizationException catch (e) {
      debugPrint('❌ Apple Sign In Authorization Error: ${e.code} - ${e.message}');
      if (e.code == AuthorizationErrorCode.canceled) {
        throw Exception('تم إلغاء تسجيل الدخول');
      } else if (e.code == AuthorizationErrorCode.failed) {
        throw Exception('فشل تسجيل الدخول بواسطة Apple');
      } else if (e.code == AuthorizationErrorCode.invalidResponse) {
        throw Exception('استجابة غير صالحة من Apple');
      } else if (e.code == AuthorizationErrorCode.notHandled) {
        throw Exception('لم يتم التعامل مع الطلب');
      } else if (e.code == AuthorizationErrorCode.notInteractive) {
        throw Exception('يتطلب تفاعل المستخدم');
      }
      throw Exception('فشل تسجيل الدخول بواسطة Apple');
    } catch (e) {
      debugPrint('❌ Apple Sign In Error: $e');
      if (e.toString().contains('تم إلغاء')) {
        rethrow;
      }
      throw Exception('فشل تسجيل الدخول بواسطة Apple');
    }
  }

  /// Check if Apple Sign-In is available on this device
  /// Returns true on iOS 13+ and macOS 10.15+
  Future<bool> isAppleSignInAvailable() async {
    return await SignInWithApple.isAvailable();
  }

  /// Sign out from all social providers
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      debugPrint('❌ Social Sign Out Error: $e');
      // Continue even if sign out fails
    }
    // Note: Apple doesn't have a sign out method
    // The user manages their Apple ID connections in Settings
  }

  /// Check if user is signed in with Google
  Future<bool> isSignedInWithGoogle() async {
    return await _googleSignIn.isSignedIn();
  }

  /// Generate a random nonce string for Apple Sign-In
  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  /// Create SHA256 hash of a string for Apple Sign-In nonce
  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
