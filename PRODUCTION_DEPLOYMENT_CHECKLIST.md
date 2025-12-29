# Wedly Production Deployment Checklist

**Date**: December 22, 2024
**Version**: 1.0.0+2
**Package Name**: com.wedlyapp.services
**Status**: Ready for Deployment ✅

---

## ✅ Pre-Deployment Verification (COMPLETED)

- [x] **Keystore file exists**: `C:\Users\mohmu\upload-keystore.jks`
- [x] **key.properties configured**: Properly set with credentials
- [x] **Package name set**: `com.wedlyapp.services`
- [x] **Version number**: `1.0.0+2` in pubspec.yaml
- [x] **Signing configuration**: Working in build.gradle.kts
- [x] **App bundle built**: `build\app\outputs\bundle\release\app-release.aab` (47.1MB)
- [x] **Privacy Policy prepared**: PRIVACY_POLICY.md exists
- [x] **Permissions declared**: Camera, Location, Storage in AndroidManifest.xml
- [x] **App name**: "Wedly" configured

---

## 📱 Required Store Listing Assets

### 1. App Icon (512x512 PNG)
**Status**: ⚠️ NEEDED

**Requirements**:
- Dimensions: 512 x 512 pixels
- Format: 32-bit PNG with alpha channel
- Max file size: 1024 KB
- Must be high-resolution version of your app icon

**How to create**:
1. Export your current app icon at 512x512
2. Or use a design tool (Canva, Figma, Photoshop)
3. Design should include wedding-related imagery (rings, hearts, etc.)
4. Use your brand colors

**Current icon location**: `android/app/src/main/res/mipmap-*/ic_launcher.png`
- You need to export the highest quality version at 512x512

---

### 2. Feature Graphic (1024x500 PNG)
**Status**: ⚠️ NEEDED

**Requirements**:
- Dimensions: 1024 x 500 pixels
- Format: 32-bit PNG or 24-bit JPEG
- Max file size: 1024 KB
- Showcases your app's main features

**Design suggestions**:
```
[Wedly Logo]     [Wedding Services Text]     [App Screenshots Preview]
```
- Left: Wedly logo or app icon
- Center: "ويدلي - منصة خدمات الزفاف" (Wedly - Wedding Services Platform)
- Right: Mini preview of app interface
- Background: Gradient or wedding-themed imagery

---

### 3. Screenshots (Minimum 2, Recommended 4-8)
**Status**: ⚠️ NEEDED

**Requirements**:
- Minimum dimensions: 320px on shortest side
- Maximum dimensions: 3840px on longest side
- Recommended: 1080 x 1920 (portrait) or 1920 x 1080 (landscape)
- Format: PNG or JPEG

**Recommended screenshots**:
1. **Login Screen** - Shows app entry point
2. **Home Screen** - Service categories and browsing
3. **Service Details** - Individual service page
4. **Booking Flow** - Cart or booking screen
5. **Provider Dashboard** - (Optional) Provider features
6. **Search/Discovery** - Location-based services

**How to capture**:
```bash
# Run app in release mode
flutter run --release

# Take screenshots on your device/emulator
# Use device screenshot tool (Power + Volume Down on Android)
```

---

### 4. App Description (Arabic & English)
**Status**: ✅ DRAFTED BELOW

#### Short Description (80 characters max)
**Arabic**: منصة شاملة لخدمات الزفاف - اكتشف وأحجز أفضل مقدمي الخدمات
**English**: Complete wedding services marketplace - Discover & book providers

#### Full Description (4000 characters max)

**Arabic**:
```
ويدلي - منصة خدمات الزفاف الشاملة في مصر

هل تخطط لحفل زفافك؟ ويدلي هو الحل الأمثل لجميع احتياجات زفافك في مكان واحد!

🎉 ما هو ويدلي؟
ويدلي هي منصة شاملة تجمع بين عملاء الزفاف ومقدمي خدمات الزفاف المحترفين. سواء كنت تبحث عن مصور فوتوغرافي، قاعة أفراح، فنان مكياج، أو أي خدمة زفاف أخرى، ستجد كل ما تحتاجه في تطبيق واحد.

✨ المميزات الرئيسية:

📸 خدمات متنوعة:
• التصوير الفوتوغرافي والفيديو
• قاعات الأفراح والفنادق
• خدمات الطعام (كيترينج)
• الديكور والتنسيق
• فساتين الزفاف
• فنانو المكياج ومصففو الشعر
• التخطيط الكامل للزفاف
• الترفيه والموسيقى
• وأكثر من ذلك بكثير!

🔍 اكتشاف سهل:
• تصفح مئات مقدمي الخدمات
• فلتر حسب الموقع والفئة والسعر
• شاهد المحفظات والصور الحقيقية
• اقرأ تقييمات العملاء السابقين

📍 قريب منك:
• اكتشف مقدمي الخدمات القريبين من موقعك
• خدمات في جميع أنحاء مصر
• عرض المواقع على الخريطة

💰 حجز وإدارة مبسطة:
• احجز الخدمات مباشرة من التطبيق
• تتبع جميع حجوزاتك في مكان واحد
• تواصل مع مقدمي الخدمات بسهولة
• إدارة الميزانية والمدفوعات

👔 للمحترفين أيضاً:
إذا كنت مقدم خدمات زفاف، يمكنك:
• إنشاء ملف تعريف احترافي
• عرض خدماتك ومحفظتك
• إدارة الحجوزات والعملاء
• الوصول إلى آلاف العملاء المحتملين

🔒 آمن وموثوق:
• جميع مقدمي الخدمات مدققون
• دفع آمن ومضمون
• دعم فني على مدار الساعة
• حماية بيانات المستخدمين

📱 تجربة مستخدم ممتازة:
• تصميم عربي أصيل (من اليمين لليسار)
• واجهة سهلة الاستخدام
• بحث سريع وذكي
• تحديثات منتظمة

🎊 لماذا تختار ويدلي؟
✓ وفر الوقت والجهد في البحث عن مقدمي الخدمات
✓ قارن الأسعار والخدمات بسهولة
✓ شاهد تقييمات حقيقية من عملاء سابقين
✓ احجز كل شيء في مكان واحد
✓ تواصل مباشر مع المحترفين
✓ ضمان الجودة والاحترافية

انضم إلى آلاف الأزواج الذين خططوا لزفافهم بنجاح باستخدام ويدلي!

حمّل التطبيق الآن وابدأ رحلتك نحو زفاف أحلامك 💍✨

---
للدعم الفني: wedly@wedlyinfo.com
```

**English**:
```
Wedly - Your Complete Wedding Services Platform in Egypt

Planning your wedding? Wedly is the ultimate solution for all your wedding needs in one place!

🎉 What is Wedly?
Wedly is a comprehensive platform connecting couples with professional wedding service providers. Whether you're looking for a photographer, venue, makeup artist, or any other wedding service, you'll find everything you need in one app.

✨ Key Features:

📸 Diverse Services:
• Photography and videography
• Wedding venues and hotels
• Catering services
• Decoration and coordination
• Wedding dresses
• Makeup artists and hair stylists
• Complete wedding planning
• Entertainment and music
• And much more!

🔍 Easy Discovery:
• Browse hundreds of service providers
• Filter by location, category, and price
• View portfolios and real photos
• Read reviews from previous clients

📍 Near You:
• Discover service providers close to your location
• Services across Egypt
• View locations on map

💰 Simple Booking & Management:
• Book services directly from the app
• Track all your bookings in one place
• Communicate easily with providers
• Manage budget and payments

👔 For Professionals Too:
If you're a wedding service provider, you can:
• Create a professional profile
• Showcase your services and portfolio
• Manage bookings and clients
• Reach thousands of potential customers

🔒 Safe & Reliable:
• All service providers verified
• Secure and guaranteed payment
• 24/7 technical support
• User data protection

📱 Excellent User Experience:
• Authentic Arabic design (RTL)
• User-friendly interface
• Fast and smart search
• Regular updates

🎊 Why Choose Wedly?
✓ Save time and effort searching for providers
✓ Compare prices and services easily
✓ See real reviews from previous clients
✓ Book everything in one place
✓ Direct communication with professionals
✓ Quality and professionalism guaranteed

Join thousands of couples who successfully planned their weddings using Wedly!

Download the app now and start your journey to your dream wedding 💍✨

---
Technical support: wedly@wedlyinfo.com
```

---

### 5. Category Selection
**Recommended**: Lifestyle
**Alternative**: Events, Shopping

---

### 6. Content Rating
Answer questionnaire honestly:
- No violence
- No user-generated content (moderated)
- No gambling
- Target age: 13+

---

## 🚀 Google Play Console Setup Steps

### Step 1: Create App in Play Console
1. Go to: https://play.google.com/console
2. Click "Create app"
3. Fill in:
   - App name: Wedly (or ويدلي)
   - Default language: Arabic (ar)
   - App/Game: App
   - Free/Paid: Free

### Step 2: Upload Privacy Policy
1. Navigate to: **Grow users** → **App content** → **Privacy Policy**
2. Create Google Doc from `PRIVACY_POLICY.md`
3. Set sharing to "Anyone with link can view"
4. Paste URL in Play Console

**Quick Privacy Policy URL**:
- Create: https://docs.google.com/document/create
- Paste content from PRIVACY_POLICY.md
- Share → Get link → Anyone with link can view
- Copy URL → Paste in Play Console

### Step 3: Data Safety Section
Navigate to: **Grow users** → **App content** → **Data safety**

**Data Collection**:
- ✓ Does your app collect or share any of the required user data types? **YES**

**Data Types Collected**:
1. **Location** (Approximate or Precise)
   - Purpose: App functionality
   - Usage: Discover nearby wedding service providers

2. **Photos and videos**
   - Purpose: App functionality
   - Usage: Profile pictures and service images

3. **Personal info** (Name, Email address, Phone number)
   - Purpose: Account management
   - Usage: User accounts and bookings

4. **App activity** (In-app search history, App interactions)
   - Purpose: Analytics
   - Usage: Improve user experience

**Data Security**:
- ✓ Data is encrypted in transit
- ✓ Users can request data deletion
- ✓ Committed to Google Play Families Policy (if targeting children)

### Step 4: Permission Declarations
Navigate to: **Grow users** → **App content** → **Permissions**

**Camera Permission**:
- Declaration: "Users can upload profile pictures and service images. Camera permission allows taking photos directly within the app."

**Location Permission**:
- Declaration: "Helps users discover nearby wedding service providers based on geographic location."

**Storage/Media Permission**:
- Declaration: "Users can select and upload photos from device gallery for profiles and service listings."

### Step 5: Store Listing
Navigate to: **Grow users** → **Main store listing**

Fill in:
- **App name**: ويدلي (Wedly)
- **Short description**: منصة شاملة لخدمات الزفاف - اكتشف وأحجز أفضل مقدمي الخدمات
- **Full description**: (Use Arabic description from above)
- **App icon**: Upload 512x512 PNG
- **Feature graphic**: Upload 1024x500 PNG
- **Phone screenshots**: Upload 2-8 screenshots
- **App category**: Lifestyle
- **Email**: wedly@wedlyinfo.com
- **Phone** (optional): Your support phone
- **Website** (optional): If you have one

### Step 6: Content Rating
1. Navigate to: **Grow users** → **App content** → **App access**
2. Complete questionnaire
3. Receive rating (likely PEGI 3 or equivalent)

### Step 7: Target Audience
1. Navigate to: **Grow users** → **Target audience**
2. Select age groups: 18+ (wedding planning audience)

### Step 8: Upload App Bundle (Internal Testing)
1. Navigate to: **Release** → **Testing** → **Internal testing**
2. Click "Create new release"
3. Upload: `build\app\outputs\bundle\release\app-release.aab`
4. Release name: "1.0.0 - Initial Release"
5. Release notes (Arabic):
   ```
   النسخة الأولية من تطبيق ويدلي

   ✨ المميزات:
   • تصفح خدمات الزفاف المتنوعة
   • اكتشاف مقدمي الخدمات حسب الموقع
   • حجز وإدارة الخدمات
   • محفظة مقدمي الخدمات والتقييمات
   • تسجيل دخول آمن
   • دعم اللغة العربية الكامل
   ```
6. Click "Save" and "Review release"
7. Click "Start rollout to Internal testing"

### Step 9: Add Testers
1. Stay in **Internal testing** → **Testers** tab
2. Create email list with your test accounts
3. Save
4. Share testing link with testers (copy from page)

### Step 10: Test Before Production
1. Install app via internal testing link on your device
2. Test all major features:
   - Login/Signup
   - Browse services
   - View service details
   - Cart and booking flow
   - Provider features
   - Location services
   - Image upload
3. Fix any critical bugs
4. Increment version and re-upload if needed

### Step 11: Promote to Production (When Ready)
1. Navigate to: **Release** → **Production**
2. Click "Create new release"
3. Select the tested build from Internal testing
4. Add production release notes
5. Choose rollout percentage (start with 20%, then 50%, then 100%)
6. Submit for review
7. Wait for Google review (1-7 days typically)

---

## 📋 Pre-Submission Checklist

Before submitting to production:

- [ ] Privacy policy URL added and accessible
- [ ] Data safety form completed
- [ ] All permissions explained
- [ ] Store listing complete (name, descriptions, icon, screenshots)
- [ ] Content rating obtained
- [ ] Target audience set
- [ ] App bundle uploaded to internal testing
- [ ] Internal testing completed successfully
- [ ] No critical bugs found
- [ ] App tested on multiple devices/Android versions
- [ ] Release notes prepared in Arabic and English
- [ ] Support email monitored: wedly@wedlyinfo.com

---

## 🎨 How to Create Store Assets

### Method 1: Use Current App (Screenshot Method)

**For Screenshots**:
```bash
# Run app in release mode
flutter run --release

# Navigate to key screens and take screenshots
# Use Android: Power + Volume Down
# Use Emulator: Screenshot button in toolbar
```

**For App Icon (512x512)**:
1. Locate: `android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png`
2. This is likely 192x192
3. Use image editor to upscale to 512x512 (use AI upscaler or redraw)

### Method 2: Design Tools

**Canva** (Free, easy):
1. Go to: https://www.canva.com
2. Create design → Custom size
3. For icon: 512x512, For feature graphic: 1024x500
4. Search templates: "app icon", "wedding"
5. Customize with your branding
6. Download as PNG

**Figma** (Free, professional):
1. Go to: https://www.figma.com
2. Create new file
3. Design app icon and feature graphic
4. Export as PNG at correct dimensions

### Method 3: Hire on Fiverr (Budget: $5-20)
- Search: "app icon design", "play store graphics"
- Provide app name, colors, wedding theme
- Get professional designs in 1-2 days

---

## 📂 File Locations

**App Bundle**:
```
build\app\outputs\bundle\release\app-release.aab
```

**Current App Icon**:
```
android\app\src\main\res\mipmap-xxxhdpi\ic_launcher.png
```

**Privacy Policy**:
```
PRIVACY_POLICY.md
```

**This Checklist**:
```
PRODUCTION_DEPLOYMENT_CHECKLIST.md
```

---

## 🔄 Version Update Process (For Future)

When releasing updates:

1. **Update version** in `pubspec.yaml`:
   ```yaml
   # Bug fix: 1.0.0+2 → 1.0.1+3
   # New feature: 1.0.0+2 → 1.1.0+3
   # Major change: 1.0.0+2 → 2.0.0+3
   version: 1.0.1+3
   ```

2. **Build new bundle**:
   ```bash
   flutter clean
   flutter pub get
   flutter build appbundle --release
   ```

3. **Upload to Play Console**:
   - Go to appropriate track (Internal/Production)
   - Create new release
   - Upload new AAB
   - Add release notes
   - Submit

---

## 🆘 Troubleshooting

### "Version code already used"
- Increment build number in pubspec.yaml (the number after +)
- Example: `1.0.0+2` → `1.0.0+3`

### "App Bundle Too Large"
- Current size: 47.1MB (within 150MB limit) ✓
- If needed, remove unused assets or use ProGuard

### "Privacy Policy Required"
- Ensure Google Doc is publicly accessible
- Test URL in incognito window

### "Missing Permissions Explanation"
- Fill Data Safety section with justifications
- Copy from this checklist

---

## 📞 Support

**Email**: wedly@wedlyinfo.com
**Developer Account**: Your Google Play Console
**Package Name**: com.wedlyapp.services

---

## ✅ Current Status Summary

**COMPLETED**:
- ✅ App bundle built successfully (47.1MB)
- ✅ Keystore configured and secure
- ✅ Privacy policy prepared
- ✅ Permissions properly declared
- ✅ Release guide documentation
- ✅ Package name configured

**PENDING**:
- ⚠️ Create 512x512 app icon
- ⚠️ Create 1024x500 feature graphic
- ⚠️ Capture 4-8 app screenshots
- ⚠️ Set up Google Play Console app listing
- ⚠️ Upload to internal testing
- ⚠️ Test and verify
- ⚠️ Submit to production

---

**Next Step**: Create store listing assets (icon, screenshots, feature graphic) then proceed with Google Play Console setup.
