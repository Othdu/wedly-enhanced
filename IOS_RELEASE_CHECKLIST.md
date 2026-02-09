# iOS Release Checklist for Wedly

> **Last Updated:** January 31, 2026
> **Bundle ID:** `com.wedly.wedding
`
> **Min iOS Version:** 13.0
> **Current Readiness:** 70/100

---

## ✅ Completed (No Mac Required)

### 1. Info.plist Configuration
- [x] `LSApplicationQueriesSchemes` added (tel, mailto, https, http, whatsapp, comgooglemaps)
- [x] `NSAppTransportSecurity` configured for WebView
- [x] Camera permission (`NSCameraUsageDescription`) - Arabic
- [x] Photo Library permission (`NSPhotoLibraryUsageDescription`) - Arabic
- [x] Photo Library Add permission (`NSPhotoLibraryAddUsageDescription`) - Arabic
- [x] Location When In Use permission (`NSLocationWhenInUseUsageDescription`) - Arabic
- [x] Google Sign-In URL scheme configured

### 2. Bundle Identifier
- [x] Changed from `com.example.wedly` to `com.wedly.wedding
`
- [x] Updated in all build configurations (Debug, Release, Profile)

### 3. Entitlements
- [x] Created `ios/Runner/Runner.entitlements`
- [x] Keychain access for `flutter_secure_storage`
- [x] Apple Sign-In capability

### 4. Apple Sign-In Implementation
- [x] Added `sign_in_with_apple: ^6.1.4` package
- [x] Added `crypto: ^3.0.6` package
- [x] Implemented `signInWithApple()` in `SocialAuthService`
- [x] Updated `AuthBloc` to handle 'apple' provider
- [x] Updated login screen button
- [x] Updated signup screen button

---

## 🔧 Requires Mac

### 1. Generate Podfile
```bash
cd ios
flutter build ios
# This generates Podfile automatically
```

After generation, add this to `ios/Podfile`:
```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
        '$(inherited)',
        'PERMISSION_CAMERA=1',
        'PERMISSION_PHOTOS=1',
        'PERMISSION_LOCATION=1',
      ]
    end
  end
end
```

### 2. Install CocoaPods Dependencies
```bash
cd ios
pod install
```

### 3. Open in Xcode
```bash
open ios/Runner.xcworkspace
```

---

## 📱 Apple Developer Portal Setup

### 1. App ID Configuration
1. Go to [Apple Developer Portal](https://developer.apple.com/account/resources/identifiers/list)
2. Click **"+"** to register new App ID
3. Select **"App IDs"** → Continue
4. Select **"App"** → Continue
5. Enter:
   - **Description:** Wedly
   - **Bundle ID:** `com.wedly.wedding
` (Explicit)
6. Enable Capabilities:
   - [x] **Sign In with Apple**
7. Click **Continue** → **Register**

### 2. Sign In with Apple Service ID (for Web/Backend)
1. Go to **Identifiers** → Click **"+"**
2. Select **"Services IDs"** → Continue
3. Enter:
   - **Description:** Wedly Web Auth
   - **Identifier:** `com.wedly.wedding
.auth`
4. Enable **Sign In with Apple**
5. Configure:
   - **Primary App ID:** `com.wedly.wedding
`
   - **Domains:** Your backend domain
   - **Return URLs:** Your callback URL

### 3. Generate Keys
1. Go to **Keys** → Click **"+"**
2. Enter **Key Name:** `Wedly Apple Sign In`
3. Enable **Sign In with Apple**
4. Configure → Select Primary App ID
5. **Download** the `.p8` key file (save securely!)
6. Note the **Key ID**

### 4. Provisioning Profile
1. Go to **Profiles** → Click **"+"**
2. Select **"App Store"** (for distribution)
3. Select App ID: `com.wedly.wedding
`
4. Select certificate
5. Enter profile name → **Generate** → **Download**

---

## 🔐 Google Sign-In Setup for iOS

### 1. Firebase Console (if using Firebase)
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project
3. Go to **Project Settings** → **General**
4. Add iOS app with bundle ID: `com.wedly.wedding
`
5. Download `GoogleService-Info.plist`
6. Place in `ios/Runner/GoogleService-Info.plist`

### 2. Google Cloud Console (if not using Firebase)
1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Select your project
3. Go to **APIs & Services** → **Credentials**
4. Create **OAuth 2.0 Client ID** for iOS
5. Enter bundle ID: `com.wedly.wedding
`
6. Note the **iOS Client ID**
7. The reversed client ID is already in Info.plist

---

## 🎨 App Assets (Required Before Submission)

### 1. App Icon
Replace all files in `ios/Runner/Assets.xcassets/AppIcon.appiconset/`:

| Size | Scale | Filename | Usage |
|------|-------|----------|-------|
| 20x20 | 1x | Icon-App-20x20@1x.png | iPad Notifications |
| 20x20 | 2x | Icon-App-20x20@2x.png | iPhone/iPad Notifications |
| 20x20 | 3x | Icon-App-20x20@3x.png | iPhone Notifications |
| 29x29 | 1x | Icon-App-29x29@1x.png | iPad Settings |
| 29x29 | 2x | Icon-App-29x29@2x.png | iPhone/iPad Settings |
| 29x29 | 3x | Icon-App-29x29@3x.png | iPhone Settings |
| 40x40 | 1x | Icon-App-40x40@1x.png | iPad Spotlight |
| 40x40 | 2x | Icon-App-40x40@2x.png | iPhone/iPad Spotlight |
| 40x40 | 3x | Icon-App-40x40@3x.png | iPhone Spotlight |
| 60x60 | 2x | Icon-App-60x60@2x.png | iPhone App |
| 60x60 | 3x | Icon-App-60x60@3x.png | iPhone App |
| 76x76 | 1x | Icon-App-76x76@1x.png | iPad App |
| 76x76 | 2x | Icon-App-76x76@2x.png | iPad App |
| 83.5x83.5 | 2x | Icon-App-83.5x83.5@2x.png | iPad Pro App |
| 1024x1024 | 1x | Icon-App-1024x1024@1x.png | App Store |

**Tips:**
- Create 1024x1024 master icon first
- Use [App Icon Generator](https://appicon.co/) to generate all sizes
- No transparency allowed
- No rounded corners (iOS adds them)

### 2. Launch Screen
Replace files in `ios/Runner/Assets.xcassets/LaunchImage.imageset/`:
- `LaunchImage.png` (1x)
- `LaunchImage@2x.png` (2x)
- `LaunchImage@3x.png` (3x)

Or customize `ios/Runner/Base.lproj/LaunchScreen.storyboard` in Xcode.

---

## 📋 App Store Connect Setup

### 1. Create App
1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. **My Apps** → **"+"** → **New App**
3. Enter:
   - **Platform:** iOS
   - **Name:** Wedly (or your app name in Arabic)
   - **Primary Language:** Arabic
   - **Bundle ID:** `com.wedly.wedding
`
   - **SKU:** `wedly-ios-001`

### 2. App Information
- **Category:** Lifestyle
- **Content Rights:** Does not contain third-party content (or declare if it does)
- **Age Rating:** Complete questionnaire

### 3. App Privacy
Required privacy policy URL and data collection declarations:
- **Data Collected:**
  - Name (for account)
  - Email (for account)
  - Phone (for account)
  - Photos (for document upload)
  - Location (for service providers)
  - Payment Info (for bookings)

### 4. Screenshots Required
| Device | Size | Count |
|--------|------|-------|
| iPhone 6.7" | 1290 x 2796 | 3-10 |
| iPhone 6.5" | 1242 x 2688 | 3-10 |
| iPhone 5.5" | 1242 x 2208 | 3-10 |
| iPad Pro 12.9" | 2048 x 2732 | 3-10 |

---

## 🚀 Build & Submit

### 1. Increment Version
In `pubspec.yaml`:
```yaml
version: 1.0.0+3  # Increment build number for each submission
```

### 2. Build Archive
```bash
flutter build ipa --release
```

### 3. Upload to App Store
Option A - Using Xcode:
1. Open `ios/Runner.xcworkspace`
2. **Product** → **Archive**
3. **Distribute App** → **App Store Connect**

Option B - Using Transporter:
1. Download [Transporter](https://apps.apple.com/app/transporter/id1450874784) from Mac App Store
2. Drag `.ipa` file to Transporter
3. Click **Deliver**

### 4. Submit for Review
1. Go to App Store Connect
2. Select your build
3. Complete all required information
4. **Submit for Review**

---

## ⚠️ Common Rejection Reasons to Avoid

### 1. Payments
- ✅ Your Paymob WebView is OK because it's for **physical services** (wedding vendors)
- ❌ Would be rejected if for digital goods/subscriptions

### 2. Sign In with Apple
- ✅ Already implemented - required when offering Google Sign-In

### 3. Privacy
- ✅ Add Privacy Policy URL to App Store Connect
- ✅ Add Privacy Policy link in app (Settings/Profile screen)

### 4. Permissions
- ✅ All permission descriptions are in Arabic
- ✅ Only requesting permissions that are used

### 5. UI/UX
- ✅ SafeArea used throughout app
- ⚠️ Test on iPad (enabled in project)
- ⚠️ Test in landscape mode (enabled in project)

---

## 📝 Backend Requirements for Apple Sign-In

Your backend needs to handle Apple Sign-In tokens. The app sends:

```json
{
  "provider": "apple",
  "provider_id": "000000.abc123xyz...",
  "email": "user@email.com",  // May be null after first sign-in!
  "name": "User Name",        // May be null after first sign-in!
  "identity_token": "eyJhbGc...",
  "authorization_code": "abc123...",
  "nonce": "random_nonce_string"
}
```

**Important Notes:**
- Apple only sends `email` and `name` on **first sign-in**
- Store these values in your database immediately
- Verify `identity_token` with Apple's public keys
- Use `authorization_code` to get refresh token from Apple

---

## 📞 Support Information in App

Currently configured in `help_and_support_screen.dart`:
- **Email:** Wedly@wedlyinfo.com
- **Phone:** +20 103 380 8046
- **Hours:** 9 AM - 10 PM (except Friday)

---

## ✅ Final Checklist Before Submission

- [ ] App icons replaced (all sizes)
- [ ] Launch screen customized
- [ ] Privacy Policy URL added
- [ ] Terms & Conditions URL added
- [ ] Support URL added
- [ ] Screenshots taken for all required sizes
- [ ] App description written (Arabic)
- [ ] Keywords added
- [ ] Promotional text added
- [ ] Age rating questionnaire completed
- [ ] Pricing set (Free or Paid)
- [ ] In-App Purchases configured (if any)
- [ ] TestFlight tested on real devices
- [ ] All features work on iOS
- [ ] No crashes in release mode
- [ ] Backend handles Apple Sign-In tokens

---

## 📊 Current Status

| Component | Status |
|-----------|--------|
| Info.plist | ✅ Complete |
| Entitlements | ✅ Complete |
| Bundle ID | ✅ Complete |
| Apple Sign-In Code | ✅ Complete |
| Google Sign-In Code | ✅ Complete |
| Podfile | ⏳ Requires Mac |
| App Icons | ❌ Using Flutter default |
| Launch Screen | ❌ Using Flutter default |
| Apple Developer Setup | ⏳ Requires account |
| App Store Connect | ⏳ Requires setup |

**Estimated Readiness Score: 70/100**

The remaining 30% requires:
- Mac for building (15%)
- Custom app icons (5%)
- Custom launch screen (5%)
- App Store Connect setup (5%)
