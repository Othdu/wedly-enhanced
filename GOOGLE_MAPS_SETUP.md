# Google Maps Setup Guide for Wedly App

## Overview
The Wedly app includes Google Maps integration for the "Add Service" screen where providers can select their service location. The implementation is **smart** - it will use Google Maps when an API key is configured, or show a placeholder if not.

## Current Status
- ✅ Google Maps Flutter package installed
- ✅ Location permissions configured in AndroidManifest.xml
- ✅ Smart fallback system (shows placeholder if API key missing)
- ⚠️ **Google Maps API Key NOT configured** (needs to be added)

## How to Get Google Maps API Key

### Step 1: Create a Google Cloud Project
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Click "Select a project" → "New Project"
3. Enter project name (e.g., "Wedly App")
4. Click "Create"

### Step 2: Enable Google Maps SDK
1. In your project, go to "APIs & Services" → "Library"
2. Search for "Maps SDK for Android"
3. Click on it and press "Enable"
4. Also enable "Maps SDK for iOS" if you plan to support iOS

### Step 3: Create API Key
1. Go to "APIs & Services" → "Credentials"
2. Click "+ CREATE CREDENTIALS" → "API key"
3. Copy the API key (it will look like: `AIzaSyD...`)
4. **Important**: Click "Edit API key" to restrict it

### Step 4: Restrict Your API Key (Recommended for Security)
1. Under "Application restrictions":
   - Select "Android apps"
   - Click "+ Add an item"
   - Package name: `com.example.wedly` (or your actual package name)
   - SHA-1 certificate fingerprint: Get from terminal:
     ```bash
     cd android
     ./gradlew signingReport
     ```
2. Under "API restrictions":
   - Select "Restrict key"
   - Check "Maps SDK for Android"
3. Click "Save"

## Installation Steps

### For Android (Required)

1. **Add API Key to AndroidManifest.xml**

   Open: `android/app/src/main/AndroidManifest.xml`

   Find this line (around line 50):
   ```xml
   <meta-data
       android:name="com.google.android.geo.API_KEY"
       android:value="YOUR_API_KEY_HERE"/>
   ```

   Replace `YOUR_API_KEY_HERE` with your actual API key:
   ```xml
   <meta-data
       android:name="com.google.android.geo.API_KEY"
       android:value="AIzaSyD...your-actual-key-here"/>
   ```

2. **Verify Permissions** (Already configured ✅)
   ```xml
   <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
   <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
   ```

3. **Rebuild the app**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

### For iOS (If Supporting iOS)

1. **Add API Key to AppDelegate.swift**

   Open: `ios/Runner/AppDelegate.swift`

   Add at the top:
   ```swift
   import GoogleMaps
   ```

   In the `application` function, add:
   ```swift
   GMSServices.provideAPIKey("YOUR_API_KEY_HERE")
   ```

2. **Update Info.plist**

   Open: `ios/Runner/Info.plist`

   Add location permissions:
   ```xml
   <key>NSLocationWhenInUseUsageDescription</key>
   <string>This app needs location access to show your service location on the map</string>
   <key>NSLocationAlwaysUsageDescription</key>
   <string>This app needs location access to show your service location on the map</string>
   ```

3. **Update Podfile**

   Open: `ios/Podfile`

   Uncomment this line:
   ```ruby
   platform :ios, '12.0'
   ```

4. **Install pods**
   ```bash
   cd ios
   pod install
   cd ..
   ```

## Testing Without API Key

The app is designed to work even without Google Maps API key!

**Without API Key**: Shows a placeholder with message "تكامل خرائط جوجل غير متاح"

**With API Key**: Shows interactive Google Maps with:
- Draggable map to select location
- Center pin marker
- Current location button
- "تأكيد الموقع" (Confirm Location) button
- Displays selected coordinates

## Code Structure

### Main Components

1. **Smart Map Widget** (`_buildMapWidget()`)
   - Checks `_useGoogleMaps` flag
   - Uses Google Maps if enabled
   - Falls back to placeholder if disabled

2. **Location Variables**
   ```dart
   LatLng _pickedLocation = const LatLng(30.0444, 31.2357); // Cairo default
   GoogleMapController? _mapController;
   final bool _useGoogleMaps = true;
   ```

3. **Map Features**
   - Initial location: Cairo, Egypt (30.0444, 31.2357)
   - Zoom level: 14
   - Draggable to select location
   - Tap to select location
   - Center pin shows selected location
   - Confirm button displays coordinates

### Switching Between Maps and Placeholder

To disable Google Maps (use placeholder):
```dart
final bool _useGoogleMaps = false; // Line 29 in provider_add_service_screen.dart
```

To enable Google Maps:
```dart
final bool _useGoogleMaps = true;
```

## Troubleshooting

### Issue: Map shows blank/grey screen
**Solution**: API key is not configured or restricted
1. Check if API key is added to AndroidManifest.xml
2. Verify API key has "Maps SDK for Android" enabled
3. Check if package name and SHA-1 match your app

### Issue: "Authorization failure" error
**Solution**: API key restrictions too strict
1. Go to Google Cloud Console
2. Edit your API key
3. Temporarily remove all restrictions
4. Test if it works, then add restrictions back

### Issue: App crashes when opening Add Service screen
**Solution**: API key issue or package not installed
1. Set `_useGoogleMaps = false` to use placeholder
2. Run `flutter clean && flutter pub get`
3. Check if google_maps_flutter package is installed

### Issue: Location permission denied
**Solution**: Enable location permissions
1. Go to phone Settings → Apps → Wedly
2. Enable Location permission
3. Restart the app

## Cost Considerations

Google Maps is **FREE** for:
- First $200/month of usage
- Up to ~28,000 map loads per month

Pricing after free tier:
- $7.00 per 1,000 map loads
- $5.00 per 1,000 API calls

**Tip**: Set up billing alerts in Google Cloud Console!

## Security Best Practices

1. ✅ **Restrict API Key** to your app's package name and SHA-1
2. ✅ **Don't commit** API key to public repositories
3. ✅ **Use API restrictions** (only enable Maps SDK)
4. ✅ **Monitor usage** in Google Cloud Console
5. ✅ **Set usage quotas** to prevent unexpected charges

## Alternative: Use Placeholder Only

If you don't want to set up Google Maps:
1. Set `_useGoogleMaps = false` (line 29)
2. Remove API key from AndroidManifest.xml
3. The app will work perfectly with a placeholder

You can always add Google Maps later!

## Resources

- [Google Maps Platform Documentation](https://developers.google.com/maps/documentation)
- [Flutter Google Maps Plugin](https://pub.dev/packages/google_maps_flutter)
- [Get API Key Tutorial](https://developers.google.com/maps/documentation/android-sdk/get-api-key)
- [Google Cloud Console](https://console.cloud.google.com/)

## Support

For issues or questions about Google Maps integration:
1. Check this documentation first
2. Test with `_useGoogleMaps = false` to isolate the issue
3. Verify API key is correctly configured
4. Check Google Cloud Console for error logs

---

**Last Updated**: $(date)
**Status**: Ready for API key configuration
