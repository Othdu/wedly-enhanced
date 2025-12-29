import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

/// Service for handling social authentication (Google & Facebook)
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
      print('❌ Google Sign In Error: $e');
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

  /// Sign in with Facebook
  /// Uses flutter_facebook_auth for native Facebook login
  Future<Map<String, dynamic>> signInWithFacebook() async {
    try {
      // Trigger the sign-in flow
      final LoginResult loginResult = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      if (loginResult.status != LoginStatus.success) {
        if (loginResult.status == LoginStatus.cancelled) {
          throw Exception('تم إلغاء تسجيل الدخول');
        }
        throw Exception('فشل تسجيل الدخول: ${loginResult.message}');
      }

      // Get the access token
      final AccessToken? accessToken = loginResult.accessToken;
      if (accessToken == null) {
        throw Exception('فشل الحصول على رمز الوصول');
      }

      // Get user data from Facebook
      final userData = await FacebookAuth.instance.getUserData();

      // Return user data to be sent to your backend
      return {
        'provider': 'facebook',
        'provider_id': userData['id'] ?? '',
        'email': userData['email'] ?? '',
        'name': userData['name'] ?? '',
        'profile_image_url': userData['picture']?['data']?['url'],
        'access_token': accessToken.tokenString,
      };
    } catch (e) {
      print('❌ Facebook Sign In Error: $e');
      if (e.toString().contains('network_error')) {
        throw Exception('خطأ في الاتصال بالإنترنت');
      } else if (e.toString().contains('تم إلغاء')) {
        rethrow;
      }
      throw Exception('فشل تسجيل الدخول بواسطة Facebook');
    }
  }

  /// Sign out from all social providers
  Future<void> signOut() async {
    try {
      await Future.wait([
        _googleSignIn.signOut(),
        FacebookAuth.instance.logOut(),
      ]);
    } catch (e) {
      print('❌ Social Sign Out Error: $e');
      // Continue even if sign out fails
    }
  }

  /// Check if user is signed in with Google
  Future<bool> isSignedInWithGoogle() async {
    return await _googleSignIn.isSignedIn();
  }
}
