# iOS Release - One Day Mac Guide

## ⏰ Time Estimate: 4-6 hours (if everything goes smoothly)

---

## 🎯 BEFORE YOU GO TO THE MAC - Prepare These

### 1. Apple Developer Account (CRITICAL)
- [ ] **Enroll at**: https://developer.apple.com/programs/enroll/
- [ ] **Cost**: $99/year (credit card required)
- [ ] **Processing time**: Can take 24-48 hours for approval
- [ ] **⚠️ START THIS NOW - Don't wait until you're on the Mac**
- [ ] Have your credentials ready: Apple ID email + password

### 2. App Store Connect Account
- [ ] Sign in at: https://appstoreconnect.apple.com
- [ ] Same Apple ID as developer account
- [ ] Verify you can log in

### 3. App Information Ready
- [ ] App Name: "Wedly" (or your preferred name)
- [ ] Bundle ID: `com.wedly.app` (or your choice - CANNOT be changed later)
- [ ] App Description (in Arabic and English)
- [ ] Keywords for App Store
- [ ] Support URL or website
- [ ] Privacy Policy URL (REQUIRED)
- [ ] App Screenshots (see requirements below)
- [ ] App Icon (1024x1024 PNG, no transparency)

### 4. Screenshots Needed (Take on Android or simulator)
For each screen size (at minimum, do iPhone 6.7" and 5.5"):
- [ ] 5-10 screenshots showing key features
- [ ] Both Arabic and English versions (if supporting both languages)

### 5. Project Files
- [ ] Bring your entire project on a USB drive
- [ ] Alternatively, push all changes to GitHub
- [ ] Have your GitHub credentials ready

### 6. Credentials to Bring
- [ ] Apple ID email and password
- [ ] Any 2FA backup codes
- [ ] GitHub credentials (if using git)
- [ ] Any API keys or certificates

---

## 📋 ON THE MAC - Step by Step

### Phase 1: Mac Setup (30-45 minutes)

#### Step 1: Install Xcode
```bash
# Option A: From App Store (RECOMMENDED - takes 1-2 hours)
# Open App Store → Search "Xcode" → Install (it's free but ~15GB)

# While Xcode downloads, continue with other steps
```

#### Step 2: Install Homebrew (Package Manager)
```bash
# Open Terminal and run:
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

#### Step 3: Install Flutter
```bash
# Download Flutter SDK
cd ~/Downloads
git clone https://github.com/flutter/flutter.git -b stable

# Add to PATH (temporary for this session)
export PATH="$PATH:$HOME/Downloads/flutter/bin"

# Verify installation
flutter doctor
```

#### Step 4: Get Your Project
```bash
# Option A: From USB
# Copy project folder to ~/Desktop/wedly-enhanced

# Option B: From GitHub
cd ~/Desktop
git clone https://github.com/Othdu/wedly-enhanced
cd wedly-enhanced
```

---

### Phase 2: Xcode Configuration (1-2 hours)

#### Step 5: Open Project in Xcode
```bash
cd ~/Desktop/wedly-enhanced
open ios/Runner.xcworkspace
```

#### Step 6: Sign In to Xcode
1. Xcode → Settings (or Preferences)
2. Click **Accounts** tab
3. Click **+** → Add Apple ID
4. Sign in with your Apple Developer account

#---------------------------------------------### Step 7: Configure Signing (MOST IMPORTANT)
1. In Xcode, select **Runner** (blue icon) in left sidebar
2. Select **Runner** target under TARGETS
3. Go to **Signing & Capabilities** tab
4. Check **"Automatically manage signing"**
5. Select your Team from dropdown
6. Change **Bundle Identifier** to your chosen ID (e.g., `com.wedly.wedding`)
7. Wait for "Signing Certificate" to appear (green checkmark)

⚠️ **Common Issues**:
- If "Failed to create provisioning profile": Your Apple Developer enrollment may not be complete
- If "No signing certificate": You need to create one (see Step 8)

#### Step 8: Create Signing Certificate (If Needed)
1. In Signing & Capabilities, click **"Manage Certificates..."**
2. Click **+** → "Apple Distribution"
3. Wait for certificate to generate
4. Close and verify signing works

---

### Phase 3: App Configuration (30 minutes)

#### Step 9: Update Bundle ID in Project
```bash
# Edit ios/Runner/Info.plist
# Find CFBundleIdentifier and ensure it matches your Bundle ID

# Or in Xcode:
# Runner → TARGETS Runner → General → Identity → Bundle Identifier
```

#### Step 10: Update App Display Name
```bash
# In Xcode:
# Runner → General → Display Name → "Wedly"
```

#### Step 11: Set App Version & Build Number
```bash
# In pubspec.yaml (back on your PC before copying):
version: 1.0.0+1

# This means Version 1.0.0, Build 1
```

#### Step 12: Add App Icon
1. Prepare 1024x1024 PNG icon (no transparency)
2. In Xcode: Open `ios/Runner/Assets.xcassets/AppIcon.appiconset`
3. Drag icon to "App Store iOS" slot
4. Xcode auto-generates all sizes

---

### Phase 4: Build & Archive (45 minutes)

#### Step 13: Select Build Scheme
1. At top of Xcode, next to "Runner":
   - Click scheme dropdown
   - Select **"Any iOS Device (arm64)"**

#### Step 14: Clean Build
```bash
# In Terminal:
cd ~/Desktop/wedly-enhanced
flutter clean
flutter pub get
cd ios
pod install
```

#### Step 15: Create Archive
1. In Xcode: **Product → Archive**
2. Wait 10-20 minutes (grab coffee ☕)
3. If successful, Archives window opens automatically

⚠️ **If Build Fails**:
```bash
# Common fixes:
flutter clean
cd ios
rm -rf Pods Podfile.lock
pod install --repo-update
```

---

### Phase 5: Upload to App Store (30 minutes)

#### Step 16: Validate Archive
1. In Archives window, select your archive
2. Click **"Validate App"**
3. Choose your signing options (auto is fine)
4. Wait for validation (5-10 minutes)
5. Fix any errors shown

#### Step 17: Upload to App Store Connect
1. Click **"Distribute App"**
2. Select **"App Store Connect"**
3. Click **Next** through dialogs (keep defaults)
4. Click **Upload**
5. Wait 10-20 minutes for upload

#### Step 18: Verify Upload
```bash
# Check at: https://appstoreconnect.apple.com
# Go to: My Apps → Wedly → TestFlight
# Your build should appear in 5-10 minutes with "Processing" status
```

---

### Phase 6: App Store Connect Setup (1-2 hours)

#### Step 19: Create App in App Store Connect
1. Go to https://appstoreconnect.apple.com
2. Click **My Apps** → **+ (plus icon)** → **New App**
3. Fill in:
   - **Platform**: iOS
   - **Name**: Wedly
   - **Primary Language**: Arabic
   - **Bundle ID**: Select your Bundle ID from dropdown
   - **SKU**: WEDLY001 (or any unique ID)
   - **User Access**: Full Access

#### Step 20: Fill App Information
Navigate to **App Information** section:
- [ ] Privacy Policy URL (REQUIRED)
- [ ] Category: Lifestyle or Shopping
- [ ] Content Rights
- [ ] Age Rating (complete questionnaire)

#### Step 21: Add App Version Info
Navigate to version section (e.g., **1.0 Prepare for Submission**):

1. **Screenshots & App Preview**:
   - Upload 5-10 screenshots per device size
   - Minimum: 6.7" display and 5.5" display

2. **Promotional Text** (optional but recommended)

3. **Description** (Arabic):
   ```
   ويدلي - سوق خدمات الأفراح الشامل

   اكتشف وأحجز أفضل خدمات الأفراح في مصر:
   • التصوير الفوتوغرافي والفيديو
   • خدمات الطعام والضيافة
   • الديكور والزينة
   • الترفيه والموسيقى
   • قاعات الأفراح والأماكن
   • خدمات التجميل والمكياج

   ميزات التطبيق:
   ✓ تصفح آلاف الخدمات المميزة
   ✓ حجز فوري وآمن
   ✓ تقييمات حقيقية من العملاء
   ✓ تواصل مباشر مع مقدمي الخدمة
   ✓ إدارة سهلة لحجوزاتك
   ```

4. **Keywords** (Arabic, comma-separated):
   ```
   أفراح,زواج,حفلات,تصوير,طعام,ديكور,قاعات,تجميل,خدمات,حجز
   ```

5. **Support URL**: Your website or support email

6. **Marketing URL** (optional)

#### Step 22: Select Build
1. In **Build** section, click **+ (Select a build)**
2. Choose the build you uploaded
3. Wait if it says "Processing" (can take 30-60 minutes)

#### Step 23: Pricing & Availability
- [ ] Set price (Free or paid)
- [ ] Select countries (Egypt, Saudi Arabia, UAE, etc.)

#### Step 24: App Privacy
1. Click **App Privacy** in left sidebar
2. Fill privacy questionnaire about data collection
3. Be honest about what data you collect

#### Step 25: Submit for Review
1. Review all sections (should have green checkmarks)
2. Click **Add for Review** (top right)
3. Click **Submit to App Store Review**

---

## 🎯 Success Checklist

At the end of your Mac session, you should have:

- [ ] ✅ Build successfully uploaded to App Store Connect
- [ ] ✅ App created in App Store Connect
- [ ] ✅ All app information filled
- [ ] ✅ Screenshots uploaded
- [ ] ✅ Privacy policy completed
- [ ] ✅ App submitted for review

**Review Time**: Usually 24-48 hours (can be up to 7 days)

---

## ⚠️ Common Issues & Solutions

### "Apple Developer Program enrollment is pending"
- **Solution**: Wait for approval email (24-48 hours). You CANNOT upload without this.

### "Failed to create provisioning profile"
- **Solution**: Verify Developer account is active and paid ($99/year)

### "Code signing error"
- **Solution**:
  1. Xcode → Settings → Accounts → Download Manual Profiles
  2. Runner → Signing → Uncheck & recheck "Automatically manage signing"

### "Build fails with Swift/Cocoapods errors"
```bash
cd ios
rm -rf Pods Podfile.lock
pod deintegrate
pod install
```

### "Archive succeeds but Upload fails"
- **Solution**: Check your network connection, Apple servers might be slow

---

## 📱 Testing Your Build

### TestFlight (Internal Testing)
After upload is processed:
1. App Store Connect → TestFlight
2. Add yourself as internal tester
3. Get TestFlight app on your iPhone
4. Install and test your build

You can do this immediately without waiting for App Store review!

---

## 🔄 What to Do After Leaving the Mac

1. **Export Certificates** (CRITICAL for future builds):
   ```bash
   # In Xcode:
   # Settings → Accounts → Select Team → Manage Certificates
   # Right-click certificate → Export
   # Save to USB drive with password
   ```

2. **Download Provisioning Profiles**:
   - Download from: https://developer.apple.com/account/resources/profiles/list
   - Keep for future builds

3. **Document Everything**:
   - Bundle ID used
   - Team ID
   - Any special configurations

---

## 💡 Pro Tips

1. **Start Early in the Day**: Don't wait until afternoon
2. **Stable Internet**: Coffee shops with good WiFi
3. **Power Adapter**: Keep Mac plugged in
4. **Take Notes**: Screenshot every step
5. **Test on iPhone**: Bring your iPhone to test TestFlight build
6. **Backup Everything**: USB drive with all exports

---

## 🆘 If You Get Stuck

1. **Flutter Doctor**: Run `flutter doctor` to check setup
2. **Xcode Logs**: Check for specific error messages
3. **Apple Documentation**: https://developer.apple.com/ios/submit/
4. **Stack Overflow**: Search your specific error message

---

## 📊 Timeline Breakdown

| Task | Time | Can Do Offline? |
|------|------|----------------|
| Install Xcode | 1-2 hours | No |
| Install Flutter | 15 min | No |
| Configure Signing | 30 min | No |
| Update App Info | 15 min | Yes |
| Build & Archive | 20 min | Yes |
| Upload Build | 20 min | No |
| App Store Connect Setup | 1-2 hours | No |
| **TOTAL** | **4-6 hours** | - |

⏰ **Plan for 6 hours to be safe!**

---

## 🎉 Success!

Once submitted, you'll receive emails from Apple about:
1. Build processing complete
2. App "In Review"
3. App status changes (Rejected/Approved)

**First submission usually takes 24-48 hours for review.**

Good luck! 🚀
