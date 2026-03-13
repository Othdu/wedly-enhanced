# Paymob SDK Integration Guide — Wedly App
> Last updated: 2026-03-13
> Backend API: `https://api.wedlyinfo.com`
> Payment endpoint: `POST /api/payments/cart`

---

## What's Already Done ✅

The following is **fully built** and waiting for the SDK:

| File | Status | What it does |
|------|--------|--------------|
| `lib/data/repositories/payment_repository.dart` | ✅ Done | Calls backend, gets `iframe_url` + `payment_token` |
| `lib/presentation/screens/user/paymob_webview_screen.dart` | ✅ Done | WebView fallback (works without SDK) |
| `lib/presentation/screens/user/payment_method_screen.dart` | ✅ Done (Visa disabled) | Payment method picker UI |
| `lib/presentation/screens/user/payment_confirmation_screen.dart` | ✅ Done | Billing form + pay button |
| `lib/core/di/injection_container.dart` | ✅ Done | `PaymentRepository` registered |
| `lib/data/services/api_constants.dart` | ✅ Done | `initiatePayment = '/api/payments/cart'` |

---

## Two Paths — Choose One

### Path A: WebView Only (No SDK needed — works TODAY)
Use the existing `PaymobWebViewScreen`. No SDK required. Paymob's hosted iframe opens in the app's WebView.

### Path B: Native SDK (When you receive it)
Replace the WebView with Paymob's native Flutter SDK for a smoother in-app card form. Follow **all steps** below.

---

## STEP 1 — Enable the Visa Button (Do This NOW)

> File: `lib/presentation/screens/user/payment_method_screen.dart`
> Lines 79–85

**Change this:**
```dart
_buildPaymentOption(
  value: 'visa',
  title: 'فيزا / بطاقة ائتمان',
  icon: Icons.credit_card,
  isDisabled: true,       // ← REMOVE THIS
  subtitle: 'قريباً',    // ← REMOVE THIS
),
```

**To this:**
```dart
_buildPaymentOption(
  value: 'visa',
  title: 'فيزا / بطاقة ائتمان',
  icon: Icons.credit_card,
),
```

---

## STEP 2 — Set Your Result Host (Do This NOW)

> File: `lib/presentation/screens/user/payment_confirmation_screen.dart`

When navigating to `PaymobWebViewScreen`, set `resultHost` to your API domain so the app knows when payment is done.

Find where `PaymobWebViewScreen` is pushed (search for `PaymobWebViewScreen(`) and make sure it looks like this:

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => PaymobWebViewScreen(
      iframeUrl: iframeUrl,         // from payment_repository response
      resultHost: 'api.wedlyinfo.com', // ← YOUR DOMAIN HERE
      onPaymentComplete: (success, message) {
        if (success) {
          // clear cart, show success, navigate home
          context.read<CartBloc>().add(const CartCleared());
          // navigate to bookings screen
        } else {
          // show error snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message ?? 'فشل الدفع'), backgroundColor: Colors.red),
          );
        }
      },
    ),
  ),
);
```

---

## STEP 3 — Wire Up the Pay Button (Visa Path)

> File: `lib/presentation/screens/user/payment_confirmation_screen.dart`

Find `_buildPayButton()` (or the confirm button logic). When `paymentMethod == 'visa'`, you must:

1. Call `PaymentRepository.initiateCartPayment(...)` with the billing fields
2. Get back `iframe_url`
3. Push `PaymobWebViewScreen`

Template:

```dart
Future<void> _handleVisaPayment() async {
  setState(() => _isLoading = true);

  try {
    final paymentRepo = getIt<PaymentRepository>();

    final nameParts = _nameController.text.trim().split(' ');
    final firstName = nameParts.first;
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '-';

    final result = await paymentRepo.initiateCartPayment(
      billingFirstName: firstName,
      billingLastName: lastName,
      billingEmail: _emailController.text.trim(),
      billingPhone: _phoneController.text.trim(),
      billingCity: _addressController.text.trim(),
      billingCountry: _billingCountryController.text.trim(), // 'EG'
      billingStreet: _billingStreetController.text.trim(),
      billingBuilding: _billingBuildingController.text.trim(),
      billingFloor: _billingFloorController.text.trim(),
      billingApartment: _billingApartmentController.text.trim(),
      billingPostalCode: _billingPostalCodeController.text.trim(),
    );

    final iframeUrl = result['iframe_url'] as String;

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymobWebViewScreen(
          iframeUrl: iframeUrl,
          resultHost: 'api.wedlyinfo.com',
          onPaymentComplete: (success, message) {
            if (success) {
              context.read<CartBloc>().add(const CartCleared());
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const UserNavigationWrapper()),
                (route) => false,
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(message ?? 'فشل الدفع'), backgroundColor: Colors.red),
              );
            }
          },
        ),
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('حدث خطأ: ${e.toString()}'), backgroundColor: Colors.red),
    );
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}
```

---

## STEP 4 — Android Setup

> File: `android/app/build.gradle`

```gradle
android {
    defaultConfig {
        minSdkVersion 21   // ← must be 21+ for WebView and most payment SDKs
    }
}
```

> File: `android/app/src/main/AndroidManifest.xml`

Add inside `<manifest>`:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

Add inside `<application>` (for cleartext if needed during dev):
```xml
android:usesCleartextTraffic="false"
```

For WebView hardware acceleration (already default, but confirm):
```xml
<activity
    android:name=".MainActivity"
    android:hardwareAccelerated="true"
    ...
```

---

## STEP 5 — iOS Setup

> File: `ios/Runner/Info.plist`

Add these keys:

```xml
<!-- Allow network requests to Paymob -->
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <false/>
    <key>NSExceptionDomains</key>
    <dict>
        <key>accept.paymob.com</key>
        <dict>
            <key>NSExceptionAllowsInsecureHTTPLoads</key>
            <false/>
            <key>NSIncludesSubdomains</key>
            <true/>
        </dict>
        <key>api.wedlyinfo.com</key>
        <dict>
            <key>NSExceptionAllowsInsecureHTTPLoads</key>
            <false/>
            <key>NSIncludesSubdomains</key>
            <true/>
        </dict>
    </dict>
</dict>
```

> File: `ios/Runner/Info.plist` — also ensure WebView is allowed:

```xml
<key>io.flutter.embedded_views_preview</key>
<true/>
```

> File: `ios/Podfile`

Make sure platform is iOS 13+:
```ruby
platform :ios, '13.0'
```

---

## STEP 6 — When You Receive the Paymob Flutter SDK

> This section is for the **native SDK path** (Path B). Skip if using WebView only.

### 6a. Add the SDK to pubspec.yaml

When Paymob gives you the SDK, it will either be:

**Option 1: pub.dev package**
```yaml
dependencies:
  paymob_payment: ^x.x.x   # use whatever version they give you
```

**Option 2: Local path (if they give you a folder)**
```yaml
dependencies:
  paymob_payment:
    path: ../paymob_payment   # adjust path to where you put it
```

**Option 3: Git repo**
```yaml
dependencies:
  paymob_payment:
    git:
      url: https://github.com/paymob/paymob-flutter.git
      ref: main
```

Then run:
```bash
flutter pub get
```

### 6b. Initialize the SDK

Ask Paymob for your **API Key** (different from the iframe key). Add initialization in `main.dart` before `runApp()`:

```dart
// In main.dart, before runApp()
import 'package:paymob_payment/paymob_payment.dart'; // adjust import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Paymob SDK
  PaymobPayment.instance.initialize(
    apiKey: 'YOUR_PAYMOB_API_KEY',        // from Paymob dashboard
    integrationID: YOUR_INTEGRATION_ID,   // card payments integration ID
    iFrameID: YOUR_IFRAME_ID,             // iframe ID from Paymob dashboard
  );

  await setupDependencyInjection();
  runApp(const WedlyApp());
}
```

### 6c. Replace WebView with SDK Call

In `payment_confirmation_screen.dart`, replace the `PaymobWebViewScreen` push with the SDK call:

```dart
// Replace this:
Navigator.push(context, MaterialPageRoute(builder: (_) => PaymobWebViewScreen(...)));

// With this (SDK version — exact API depends on what Paymob gives you):
final response = await PaymobPayment.instance.pay(
  context: context,
  currency: 'EGP',
  amountInCents: (widget.totalAmount * 100).toInt(), // SDK usually wants cents
  // OR pass the payment_token from your backend:
  paymentToken: result['payment_token'] as String,
);

if (response.success) {
  context.read<CartBloc>().add(const CartCleared());
  // navigate to success screen
} else {
  // show error
}
```

> **Note**: The exact method names (`pay`, `startPayment`, etc.) depend on Paymob's SDK. They should provide documentation. The pattern above is the most common.

### 6d. Android SDK Setup (if SDK needs it)

> File: `android/app/build.gradle`

The SDK may require adding their Maven repository:
```gradle
repositories {
    maven { url 'https://jitpack.io' }  // common for Android SDKs
}
```

If they give you a `.aar` file:
1. Create `android/app/libs/` folder
2. Put the `.aar` file in it
3. In `android/app/build.gradle`:
```gradle
dependencies {
    implementation fileTree(dir: 'libs', include: ['*.aar'])
}
```

### 6e. iOS SDK Setup (if SDK needs it)

If they give you a `.xcframework` or CocoaPod:

**CocoaPod:**
```ruby
# ios/Podfile
pod 'PaymobSDK', '~> x.x'
```
Then run:
```bash
cd ios && pod install
```

**Manual framework:**
1. Drag `.xcframework` into Xcode under `Runner/Frameworks`
2. In Xcode: Target → General → Frameworks, Libraries, and Embedded Content → set to "Embed & Sign"

---

## STEP 7 — Backend Response Requirements

Make sure your backend `POST /api/payments/cart` returns exactly this shape:

```json
{
  "data": {
    "payment_intent_id": "string",
    "paymob_order_id": "string",
    "amount_cents": 150000,
    "currency": "EGP",
    "payment_token": "string (JWT from Paymob)",
    "iframe_url": "https://accept.paymob.com/api/acceptance/iframes/YOUR_IFRAME_ID?payment_token=TOKEN"
  }
}
```

If the backend changes the shape, update `payment_repository.dart` lines 41–49.

---

## STEP 8 — Test Checklist

Before going live, test these scenarios on both Android and iOS:

- [ ] Visa payment — success flow → cart cleared, navigates home
- [ ] Visa payment — card declined → error shown, stays on payment screen
- [ ] Visa payment — user presses back → cancel dialog shown
- [ ] Visa payment — network error during `initiateCartPayment` → error snackbar
- [ ] Cash payment — still works after changes
- [ ] App backgrounded during payment → resumes correctly
- [ ] Billing form validation — empty fields blocked
- [ ] Arabic text displayed correctly in WebView/SDK (RTL)

### Paymob Test Cards (for development)

| Card Number | Expiry | CVV | Result |
|-------------|--------|-----|--------|
| 4987654321098769 | any future | 123 | Success |
| 4111111111111111 | any future | 123 | Declined |

> Get official test cards from your Paymob dashboard → Developer → Test Cards

---

## STEP 9 — Go Live Checklist

- [ ] Switch Paymob from **test mode** to **live mode** in dashboard
- [ ] Replace test API key with live API key
- [ ] Replace test integration ID with live integration ID
- [ ] Replace test iframe ID with live iframe ID
- [ ] Confirm backend webhook at `/webhooks/paymob` is verified with HMAC
- [ ] Test one real transaction with a real card
- [ ] Enable Visa option in `payment_method_screen.dart` (Step 1)

---

## File Map — Quick Reference

```
lib/
├── data/
│   ├── repositories/
│   │   └── payment_repository.dart          ← API call to backend
│   └── services/
│       └── api_constants.dart               ← endpoint: /api/payments/cart
├── presentation/
│   └── screens/user/
│       ├── payment_method_screen.dart        ← Step 1: enable Visa here
│       ├── payment_confirmation_screen.dart  ← Step 3: wire pay button here
│       └── paymob_webview_screen.dart        ← WebView fallback (already done)
└── core/di/
    └── injection_container.dart             ← PaymentRepository registered
```

---

## Questions to Ask Paymob When You Get the SDK

1. Is this a Flutter pub.dev package, a git repo, or a local `.aar`/`.xcframework`?
2. What is my **API Key** (for SDK initialization)?
3. What is my **Integration ID** for card payments?
4. What is my **iFrame ID**?
5. Do I need to initialize the SDK or just pass the `payment_token` from my backend?
6. What does the response object look like on success/failure?
7. Do I need separate integration IDs for Android and iOS?
8. What is the minimum supported Android SDK version and iOS version?
