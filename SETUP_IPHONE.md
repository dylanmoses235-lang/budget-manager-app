# 📱 iPhone Setup Guide for Budget Manager

This guide will walk you through installing the Budget Manager app on your iPhone.

## ✅ Prerequisites

### On Your Mac
1. **Xcode** - Latest version from the App Store
2. **Flutter SDK** - Install from [flutter.dev](https://docs.flutter.dev/get-started/install/macos)
3. **Git** - Should be pre-installed on macOS

### On Your iPhone
1. **iOS 13.0 or later**
2. **USB cable** to connect to your Mac
3. **Apple ID** signed in to your device

---

## 🚀 Installation Steps

### Step 1: Clone/Download the Project

```bash
# Navigate to your preferred directory
cd ~/Desktop

# Clone the repository (or download and extract the ZIP)
git clone <your-repo-url> budget_manager
cd budget_manager
```

### Step 2: Install Flutter Dependencies

```bash
# Get all the required packages
flutter pub get
```

### Step 3: Connect Your iPhone

1. **Connect** your iPhone to your Mac using a USB cable
2. **Enable Developer Mode** on your iPhone:
   - Go to **Settings** → **Privacy & Security** → **Developer Mode**
   - Toggle it **ON**
   - Your iPhone will restart
3. **Trust your Mac** when prompted on your iPhone

### Step 4: Configure Code Signing in Xcode

```bash
# Open the iOS project in Xcode
open ios/Runner.xcworkspace
```

In Xcode:
1. Select **Runner** in the left sidebar (top item)
2. Go to the **Signing & Capabilities** tab
3. Under **Team**, select your Apple ID (Personal Team)
   - If you don't see your Apple ID, go to Xcode → Preferences → Accounts and sign in
4. The **Bundle Identifier** is already set to: `com.dylanmoses.budgetManager`
5. Xcode will automatically create a provisioning profile

### Step 5: Run on Your iPhone

**Option A: Using Flutter Command (Recommended)**

```bash
# List all connected devices
flutter devices

# Run the app on your iPhone
flutter run
```

**Option B: Using Xcode**

1. In Xcode, select your iPhone from the device dropdown (top bar)
2. Click the ▶️ **Play** button
3. Wait for the build to complete

### Step 6: Trust the Developer Certificate

**First time only:**

1. On your iPhone, go to **Settings** → **General** → **VPN & Device Management**
2. Under **Developer App**, tap on your Apple ID
3. Tap **Trust "Dylan Moses (Personal Team)"**
4. Tap **Trust** again to confirm
5. The app should now launch! 🎉

---

## 📊 Current Account Information

Your app is pre-configured with your current account data (as of Nov 1, 2025):

### Accounts
- **Cash App**: $9.43 (with $110 overdraft available)
- **Cash App Savings**: $4.03
- **Cash App Stocks**: $4.03
- **Cash App Borrow**: -$357.00 owed
- **Cash App Afterpay**: -$207.53 owed
- **Cash App Bitcoin**: $0.00
- **US Bank Checking 3883**: -$193.81
- **US Bank Savings 0588**: $0.00

### Bills
- **Electric (OG&E)**: $182.15 due Nov 5, 2025
- **Internet (AT&T)**: $5.33 due Nov 9, 2025
- **Phone (Visible)**: TBD
- **Apple Services**: TBD
- **Rent**: TBD

### Paycheck Info
- **Amount**: $1,311.00
- **Frequency**: Bi-weekly (every 14 days)
- **Next Paycheck**: Oct 29, 2025
- **Auto-deposit**: Cash App

---

## 🔧 Troubleshooting

### "No provisioning profiles found"
**Solution**: Make sure you've selected your Apple ID as the Team in Xcode's Signing & Capabilities tab.

### "Untrusted Developer" on iPhone
**Solution**: Go to Settings → General → VPN & Device Management and trust the developer certificate.

### "Developer Mode Required"
**Solution**: Enable Developer Mode in Settings → Privacy & Security → Developer Mode (requires restart).

### App crashes on startup
**Solution**: 
1. Delete the app from your iPhone
2. In Xcode, go to Product → Clean Build Folder
3. Run `flutter clean && flutter pub get` in Terminal
4. Try building again

### "Code signing failed"
**Solution**: 
1. Make sure your Apple ID is signed in to Xcode
2. The bundle identifier `com.dylanmoses.budgetManager` should be unique to your account
3. If it conflicts, you can change it in `ios/Runner.xcodeproj/project.pbxproj`

---

## 🔄 Updating the App

When you make changes to the code:

```bash
# Stop the current running app (Ctrl+C in terminal)

# Run again to see changes
flutter run

# Or for a fresh install
flutter run --release
```

---

## 📦 Building a Release Version

To create a production-ready build:

```bash
# Build the IPA file
flutter build ipa --release

# The IPA will be located at:
# build/ios/archive/Runner.xcarchive
```

You can then use Xcode Organizer to:
- Install on your device
- Archive for App Store submission (requires paid Apple Developer account)
- Export for ad-hoc distribution

---

## 📝 Notes

- **Free Apple ID Limitation**: Apps installed with a free Apple ID expire after 7 days and need to be reinstalled
- **Paid Developer Account**: With a $99/year Apple Developer account, apps stay installed for 1 year
- **TestFlight**: You can distribute to others via TestFlight if you have a paid developer account

---

## 🆘 Need Help?

- **Flutter Documentation**: https://docs.flutter.dev/
- **Xcode Help**: https://developer.apple.com/xcode/
- **iOS Deployment Guide**: https://docs.flutter.dev/deployment/ios

---

## 📱 Quick Reference

```bash
# Check Flutter installation
flutter doctor

# List connected devices
flutter devices

# Clean and rebuild
flutter clean && flutter pub get && flutter run

# Build for release
flutter build ipa --release

# Open iOS project in Xcode
open ios/Runner.xcworkspace
```

**Bundle ID**: `com.dylanmoses.budgetManager`  
**Min iOS Version**: 13.0  
**App Name**: Budget Manager

---

*Last Updated: November 1, 2025*
