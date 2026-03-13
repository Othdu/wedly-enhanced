# Wedly App - Launch Plan

## ✅ Done

### Auth
- [x] Email/password login, register, OTP verification
- [x] Forgot password / reset password
- [x] Google Sign-In — iOS client ID set, URL scheme in Info.plist
- [x] Apple Sign-In — `identityToken` payload correct, entitlements present
- [x] Token refresh with request queuing
- [x] Auto logout on session expiry

### Permissions
- [x] iOS camera & photos — handled natively by image_picker (no permission_handler needed)
- [x] Android camera & photos — permission_handler with fallback
- [x] Info.plist usage descriptions for camera, photos, location

### Code Quality
- [x] PrettyDioLogger disabled in production (kDebugMode guard)
- [x] Removed unused packages: google_maps_flutter, geolocator
- [x] Podfile GCC_PREPROCESSOR_DEFINITIONS for PERMISSION_CAMERA and PERMISSION_PHOTOS

---

## 🔧 Still Needed

### Apple Sign-In (Outside Code)
- [ ] Apple Developer Portal → enable "Sign In with Apple" for App ID `com.wedlyapp.wedly`
- [ ] Xcode → Runner → Signing & Capabilities → add "Sign In with Apple" capability
- [ ] Regenerate provisioning profile after enabling capability

### iOS Build
- [ ] Run `cd ios && pod install --repo-update` after Podfile changes
- [ ] Run `flutter clean && flutter build ios`
- [ ] Delete app from device before reinstalling (clears cached permission decisions)

### Issue #1 — Token Interceptor (Low Priority)
- [ ] Add `/auth/google-login` and `/auth/apple-login` to the bypass list in `api_client.dart`
  - Currently only `/auth/social-login` (old path) is bypassed
  - Risk: low, but if these endpoints return 401, interceptor tries to refresh unnecessarily

---

## 📋 Before App Store Submission

- [ ] Apple Sign-In working end-to-end (requires backend + portal setup above)
- [ ] Test Google Sign-In on real device
- [ ] Test image picker (camera + gallery) on real device
- [ ] Test all booking, payment, and notification flows
- [ ] Remove or gate any test/demo credentials
- [ ] Set `flutter build ios --release` and test on TestFlight first
- [ ] Apple requires Sign In with Apple if Google Sign-In is shown (guideline 4.8)
