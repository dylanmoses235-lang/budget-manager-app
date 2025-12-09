# 🔧 iPhone Build Troubleshooting Guide

Complete guide to solving common iPhone build and deployment issues.

---

## 🔍 Quick Diagnosis

Run this first to see what's wrong:

```bash
cd ~/Desktop/budget_manager
flutter doctor -v
flutter devices
```

---

## ❌ Issue: "No devices found"

### Symptoms
- `flutter devices` shows no iOS devices
- iPhone not appearing in Xcode
- "Waiting for device to connect" message

### Solutions

#### Solution 1: Basic Connection Check
```bash
# Disconnect and reconnect iPhone
# Unlock your iPhone
# Tap "Trust" on the prompt
```

#### Solution 2: Check iOS Settings
1. **Enable Developer Mode**:
   - Settings → Privacy & Security → Developer Mode
   - Toggle ON
   - Restart iPhone

2. **Trust Computer**:
   - When prompted, tap "Trust"
   - Enter your iPhone passcode

#### Solution 3: Check USB Connection
- Use original Apple USB cable (3rd party cables often fail)
- Try different USB port on Mac
- Avoid USB hubs - connect directly to Mac

#### Solution 4: Restart Services
```bash
# Kill and restart iOS device daemon
killall -9 ideviced idevicefs
sudo killall usbmuxd
```

#### Solution 5: Check System Report
1. Click Apple menu → About This Mac
2. System Report → USB
3. Look for "iPhone" or "iPad" in device list
4. If not there, it's a hardware/cable issue

---

## ❌ Issue: "Code signing failed"

### Symptoms
- "No provisioning profiles found"
- "Failed to create provisioning profile"
- "Signing requires a development team"

### Solutions

#### Solution 1: Add Apple ID to Xcode
```bash
# Open Xcode
open ios/Runner.xcworkspace
```

1. Xcode → Preferences (Cmd + ,)
2. Accounts tab
3. Click + → Add Apple ID
4. Sign in with your Apple ID
5. Close Preferences

#### Solution 2: Select Team
In Xcode:
1. Select "Runner" in left sidebar (top project)
2. Go to "Signing & Capabilities" tab
3. Under "Team" dropdown, select your Apple ID (Personal Team)
4. Xcode will create provisioning profile automatically

#### Solution 3: Change Bundle Identifier
If you see "Bundle ID already in use":

```bash
# Edit the bundle ID
open ios/Runner.xcodeproj/project.pbxproj
```

Find and replace:
```
com.dylanmoses.budgetManager
```
With something unique like:
```
com.yourname.budgetmanager
```

Or in Xcode:
1. Runner → General tab
2. Change "Bundle Identifier"
3. Try: `com.yourname.budgetmanager`

#### Solution 4: Clean Provisioning Profiles
```bash
# Remove old profiles
rm -rf ~/Library/Developer/Xcode/DerivedData
rm -rf ~/Library/MobileDevice/Provisioning\ Profiles/*
```

Then rebuild:
```bash
flutter clean
flutter pub get
flutter run
```

---

## ❌ Issue: "Untrusted Developer"

### Symptoms
- App installs but won't open
- "Untrusted Enterprise Developer" message
- App icon is grayed out

### Solution
**On your iPhone:**
1. Go to **Settings**
2. **General**
3. **VPN & Device Management** (or **Profiles & Device Management**)
4. Under "Developer App" section
5. Tap on your Apple ID/email
6. Tap **Trust "[Your Apple ID]"**
7. Tap **Trust** again in popup
8. Open the app again

---

## ❌ Issue: "Developer Mode Required"

### Symptoms
- "Developer Mode disabled" message
- Can't install app even after trust
- iOS 16+ requirement

### Solution
**On iPhone (iOS 16+):**
1. **Settings** → **Privacy & Security**
2. Scroll to **Developer Mode**
3. Toggle **ON**
4. Enter passcode
5. Tap **Restart**
6. After restart, tap **Turn On** in confirmation dialog
7. Enter passcode again

**Note**: This setting is only available on iOS 16+. If you don't see it, your iOS version doesn't need it.

---

## ❌ Issue: Build Fails with Errors

### Symptom 1: "CocoaPods not installed"
```bash
# Install CocoaPods
sudo gem install cocoapods

# Or with Homebrew
brew install cocoapods
```

### Symptom 2: "Pod install failed"
```bash
# Clean pods and reinstall
cd ios
rm -rf Pods
rm Podfile.lock
pod install --repo-update
cd ..

flutter clean
flutter pub get
flutter run
```

### Symptom 3: "Version solving failed"
```bash
# Update dependencies
flutter pub upgrade

# If still fails, check pubspec.yaml
flutter pub get --verbose
```

### Symptom 4: "Xcode build failed"
```bash
# Clean everything
flutter clean
rm -rf ios/Pods ios/Podfile.lock
rm -rf ~/Library/Developer/Xcode/DerivedData

# Rebuild
flutter pub get
cd ios && pod install && cd ..
flutter run
```

### Symptom 5: "Swift version error"
```bash
# Open Xcode
open ios/Runner.xcworkspace

# In Xcode:
# 1. Select Runner in left sidebar
# 2. Build Settings tab
# 3. Search for "Swift"
# 4. Set Swift Language Version to 5.0
```

---

## ❌ Issue: App Crashes or White Screen

### Symptoms
- App installs but crashes on launch
- White screen then closes
- App worked before, broken after force-close

### Solution 1: Check Logs
```bash
# Run with verbose logging
flutter run -v

# Watch for errors in Terminal output
# Look for lines starting with:
# "🚀 Starting BudgetService initialization..."
# "⚠️ Corruption detected..."
# "❌ Error:"
```

### Solution 2: Delete and Reinstall
```bash
# Delete app from iPhone (long press icon → Remove App)

# Clean build
flutter clean
flutter pub get

# Rebuild
flutter run

# Watch Terminal for error messages
```

### Solution 3: Check Xcode Console
```bash
# Open Xcode
open ios/Runner.xcworkspace

# In Xcode:
# 1. Select your iPhone from device dropdown
# 2. Click Run (▶️)
# 3. Open "Debug Area" (Cmd + Shift + Y)
# 4. Watch console output for errors
```

### Solution 4: Database Corruption
The app has automatic corruption recovery, but if it fails:

```bash
# Delete app from iPhone completely

# In Terminal:
flutter clean
flutter pub get
flutter run

# The app will create a fresh database
```

---

## ❌ Issue: "Provisioning profile expired"

### Symptoms
- App was working, now won't open
- "Provisioning profile has expired"
- After 7 days with free Apple ID

### Solution
**With Free Apple ID** (expires every 7 days):
```bash
# Reconnect iPhone
# Reinstall app (takes 2-3 minutes)
./quick_rebuild.sh

# Or manually:
flutter run
```

**Permanent Solution**:
- Get paid Apple Developer account ($99/year)
- Apps stay valid for 1 year instead of 7 days

---

## ❌ Issue: "Can't find Xcode"

### Symptoms
- "Unable to locate Xcode"
- "xcodebuild not found"
- Flutter doctor shows Xcode missing

### Solutions

#### Solution 1: Install Xcode
1. Open **App Store**
2. Search "Xcode"
3. Install (free, but ~7GB download)

#### Solution 2: Set Xcode Path
```bash
# Find Xcode location
ls /Applications | grep Xcode

# Set the path
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer

# Accept license
sudo xcodebuild -license accept

# Run first launch
sudo xcodebuild -runFirstLaunch

# Verify
xcode-select -p
# Should show: /Applications/Xcode.app/Contents/Developer
```

#### Solution 3: Install Command Line Tools
```bash
xcode-select --install
```

---

## ❌ Issue: Slow Build Times

### Solutions

#### Solution 1: Use Release Mode
```bash
# Debug mode is slower but has hot reload
flutter run

# Release mode is much faster
flutter run --release
```

#### Solution 2: Skip Pub Get
```bash
# If dependencies haven't changed
flutter run --no-pub
```

#### Solution 3: Clean Old Builds
```bash
# Clean derived data (frees space and can speed up builds)
rm -rf ~/Library/Developer/Xcode/DerivedData

# Clean Flutter cache
flutter clean
```

---

## ❌ Issue: "Module not found"

### Symptoms
- "Module 'xxx' not found"
- Import errors during build
- Missing package errors

### Solution
```bash
# Clean everything
flutter clean
rm -rf ios/Pods
rm ios/Podfile.lock

# Reinstall
flutter pub get
cd ios
pod install --repo-update
cd ..

# Rebuild
flutter run
```

---

## ❌ Issue: Can't Update App

### Symptom: New version won't install over old one

### Solution
```bash
# Delete old version from iPhone

# Clean build
flutter clean

# Reinstall with new version
flutter run --release
```

---

## 🔍 Advanced Diagnostics

### Check Flutter Setup
```bash
flutter doctor -v
```

All these should have ✓:
- Flutter (Channel stable)
- Xcode - develop for iOS
- iOS toolchain

### Check Xcode Setup
```bash
# Check Xcode path
xcode-select -p

# Check Xcode version
xcodebuild -version

# Check available simulators
xcrun simctl list devices
```

### Check iOS Device Setup
```bash
# List connected devices
flutter devices

# Get device details
idevice_id -l
ideviceinfo
```

### View Detailed Logs
```bash
# Run with maximum verbosity
flutter run -v

# Or even more detail
flutter run -vv
```

---

## 🧹 Nuclear Option: Complete Clean

If nothing else works, start completely fresh:

```bash
# 1. Delete app from iPhone

# 2. Clean Flutter
flutter clean
flutter pub cache repair

# 3. Clean iOS build files
rm -rf ios/Pods
rm ios/Podfile.lock
rm -rf ios/build

# 4. Clean Xcode derived data
rm -rf ~/Library/Developer/Xcode/DerivedData

# 5. Clean provisioning profiles
rm -rf ~/Library/MobileDevice/Provisioning\ Profiles/*

# 6. Reinstall dependencies
flutter pub get
cd ios && pod install --repo-update && cd ..

# 7. Open Xcode and reconfigure signing
open ios/Runner.xcworkspace
# Configure Team in Signing & Capabilities

# 8. Build fresh
flutter run --release
```

---

## 📱 Multiple iPhones

### Installing on multiple devices
```bash
# List all connected devices
flutter devices

# Install on specific device
flutter run -d <device-id>

# Install on all connected iOS devices
flutter run -d all-ios
```

---

## 🆘 Still Not Working?

### Collect Debug Information

```bash
# Run these and save output:
flutter doctor -v > flutter_doctor.txt
flutter devices > devices.txt
flutter run -v > build_log.txt 2>&1
```

### Check System Requirements
- **macOS**: 10.14 (Mojave) or later
- **Xcode**: 12.0 or later
- **iOS**: 13.0 or later
- **Flutter**: 3.0 or later
- **Free disk space**: At least 10GB

### Common Causes Checklist
- [ ] iPhone is unlocked
- [ ] Computer is trusted on iPhone
- [ ] Developer Mode is enabled (iOS 16+)
- [ ] Apple ID is added to Xcode
- [ ] Team is selected in Signing & Capabilities
- [ ] Developer certificate is trusted on iPhone
- [ ] Using genuine Apple USB cable
- [ ] Plugged directly into Mac (not through hub)
- [ ] Xcode command line tools installed
- [ ] Sufficient disk space available

---

## 📞 Getting Help

### Official Resources
- **Flutter Issues**: https://github.com/flutter/flutter/issues
- **Flutter Discord**: https://discord.gg/flutter
- **Stack Overflow**: Tag with `flutter` and `ios`

### When Asking for Help
Include:
1. Error message (exact text)
2. `flutter doctor -v` output
3. iOS version on iPhone
4. macOS version
5. Xcode version
6. What you've already tried

---

## ✅ Prevention Tips

### Keep Everything Updated
```bash
# Update Flutter
flutter upgrade

# Update dependencies
flutter pub upgrade

# Update CocoaPods
sudo gem update cocoapods
```

### Regular Maintenance
```bash
# Weekly cleanup
flutter clean
rm -rf ~/Library/Developer/Xcode/DerivedData

# Monthly cache cleanup
flutter pub cache repair
```

### Best Practices
- ✅ Always use `flutter clean` before major rebuilds
- ✅ Use release mode for production testing
- ✅ Keep Xcode and Flutter updated
- ✅ Use genuine Apple cables
- ✅ Backup your code with git
- ✅ Test on simulators first when possible

---

**Remember**: Most issues are solved by:
1. `flutter clean`
2. Delete app from iPhone
3. Restart iPhone
4. `flutter run`

**Good luck! 🍀**
