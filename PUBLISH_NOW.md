# Publishing Wedly — Current Version (Cash Only)
> Version: 1.0.0+6 | Date: 2026-03-13
> Package (Android): `com.wedlyapp.services`
> Bundle ID (iOS): `com.wedly.wedding`
> Payment: Cash only (Visa disabled until SDK arrives)

---

## Before You Start — Build the App

### Android (you can do this on Windows RIGHT NOW)

```bash
flutter clean
flutter pub get
flutter build appbundle --release
```

Output file → `build\app\outputs\bundle\release\app-release.aab`

> Your keystore is already set up at `C:\Users\mohmu\upload-keystore.jks` ✅

---

### iOS (requires a Mac)

```bash
flutter clean
flutter pub get
flutter build ipa --release
```

Output file → `build\ios\ipa\wedly.ipa`

> If you don't have a Mac, use a Mac friend, a rented Mac online (MacinCloud ~$1/hr), or Codemagic CI/CD (free tier).

---

## ── ANDROID — Google Play Store ──

### Step 1 — Create App (one time only)
1. Go to [play.google.com/console](https://play.google.com/console)
2. **Create app** → App name: `ويدلي` → Language: Arabic → Free → App (not game)
3. Accept policies

### Step 2 — Fill App Content (under "Grow users" → "App content")

| Section | What to do |
|---------|-----------|
| Privacy Policy | Paste a public Google Doc URL of your privacy policy |
| Data safety | See table below |
| Ads | "This app does not contain ads" |
| Content ratings | Complete questionnaire (no violence, no gambling, 18+) |
| Target audience | 18+ |

**Data Safety answers:**

| Data type | Collected | Shared | Purpose |
|-----------|-----------|--------|---------|
| Name | Yes | No | Account management |
| Email | Yes | No | Account management |
| Phone number | Yes | No | Account management |
| Location (approx) | Yes | No | Show nearby providers |
| Photos/videos | Yes | No | Profile and service images |

Encryption: Yes | Users can delete data: Yes

### Step 3 — Store Listing (under "Grow users" → "Main store listing")

| Field | Value |
|-------|-------|
| App name | ويدلي |
| Short description | منصة شاملة لخدمات الزفاف - اكتشف وأحجز أفضل مقدمي الخدمات |
| Full description | Copy from `PRODUCTION_DEPLOYMENT_CHECKLIST.md` (Arabic section) |
| Category | Lifestyle |
| Email | wedly@wedlyinfo.com |

**Assets you must upload:**
- App icon: **512×512 PNG** (no transparency)
- Feature graphic: **1024×500 PNG**
- Screenshots: **minimum 2**, recommended 4–8 (phone screenshots)

> To get screenshots: run `flutter run --release` on a device, then take screenshots of: Home, Service Details, Booking/Cart, Profile

### Step 4 — Upload the Build

1. **Release** → **Testing** → **Internal testing** → "Create new release"
2. Upload: `build\app\outputs\bundle\release\app-release.aab`
3. Release name: `1.0.0 - الإصدار الأول`
4. Release notes:
```
النسخة الأولى من تطبيق ويدلي
• تصفح خدمات الزفاف
• حجز الخدمات
• لوحة تحكم مقدمي الخدمات
• دعم كامل للغة العربية
```
5. Save → Review → Start rollout to Internal testing

### Step 5 — Test on Your Device
1. Add your Gmail to the testers list
2. Open the testing link on your Android phone
3. Install and test the main flows
4. Fix any crashes, rebuild with incremented build number (`1.0.0+7`), re-upload

### Step 6 — Promote to Production
1. **Release** → **Production** → "Create new release"
2. Select the tested build
3. Start with **20% rollout** (safe)
4. Submit → Google reviews in **1–3 days**

---

## ── iOS — App Store ──

> ⚠️ Everything below requires a Mac and an Apple Developer account ($99/year)

### Step 1 — Apple Developer Portal (one time)
1. Go to [developer.apple.com](https://developer.apple.com/account)
2. **Identifiers** → Register new App ID
   - Bundle ID: `com.wedly.wedding`
   - Enable: **Sign In with Apple**
3. **Profiles** → Create **App Store** distribution profile for this App ID
4. Download the provisioning profile

### Step 2 — On Mac: Install deps & open Xcode

```bash
cd ios
pod install
open Runner.xcworkspace
```

In Xcode:
- Set Signing Team to your Apple Developer account
- Confirm Bundle ID is `com.wedly.wedding`
- Confirm Deployment Target is **iOS 13.0**

### Step 3 — App Icons
Generate all required sizes from your 1024×1024 master icon:
1. Go to [appicon.co](https://appicon.co)
2. Upload your 1024×1024 icon
3. Download and replace all files in `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

### Step 4 — Build Archive (on Mac)

```bash
flutter build ipa --release
```

Or in Xcode: **Product** → **Archive** → **Distribute App** → **App Store Connect**

### Step 5 — App Store Connect Setup
1. Go to [appstoreconnect.apple.com](https://appstoreconnect.apple.com)
2. **My Apps** → **+** → **New App**
   - Platform: iOS
   - Name: ويدلي
   - Primary Language: Arabic
   - Bundle ID: `com.wedly.wedding`
   - SKU: `wedly-ios-001`

### Step 6 — Fill In App Info

| Field | Value |
|-------|-------|
| Category | Lifestyle |
| Privacy Policy URL | Your hosted privacy policy URL |
| Support URL | `https://wedlyinfo.com` or support page |
| Age Rating | Complete questionnaire (17+) |

**Screenshots required (minimum):**
| Device | Resolution |
|--------|-----------|
| iPhone 6.7" (required) | 1290 × 2796 |
| iPhone 6.5" (required) | 1242 × 2688 |
| iPad Pro 12.9" (required if iPad enabled) | 2048 × 2732 |

> Run app in iPhone simulator at these sizes in Xcode → take screenshots

### Step 7 — Upload & Submit
1. Upload IPA via Xcode or [Transporter app](https://apps.apple.com/app/transporter/id1450874784)
2. In App Store Connect, select the uploaded build
3. Fill all required fields
4. **Submit for Review**
5. Apple reviews in **1–3 days** (can be up to 7)

---

## ── Telling Reviewers About Payment ──

Both stores may ask about payment. Here's what to say:

**Google Play (release notes / reviewer notes):**
> The app allows users to browse and book wedding services in Egypt. Payment is currently cash-only (paid to the service provider at the time of service). Online card payment is under development and will be added in a future update.

**Apple App Store (review notes):**
> This app connects users with wedding service providers in Egypt. Payment is handled directly between the user and provider (cash on delivery). No in-app purchases or digital goods are sold. Online payment integration is planned for a future version.

> This is important — it removes any concern from reviewers about payment flows.

---

## ── Version Bump Before Each Upload ──

Every time you upload a new build, increment the build number in [pubspec.yaml](pubspec.yaml):

```yaml
# Current
version: 1.0.0+6

# Next upload (bug fix or same release)
version: 1.0.0+7

# When you activate Paymob later
version: 1.1.0+8
```

Then rebuild:
```bash
flutter clean && flutter pub get
flutter build appbundle --release   # Android
flutter build ipa --release          # iOS (on Mac)
```

---

## ── After Paymob SDK Arrives ──

When payment is ready:
1. Follow `PAYMOB_INTEGRATION_GUIDE.md` (Steps 1–5 to activate Visa)
2. Bump version to `1.1.0+8`
3. Rebuild both platforms
4. Upload as a new release to both stores
5. In release notes: "إضافة الدفع الإلكتروني عبر فيزا / ماستركارد"

---

## ── Status Summary ──

| Task | Android | iOS |
|------|---------|-----|
| Build command ready | ✅ | ✅ (needs Mac) |
| Signing configured | ✅ keystore exists | ⏳ needs Xcode signing |
| App icons | ⚠️ need 512×512 | ⚠️ need all sizes |
| Screenshots | ⚠️ take them | ⚠️ take them |
| Store listing text | ✅ in PRODUCTION_DEPLOYMENT_CHECKLIST.md | ✅ same text |
| Payment note for reviewers | ✅ above | ✅ above |
| Payment (cash) | ✅ works | ✅ works |
| Payment (Visa) | ⏳ activate when SDK arrives | ⏳ activate when SDK arrives |
