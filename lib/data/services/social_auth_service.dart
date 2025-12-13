import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

/// Service for handling social authentication (Google & Facebook)
/// This service communicates with Firebase Auth, and the tokens will be sent to your backend
class SocialAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Sign in with Google
  /// Returns user data that should be sent to your backend API
  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the sign-in
        throw Exception('تم إلغاء تسجيل الدخول');
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the credential
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user == null) {
        throw Exception('فشل تسجيل الدخول');
      }

      // Get the Firebase ID token to send to your backend
      final String? idToken = await user.getIdToken();

      // Return user data to be sent to your backend
      return {
        'provider': 'google',
        'provider_id': user.uid,
        'email': user.email ?? '',
        'name': user.displayName ?? '',
        'profile_image_url': user.photoURL,
        'firebase_token': idToken, // Send this to your backend for verification
        'access_token': googleAuth.accessToken,
        'id_token': googleAuth.idToken,
      };
    } catch (e) {
      print('❌ Google Sign In Error: $e');
      if (e.toString().contains('network_error')) {
        throw Exception('خطأ في الاتصال بالإنترنت');
      } else if (e.toString().contains('sign_in_canceled')) {
        throw Exception('تم إلغاء تسجيل الدخول');
      } else if (e.toString().contains('sign_in_failed')) {
        throw Exception('فشل تسجيل الدخول. يرجى المحاولة مرة أخرى');
      }
      throw Exception('فشل تسجيل الدخول بواسطة Google: ${e.toString()}');
    }
  }

  /// Sign in with Facebook
  /// Returns user data that should be sent to your backend API
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

      // Create a credential from the access token
      final OAuthCredential facebookAuthCredential =
          FacebookAuthProvider.credential(accessToken.tokenString);

      // Sign in to Firebase with the credential
      final UserCredential userCredential =
          await _auth.signInWithCredential(facebookAuthCredential);
      final User? user = userCredential.user;

      if (user == null) {
        throw Exception('فشل تسجيل الدخول');
      }

      // Get user data from Facebook
      final userData = await FacebookAuth.instance.getUserData();

      // Get the Firebase ID token to send to your backend
      final String? idToken = await user.getIdToken();

      // Return user data to be sent to your backend
      return {
        'provider': 'facebook',
        'provider_id': user.uid,
        'email': userData['email'] ?? user.email ?? '',
        'name': userData['name'] ?? user.displayName ?? '',
        'profile_image_url': userData['picture']?['data']?['url'] ?? user.photoURL,
        'firebase_token': idToken, // Send this to your backend for verification
        'access_token': accessToken.tokenString,
      };
    } catch (e) {
      print('❌ Facebook Sign In Error: $e');
      if (e.toString().contains('network_error')) {
        throw Exception('خطأ في الاتصال بالإنترنت');
      } else if (e.toString().contains('cancelled')) {
        throw Exception('تم إلغاء تسجيل الدخول');
      }
      throw Exception('فشل تسجيل الدخول بواسطة Facebook: ${e.toString()}');
    }
  }

  /// Sign out from all social providers
  Future<void> signOut() async {
    try {
      await Future.wait([
        _googleSignIn.signOut(),
        FacebookAuth.instance.logOut(),
        _auth.signOut(),
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

  /// Get current Firebase user
  User? getCurrentUser() {
    return _auth.currentUser;
  }
}
