import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Service for handling social authentication (Google)
/// This service works with native SDKs and sends tokens to backend
class SocialAuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    // Server client ID for backend verification
    serverClientId: '258355634687-t6lurbfodd4jg3dsipdgtsj06a0glkq2.apps.googleusercontent.com',
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


  /// Sign out from all social providers
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      debugPrint('❌ Social Sign Out Error: $e');
      // Continue even if sign out fails
    }
  }

  /// Check if user is signed in with Google
  Future<bool> isSignedInWithGoogle() async {
    return await _googleSignIn.isSignedIn();
  }
}
