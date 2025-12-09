# 📱 Quick Guide: Build Budget Manager on Your iPhone

## 🎯 What You Need

### On Your Mac:
- ✅ macOS (any recent version)
- ✅ Xcode (free from App Store)
- ✅ Flutter SDK (free from flutter.dev)
- ✅ This project code

### On Your iPhone:
- ✅ iOS 13 or later
- ✅ USB cable to connect to Mac
- ✅ Apple ID (the free one you already have)

---

## 🚀 FASTEST WAY - Use the Build Script

### 1️⃣ One-Time Setup (5 minutes)

```bash
# Open Terminal on your Mac
cd ~/Desktop

# If you haven't cloned the repo yet:
git clone <your-repo-url> budget_manager
cd budget_manager

# Make the build script executable
chmod +x build_iphone.sh

# Run the automated build script
./build_iphone.sh
```

The script will:
- ✅ Check if Flutter and Xcode are installed
- ✅ Clean and prepare the project
- ✅ Open Xcode for you to set up code signing
- ✅ Build and install on your iPhone
- ✅ Guide you through every step

### 2️⃣ After First Install - Quick Rebuilds

When you make code changes and want to reinstall:

```bash
# Use the quick rebuild script
./quick_rebuild.sh
```

This skips all the setup steps and just rebuilds!

---

## 📋 Manual Step-by-Step (if you prefer)

### Step 1: Install Flutter (One-Time)

```bash
# Download Flutter
cd ~/development
git clone https://github.com/flutter/flutter.git -b stable

# Add to your PATH
echo 'export PATH="$PATH:$HOME/development/flutter/bin"' >> ~/.zshrc
source ~/.zshrc

# Verify installation
flutter doctor
```

### Step 2: Install Xcode (One-Time)

1. Open **App Store** on your Mac
2. Search for "Xcode"
3. Click **Install** (it's free but large, ~7GB)
4. After install, run in Terminal:
```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
```

### Step 3: Prepare Your iPhone (One-Time)

1. **Connect** iPhone to Mac with USB cable
2. **Trust** this computer (prompt on iPhone)
3. **Enable Developer Mode**:
   - Go to **Settings** → **Privacy & Security** → **Developer Mode**
   - Toggle **ON**
   - iPhone will restart

### Step 4: Get the Project

```bash
cd ~/Desktop
git clone <your-repo-url> budget_manager
cd budget_manager
flutter pub get
```

### Step 5: Configure Code Signing

```bash
# Open Xcode
open ios/Runner.xcworkspace
```

In Xcode:
1. Click **Runner** in left sidebar
2. Go to **Signing & Capabilities** tab
3. Under **Team**, select your Apple ID
   - If not there: Xcode → Preferences → Accounts → Add Apple ID
4. Bundle ID: `com.dylanmoses.budgetManager` (already set)
5. Xcode will auto-create a provisioning profile

### Step 6: Build and Install

```bash
# Check iPhone is connected
flutter devices

# Build and install (Debug mode - with hot reload)
flutter run

# OR Build release version (optimized)
flutter run --release
```

### Step 7: Trust Developer Certificate (First Time Only)

On your iPhone:
1. Go to **Settings** → **General** → **VPN & Device Management**
2. Tap your Apple ID under **Developer App**
3. Tap **Trust**
4. Tap **Trust** again to confirm

🎉 **Done!** The app is now installed and running!

---

## 🔄 Making Changes & Reinstalling

### Quick Method (with Hot Reload)
```bash
flutter run

# Now while the app is running:
# - Make code changes
# - Press 'r' in Terminal for hot reload
# - Press 'R' for full restart
# - Press 'q' to quit
```

### Full Reinstall
```bash
# Clean everything
flutter clean

# Reinstall
flutter pub get
flutter run
```

---

## 🐛 Common Issues & Solutions

### ❌ "No devices found"
**Problem**: iPhone not detected

**Solutions**:
1. Unplug and replug USB cable
2. Unlock your iPhone
3. Tap "Trust" on the iPhone prompt
4. Check cable (use official Apple cable if possible)
5. Try different USB port

```bash
# Check if iPhone appears
flutter devices
```

### ❌ "Code signing failed"
**Problem**: No developer certificate

**Solutions**:
1. Open Xcode: `open ios/Runner.xcworkspace`
2. Go to Signing & Capabilities
3. Select your Apple ID under Team
4. If you see "Failed to create provisioning profile":
   - Change Bundle Identifier to something unique
   - Try: `com.yourname.budgetmanager`

### ❌ "Untrusted Developer"
**Problem**: Certificate not trusted on iPhone

**Solution**:
1. Settings → General → VPN & Device Management
2. Trust your Apple ID
3. Reopen the app

### ❌ "Developer Mode Required"
**Problem**: Developer Mode not enabled

**Solution**:
1. Settings → Privacy & Security → Developer Mode
2. Toggle ON
3. iPhone will restart

### ❌ App crashes or white screen
**Problem**: Database corruption or initialization error

**Solution**:
```bash
# Full clean rebuild
flutter clean
flutter pub get
flutter run

# Watch for error logs in Terminal
```

### ❌ "Version solving failed"
**Problem**: Dependency conflicts

**Solution**:
```bash
flutter pub get --verbose
flutter pub upgrade
```

---

## 🎯 Pro Tips

### 1. Use Hot Reload for Fast Development
```bash
flutter run
# Make changes to code
# Press 'r' for hot reload (almost instant!)
# Press 'R' for full restart
```

### 2. View Console Logs
While running from Terminal, you'll see all logs and print statements!

### 3. Build Release Version for Speed
```bash
flutter run --release
# Much faster performance
# But can't use hot reload
```

### 4. Install on Multiple Devices
```bash
# List all connected devices
flutter devices

# Run on specific device
flutter run -d <device-id>
```

### 5. Keep Your Code Up to Date
```bash
git pull origin main
flutter pub get
flutter run
```

---

## 📊 Your App's Current Data

The app comes pre-loaded with your accounts and bills:

### 💰 Accounts
- Cash App: $9.43 (+ $110 overdraft)
- Cash App Savings: $4.03
- US Bank Checking: -$193.81
- And more...

### 📅 Bills
- Electric (OG&E): $182.15 - Due Nov 5
- Internet (AT&T): $5.33 - Due Nov 9
- And more...

### 💵 Paycheck
- Amount: $1,311.00
- Every 14 days
- Auto-deposits to Cash App

---

## ⏱️ Time Estimates

| Task | First Time | Subsequent |
|------|-----------|------------|
| Install Flutter + Xcode | 30-60 min | - |
| Enable iPhone Dev Mode | 5 min | - |
| Configure Code Signing | 5 min | - |
| Initial Build | 5-10 min | 2-3 min |
| Trust Certificate | 1 min | - |
| **Total First Install** | **~1 hour** | **~3 min** |

---

## 🆘 Still Stuck?

### Check Flutter Setup
```bash
flutter doctor -v
```
Should show all checkmarks (✓) for iOS toolchain

### Get Detailed Build Logs
```bash
flutter run -v
```

### Clean Everything and Start Fresh
```bash
flutter clean
rm -rf ios/Pods
rm ios/Podfile.lock
flutter pub get
cd ios && pod install && cd ..
flutter run
```

---

## 📱 App Expiration (Free Apple ID)

**Important**: Apps signed with a free Apple ID expire after **7 days**.

After 7 days:
1. Connect iPhone to Mac
2. Run `./quick_rebuild.sh` or `flutter run`
3. Takes ~2-3 minutes to reinstall

**To avoid this**: Get a paid Apple Developer account ($99/year) for 1-year signing.

---

## 🎓 Learning Resources

- **Flutter Docs**: https://docs.flutter.dev/
- **iOS Deployment**: https://docs.flutter.dev/deployment/ios
- **Flutter Codelabs**: https://docs.flutter.dev/codelabs
- **Xcode Help**: https://developer.apple.com/xcode/

---

## 🎉 Success Checklist

- [ ] Flutter and Xcode installed
- [ ] iPhone Developer Mode enabled
- [ ] iPhone connected and trusted
- [ ] Code signing configured in Xcode
- [ ] App builds without errors
- [ ] Developer certificate trusted on iPhone
- [ ] App launches successfully

**Once all checked, you're ready to go! 🚀**

---

## 💻 Quick Command Reference

```bash
# Check setup
flutter doctor

# List connected devices  
flutter devices

# Install dependencies
flutter pub get

# Clean build
flutter clean

# Run in debug mode
flutter run

# Run in release mode
flutter run --release

# Build IPA file
flutter build ipa --release

# Open Xcode
open ios/Runner.xcworkspace

# Automated build
./build_iphone.sh

# Quick rebuild
./quick_rebuild.sh
```

---

**Bundle ID**: `com.dylanmoses.budgetManager`  
**Minimum iOS**: 13.0  
**App Name**: Budget Manager  
**Current Version**: 1.0.0

---

*This guide was created to make iPhone deployment as simple as possible. Happy budgeting! 💰*
