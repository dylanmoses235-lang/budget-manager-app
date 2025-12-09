# 📱 START HERE - Build on Your iPhone

## 🎯 Quick Answer: How Do I Build This?

### The Absolute Fastest Way:

```bash
# 1. Open Terminal on your Mac
cd ~/Desktop

# 2. Clone this repo (if you haven't already)
git clone https://github.com/dylanmoses235-lang/budget-manager-app.git
cd budget-manager-app

# 3. Run the magic script
./build_iphone.sh
```

**That's it!** ✨ The script does everything automatically and guides you through each step.

---

## 📚 Which Guide Should I Read?

### 🚀 I want the FASTEST way
**Read:** `QUICK_START_IPHONE.md` (5 min)  
**Then run:** `./build_iphone.sh`

### 📖 I want to understand everything
**Read:** `BUILD_ON_MAC.md` (30 min)  
**Then try:** Manual commands or `./build_iphone.sh`

### 🔧 Something is broken
**Read:** `TROUBLESHOOTING_IPHONE.md`  
**Find:** Your exact error and solution

### 📊 I want an overview
**Read:** `IPHONE_BUILD_SUMMARY.md`  
**Get:** High-level view of all tools

---

## ⚡ One-Command Install

If you already have Flutter and Xcode installed:

```bash
cd ~/Desktop && \
git clone https://github.com/dylanmoses235-lang/budget-manager-app.git && \
cd budget-manager-app && \
./build_iphone.sh
```

Copy-paste this into Terminal → Press Enter → Follow prompts → Done!

---

## 🎓 Complete Learning Path

### Step 1: Prerequisites (One-Time, ~30-45 min)
- Install Xcode from App Store (free)
- Install Flutter: https://docs.flutter.dev/get-started/install/macos
- Enable Developer Mode on iPhone
- Connect iPhone to Mac

### Step 2: First Build (~10 min)
```bash
./build_iphone.sh
```
Follow the prompts, configure code signing in Xcode, trust certificate on iPhone.

### Step 3: Use Your App! 🎉
Open Budget Manager on your iPhone and start tracking your finances!

### Step 4: Subsequent Builds (~2 min)
```bash
./quick_rebuild.sh
```
Use this every time you make changes.

---

## 📁 File Guide

| File | Purpose | When to Use |
|------|---------|-------------|
| **START_HERE_IPHONE.md** | You are here! | First visit |
| **build_iphone.sh** | Automated build | First time + full builds |
| **quick_rebuild.sh** | Fast rebuild | After code changes |
| **QUICK_START_IPHONE.md** | 5-min guide | Want speed |
| **BUILD_ON_MAC.md** | Complete manual | Want details |
| **TROUBLESHOOTING_IPHONE.md** | Fix issues | Something broke |
| **IPHONE_BUILD_SUMMARY.md** | Overview | Want summary |
| **SETUP_IPHONE.md** | Original guide | Reference |

---

## ✅ Pre-Flight Checklist

Before building, make sure you have:

### On Your Mac:
- [ ] macOS 10.14 or later
- [ ] Xcode installed (App Store, free)
- [ ] Flutter SDK installed
- [ ] Command line tools: `xcode-select --install`
- [ ] This project cloned/downloaded

### On Your iPhone:
- [ ] iOS 13 or later
- [ ] Connected to Mac via USB cable
- [ ] Unlocked
- [ ] "Trust Computer" tapped
- [ ] Developer Mode enabled (iOS 16+)

### In Xcode:
- [ ] Apple ID added to Xcode
- [ ] Will be configured by script (or manually)

All checked? Run `./build_iphone.sh`

---

## 🎯 What You'll Get

**Budget Manager** - A fully-featured iOS app to manage your finances:

### Features:
- 💰 **Account Tracking**: Cash App, US Bank, and more
- 📅 **Bill Management**: Track due dates and amounts
- 💵 **Paycheck Calculator**: Automatic payment forecasting
- 📊 **Budget Forecasting**: Plan ahead with smart calculations
- 💾 **Backup/Restore**: Export and import your data
- 🌙 **Dark Mode**: System-adaptive theme
- 📱 **Native iOS**: Beautiful, fast, native performance

### Pre-loaded Data:
Your app comes with realistic sample data:
- Multiple accounts (Cash App, US Bank)
- Bills (Electric, Internet, Phone)
- Paycheck information
- Transaction history

---

## ⏱️ Time Investment

| Activity | First Time | Subsequent |
|----------|-----------|------------|
| **Install Xcode** | 30-45 min | - |
| **Install Flutter** | 5-10 min | - |
| **Setup iPhone** | 5 min | - |
| **Build App** | 10 min | 2 min |
| **Trust Certificate** | 30 sec | - |
| **Total** | **~1 hour** | **~2 min** |

After first setup, rebuilding takes just 2 minutes!

---

## 🚀 Quick Start Commands

### First Build (Automated)
```bash
cd ~/Desktop/budget-manager-app
./build_iphone.sh
```

### Quick Rebuild (After Changes)
```bash
cd ~/Desktop/budget-manager-app
./quick_rebuild.sh
```

### With Hot Reload (During Development)
```bash
cd ~/Desktop/budget-manager-app
flutter run
# Press 'r' after making changes for instant reload!
```

### Full Clean Rebuild (If Issues)
```bash
cd ~/Desktop/budget-manager-app
flutter clean
flutter pub get
./build_iphone.sh
```

---

## 🐛 Quick Troubleshooting

### iPhone not detected?
```bash
flutter devices
# Should show your iPhone
# If not: unplug → unlock iPhone → replug
```

### Code signing error?
```bash
open ios/Runner.xcworkspace
# In Xcode: Signing & Capabilities → Select your Apple ID
```

### App won't open?
iPhone: Settings → General → VPN & Device Management → Trust your Apple ID

### App crashes?
```bash
flutter clean
flutter pub get
flutter run -v
# Watch Terminal for error messages
```

### More help?
See `TROUBLESHOOTING_IPHONE.md` for every possible issue and solution.

---

## 💡 Pro Tips

### 1. Use Scripts for Convenience
- First time: `./build_iphone.sh` (guided, automated)
- Every other time: `./quick_rebuild.sh` (fast, no prompts)

### 2. Hot Reload for Speed
```bash
flutter run
# Make changes → Press 'r' → See results in 1 second!
```

### 3. Watch Logs
Terminal shows all app logs and errors in real-time. Very helpful for debugging!

### 4. Free Apple ID Limitation
Apps expire after 7 days. Just run `./quick_rebuild.sh` to reinstall (2 min).

### 5. Keep Updated
```bash
git pull origin main
flutter pub get
./quick_rebuild.sh
```

---

## 🎓 Resources

### Official Documentation:
- **Flutter**: https://docs.flutter.dev/
- **iOS Deployment**: https://docs.flutter.dev/deployment/ios
- **Xcode**: https://developer.apple.com/xcode/

### Community:
- **Flutter Discord**: https://discord.gg/flutter
- **Stack Overflow**: Tag with `flutter` and `ios`
- **GitHub Issues**: https://github.com/flutter/flutter/issues

### In This Repo:
- All the `.md` files in this directory!
- Scripts: `build_iphone.sh`, `quick_rebuild.sh`

---

## 🎯 Your Path Forward

```
1. Read QUICK_START_IPHONE.md (5 min)
   ↓
2. Run ./build_iphone.sh
   ↓
3. Configure code signing in Xcode
   ↓
4. Trust certificate on iPhone
   ↓
5. App works! 🎉
   ↓
6. Make changes to code
   ↓
7. Run ./quick_rebuild.sh
   ↓
8. Repeat steps 6-7 as needed
```

---

## 🎉 Ready to Start?

### Absolute Minimum:
```bash
cd ~/Desktop/budget-manager-app
./build_iphone.sh
```

### Want to Read First?
```bash
# Quick guide (5 min)
cat QUICK_START_IPHONE.md

# Or comprehensive guide (30 min)
cat BUILD_ON_MAC.md
```

### Already Had Issues?
```bash
# Troubleshooting guide
cat TROUBLESHOOTING_IPHONE.md
```

---

## 📞 Need Help?

1. **Check docs**: Read the relevant `.md` file
2. **Check Flutter**: `flutter doctor -v`
3. **Check logs**: Run with `-v` flag for verbose output
4. **Google it**: Most issues are common and well-documented
5. **Ask community**: Flutter Discord or Stack Overflow

---

## ✅ Success Indicators

You'll know it worked when:
- ✅ Terminal says "Build succeeded"
- ✅ App appears on your iPhone home screen
- ✅ App opens without crashing
- ✅ You can see your accounts and bills
- ✅ You can navigate between screens
- ✅ Everything just works!

---

## 🎊 What's Next?

After successful build:
1. **Explore the app**: Check out all features
2. **Add real data**: Input your actual accounts and bills
3. **Customize**: Modify the code to fit your needs
4. **Share**: Show off your budgeting app!

---

**Ready? Let's build!** 🚀

```bash
./build_iphone.sh
```

---

*This guide is your starting point. All other documentation is available for deeper dives into specific topics.*

**Good luck, and enjoy your Budget Manager app! 💰📱✨**

---

## 📊 Quick Reference

```bash
# Complete first-time setup
./build_iphone.sh

# Quick rebuild after changes  
./quick_rebuild.sh

# Development with hot reload
flutter run

# Check setup status
flutter doctor -v

# List connected devices
flutter devices

# Clean and rebuild
flutter clean && flutter pub get && flutter run

# View help
./build_iphone.sh --help   # (shows usage)
flutter run --help          # (shows flutter options)
```

---

**Current Version**: 1.0.0  
**Bundle ID**: com.dylanmoses.budgetManager  
**Min iOS**: 13.0  
**Last Updated**: December 9, 2025

---

**You've got this! 💪**
