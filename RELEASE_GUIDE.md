# Wedly App - Release Guide & Configuration Reference

**Last Updated:** December 18, 2024
**Current Version:** 1.0.0+2
**Package Name:** com.wedlyapp.services

---

## Table of Contents

1. [App Configuration](#app-configuration)
2. [Release Signing Setup](#release-signing-setup)
3. [Permission Handling](#permission-handling)
4. [Build Process](#build-process)
5. [Google Play Console Setup](#google-play-console-setup)
6. [Updating the App](#updating-the-app)
7. [Important Files & Locations](#important-files--locations)
8. [Troubleshooting](#troubleshooting)

---

## App Configuration

### Package Name
- **Package Name:** `com.wedlyapp.services`
- **Location:** `android/app/build.gradle.kts` (line 19, 34)
- **MainActivity Package:** `com.wedlyapp.services`
- **Location:** `android/app/src/main/kotlin/com/wedlyapp/services/MainActivity.kt`

### Version Management
- **Location:** `pubspec.yaml` (line 19)
- **Current Version:** `version: 1.0.0+2`
- **Format:** `MAJOR.MINOR.PATCH+BUILD_NUMBER`
  - `1.0.0` = Version name (visible to users)
  - `+2` = Build number (must increment with each upload)

### App Label
- **Name:** "Wedly" (ويدلي in Arabic)
- **Location:** `android/app/src/main/AndroidManifest.xml` (line 15)

---

## Release Signing Setup

### Keystore File
- **Location:** `C:\Users\mohmu\upload-keystore.jks`
- **Password:** `wedly@@@@@` (KEEP SECURE!)
- **Alias:** `upload`

**⚠️ CRITICAL:** Backup this keystore file! Without it, you cannot update your app!

**Backup Locations:**
- [ ] USB Drive
- [ ] Cloud Storage (Google Drive, Dropbox)
- [ ] Password Manager

### Signing Configuration Files

#### 1. `android/key.properties`
```properties
storePassword=wedly@@@@@
keyPassword=wedly@@@@@
keyAlias=upload
storeFile=C:\\Users\\mohmu\\upload-keystore.jks
```

**⚠️ This file is in .gitignore - never commit it to Git!**

#### 2. `android/app/build.gradle.kts`
Contains keystore loading logic (lines 11-16) and signing configuration (lines 40-47).

**Key Sections:**
```kotlin
// Load keystore properties
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()

// Signing configurations
signingConfigs {
    create("release") {
        keyAlias = keystoreProperties["keyAlias"] as String
        keyPassword = keystoreProperties["keyPassword"] as String
        storeFile = file(keystoreProperties["storeFile"] as String)
        storePassword = keystoreProperties["storePassword"] as String
    }
}
```

---

## Permission Handling

### Permissions Declared in AndroidManifest.xml

**Location:** `android/app/src/main/AndroidManifest.xml`

```xml
<!-- Camera Permission -->
<uses-permission android:name="android.permission.CAMERA"/>

<!-- Storage Permissions -->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" android:maxSdkVersion="32" />
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>

<!-- Location Permissions -->
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION"/>
```

### Runtime Permission Helper

**Location:** `lib/core/utils/permission_helper.dart`

**Features:**
- Camera permission requests
- Storage/photos permission requests (handles Android 13+ differences)
- Location permission requests
- User-friendly dialogs in Arabic
- Settings redirect for permanently denied permissions
- Image source selection dialog (Camera vs Gallery)

**Usage Example:**
```dart
// Request camera permission
final hasPermission = await PermissionHelper.requestCameraPermission(context);

// Request storage permission
final hasPermission = await PermissionHelper.requestStoragePermission(context);

// Request location permission
final hasPermission = await PermissionHelper.requestLocationPermission(context);

// Show image source dialog
final source = await PermissionHelper.showImageSourceDialog(context);
```

### Files Using Permission Helper

1. **`lib/presentation/widgets/profile_picture_widget.dart`**
   - Requests camera/storage permission before image picking
   - Shows source selection dialog

2. **`lib/presentation/screens/provider/provider_add_service_screen.dart`**
   - Requests permissions for service image uploads
   - Shows source selection dialog

3. **`lib/presentation/screens/auth/provider_documents_screen.dart`**
   - Already had permission handling
   - Uses `permission_handler` package directly

---

## Build Process

### Build Release App Bundle

```bash
# Clean build artifacts
flutter clean

# Get dependencies
flutter pub get

# Build release bundle
flutter build appbundle --release
```

### Output Location
```
build/app/outputs/bundle/release/app-release.aab
```

### Build APK (for direct distribution)
```bash
flutter build apk --release
```

**Output:** `build/app/outputs/flutter-apk/app-release.apk`

---

## Google Play Console Setup

### Account Information
- **Developer Account:** Google Play Developer (already set up)
- **Package Name:** `com.wedlyapp.services`

### Required Setup Steps

#### 1. Privacy Policy
- **Location of local file:** `PRIVACY_POLICY.md`
- **Where to host:** Google Docs (set to "Anyone with link can view")
- **Google Play Console:** Go to **Grow users** → **App content** → **Privacy Policy**

**Quick Setup:**
1. Copy content from `PRIVACY_POLICY.md`
2. Create Google Doc
3. Share publicly
4. Paste URL in Play Console

#### 2. Data Safety / Permission Declarations

**In Play Console:** **Grow users** → **App content** → **Data safety**

**Camera Permission:**
- **Purpose:** Photo capture
- **Justification:** "Users can upload profile pictures and service images. Camera permission allows taking photos directly within the app for wedding service provider profiles and user accounts."

**Location Permission:**
- **Purpose:** Location-based features
- **Justification:** "Helps users discover nearby wedding service providers (photographers, venues, caterers, decorators) based on their geographic location."

**Storage/Media Permission:**
- **Purpose:** Photo/media access
- **Justification:** "Users can select and upload photos from device gallery for their profiles and service listings in the wedding marketplace."

#### 3. Store Listing Requirements

**Navigate to:** **Grow users** → **Main store listing**

**Required:**
- App name: ويدلي (Wedly)
- Short description (80 chars max)
- Full description (4000 chars max)
- App icon (512x512 PNG)
- Feature graphic (1024x500 PNG)
- At least 2 screenshots (min 320px on shortest side)
- App category: Lifestyle or Shopping
- Contact email: wedly@wedlyinfo.com

#### 4. Content Rating

Complete the questionnaire about app content (no violence, gambling, etc.)

#### 5. Target Audience

Select appropriate age groups (typically 13+)

#### 6. Upload Release

**Testing Track (Internal Testing):**
1. Go to **Test and release** → **Internal testing**
2. Click **Create new release**
3. Upload `app-release.aab`
4. Add release notes
5. Save and rollout

**Adding Testers:**
1. **Testing** → **Internal testing** → **Testers tab**
2. Create email list
3. Share testing link with testers

---

## Updating the App

### Version Number Rules

**ALWAYS increment build number (+1, +2, +3...)**

**Version Name Guidelines:**
- Bug fix: `1.0.0` → `1.0.1`
- New features: `1.0.0` → `1.1.0`
- Major changes: `1.0.0` → `2.0.0`

### Update Process

#### Step 1: Update Version in pubspec.yaml
```yaml
# Before
version: 1.0.0+2

# After (bug fix)
version: 1.0.1+3

# After (new feature)
version: 1.1.0+3

# After (major update)
version: 2.0.0+3
```

#### Step 2: Make Your Changes
- Fix bugs
- Add features
- Update code

#### Step 3: Build New Release
```bash
flutter clean
flutter pub get
flutter build appbundle --release
```

#### Step 4: Upload to Play Console
1. Go to appropriate track (Internal Testing, Production, etc.)
2. Create new release
3. Upload new `app-release.aab`
4. Add release notes (what's new)
5. Save and rollout

### Rollout Strategies

**Internal Testing (Instant):**
- Up to 100 testers
- No review required
- Updates available immediately

**Closed Testing (Few hours):**
- Unlimited testers
- Fast review (~hours)
- Good for beta testing

**Production (1-3 hours):**
- All users
- Standard review
- Can use staged rollout (10% → 50% → 100%)

---

## Important Files & Locations

### Configuration Files

```
android/
├── app/
│   ├── build.gradle.kts          # Package name, signing config
│   └── src/main/
│       ├── AndroidManifest.xml    # Permissions, app name
│       └── kotlin/com/wedlyapp/services/
│           └── MainActivity.kt    # Package declaration
├── key.properties                 # Keystore credentials (DO NOT COMMIT!)
└── gradle/                        # Gradle configuration

lib/
├── core/
│   ├── utils/
│   │   └── permission_helper.dart # Permission handling logic
│   └── di/
│       └── injection_container.dart # Dependency injection
├── presentation/
│   ├── widgets/
│   │   └── profile_picture_widget.dart # Uses permission helper
│   └── screens/
│       ├── provider/
│       │   └── provider_add_service_screen.dart # Uses permission helper
│       └── auth/
│           └── provider_documents_screen.dart # Permission handling
└── data/
    └── services/
        └── api_constants.dart     # API base URL

pubspec.yaml                       # Version number, dependencies
PRIVACY_POLICY.md                  # Privacy policy content
RELEASE_GUIDE.md                   # This file!
```

### Backup These Files!

**Critical (Cannot recover if lost):**
- `C:\Users\mohmu\upload-keystore.jks`
- Password: `wedly@@@@@`

**Important (Contains sensitive info):**
- `android/key.properties`

**Reference:**
- This guide (`RELEASE_GUIDE.md`)
- Privacy policy (`PRIVACY_POLICY.md`)

---

## Troubleshooting

### Build Errors

#### "Version code already used"
**Solution:** Increment build number in `pubspec.yaml`
```yaml
version: 1.0.0+3  # Increment the number after +
```

#### "Package name already exists"
**Solution:** Package name is taken by another developer. Change in:
- `android/app/build.gradle.kts` (lines 19, 34)
- `MainActivity.kt` package declaration
- Move MainActivity to new package folder

#### "Debug mode signing error"
**Solution:** Ensure `key.properties` exists and has correct values.

#### "Keystore not found"
**Solution:** Check `storeFile` path in `key.properties` uses double backslashes:
```properties
storeFile=C:\\Users\\mohmu\\upload-keystore.jks
```

### Permission Issues

#### "App doesn't request permissions"
**Files to check:**
1. `lib/core/utils/permission_helper.dart` exists
2. Import added: `import 'package:wedly/core/utils/permission_helper.dart' as permission;`
3. Permission requests called before image picker
4. `permission_handler: ^12.0.1` in `pubspec.yaml`

#### "Permission permanently denied"
**User action required:** App will show dialog → "Open Settings" button → redirects to app settings

### Google Play Console Issues

#### "Privacy policy required"
**Solution:**
1. Create Google Doc from `PRIVACY_POLICY.md`
2. Set sharing to "Anyone with link"
3. Add URL to Play Console

#### "Permission declaration required"
**Solution:** Fill out Data Safety section with justifications from this guide

#### "Manifest conflicts"
**Solution:** Package name might conflict with existing apps. Choose unique name.

---

## Quick Reference Commands

### Development
```bash
# Run app in debug mode
flutter run

# Run app in release mode
flutter run --release

# Check for issues
flutter analyze

# Format code
dart format .

# Update dependencies
flutter pub upgrade
```

### Building
```bash
# Clean build
flutter clean && flutter pub get && flutter build appbundle --release

# Build APK
flutter build apk --release

# Build with specific build number
flutter build appbundle --release --build-number=4
```

### Version Management
```bash
# Check current version
grep "version:" pubspec.yaml

# View git changes
git status

# Commit changes
git add .
git commit -m "Release v1.0.1 - Bug fixes"
```

---

## Contact & Support

**Email:** wedly@wedlyinfo.com
**Package Name:** com.wedlyapp.services
**API Base URL:** https://64.226.96.53

---

## Changelog

### Version 1.0.0+2 (December 18, 2024)
- ✅ Added runtime permission requests for camera, storage, location
- ✅ Created `PermissionHelper` utility class
- ✅ Updated `ProfilePictureWidget` with permission handling
- ✅ Updated `ProviderAddServiceScreen` with permission handling
- ✅ Fixed package name from `com.example.wedly` to `com.wedlyapp.services`
- ✅ Configured release signing with keystore
- ✅ Removed Google Maps API key requirement (not using yet)
- ✅ Created privacy policy document

### Version 1.0.0+1 (Initial)
- Initial release with mock data removed
- API integration enabled
- Basic functionality implemented

---

## Notes

- App is in Arabic (RTL layout)
- Currently using real API at `https://64.226.96.53`
- Mock data mode disabled (`_useMockData = false`)
- Firebase dependencies present but not fully configured (social auth features)
- Google Maps dependencies present but not active

---

**End of Release Guide**
