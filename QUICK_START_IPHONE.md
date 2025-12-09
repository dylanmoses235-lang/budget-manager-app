# 🚀 5-Minute iPhone Setup

Get your Budget Manager app running on your iPhone in 5 minutes!

---

## ⚡ Super Quick Method

### 1️⃣ Open Terminal on your Mac

```bash
cd ~/Desktop
git clone <your-repo-url> budget_manager
cd budget_manager
```

### 2️⃣ Run the automated build script

```bash
chmod +x build_iphone.sh
./build_iphone.sh
```

**That's it!** The script does everything automatically. Just follow the prompts.

---

## 📋 What the Script Does

1. ✅ Checks if Flutter is installed (tells you how to install if not)
2. ✅ Checks if Xcode is installed (tells you how to install if not)
3. ✅ Cleans previous builds
4. ✅ Gets all dependencies
5. ✅ Opens Xcode for you to set up code signing
6. ✅ Builds and installs on your iPhone

---

## 🎯 First Time Setup Checklist

Before running the script:

### On Your Mac:
- [ ] Install **Xcode** from App Store (free, ~7GB)
- [ ] Install **Flutter**:
  ```bash
  # Quick Flutter install
  cd ~/development
  git clone https://github.com/flutter/flutter.git -b stable
  echo 'export PATH="$PATH:$HOME/development/flutter/bin"' >> ~/.zshrc
  source ~/.zshrc
  flutter doctor
  ```

### On Your iPhone:
- [ ] Connect to Mac with USB cable
- [ ] Tap **Trust** when prompted
- [ ] Enable **Developer Mode**:
  - Settings → Privacy & Security → Developer Mode → ON
  - Restart iPhone when prompted

### In Xcode (script will open it for you):
- [ ] Click **Runner** in left sidebar
- [ ] Go to **Signing & Capabilities** tab
- [ ] Select your **Apple ID** under Team
- [ ] That's it!

---

## 🎉 After First Install

### Trust Your Developer Certificate (One Time Only)

On your iPhone:
1. Settings → General → VPN & Device Management
2. Tap your Apple ID
3. Tap "Trust"

Now open the app - it works! 🎊

---

## 🔄 Quick Rebuild (After Code Changes)

```bash
# Just run this - takes 2 minutes!
./quick_rebuild.sh
```

---

## 📱 What You Get

Your Budget Manager app with:
- 💰 Account tracking (Cash App, US Bank, etc.)
- 📅 Bill management (Electric, Internet, etc.)
- 💵 Paycheck calculator
- 📊 Budget forecasting
- 💾 Data backup/restore
- 🌙 Dark mode support
- 📱 Native iOS experience

---

## ⏱️ Time Breakdown

| Step | Time |
|------|------|
| Install Xcode | 15-30 min (one time) |
| Install Flutter | 5-10 min (one time) |
| Enable iPhone Dev Mode | 2 min (one time) |
| Run build script | 5-10 min (one time) |
| Trust certificate | 30 sec (one time) |
| **Total First Time** | **~30-45 min** |
| **Subsequent Builds** | **~2 min** |

---

## 🆘 Quick Troubleshooting

### iPhone not detected?
```bash
# Check connection
flutter devices

# Should see your iPhone
# If not: unplug, unlock iPhone, replug
```

### Code signing error?
- Open Xcode: `open ios/Runner.xcworkspace`
- Select your Apple ID in Signing & Capabilities
- Xcode will fix it automatically

### App won't open?
- Settings → General → VPN & Device Management
- Trust your developer certificate

### More help?
- See `TROUBLESHOOTING_IPHONE.md` for detailed solutions
- Or `BUILD_ON_MAC.md` for manual step-by-step guide

---

## 💡 Pro Tips

### 1. Hot Reload for Fast Development
```bash
flutter run
# Make code changes
# Press 'r' for instant hot reload!
```

### 2. Build Release Version
```bash
# Runs much faster
flutter run --release
```

### 3. Watch Logs
While running, Terminal shows all logs and errors in real-time!

### 4. Free Apple ID Limitation
Apps expire after 7 days. Just run `./quick_rebuild.sh` to reinstall (2 min).

---

## 📦 What's Included

- ✅ Automated build script (`build_iphone.sh`)
- ✅ Quick rebuild script (`quick_rebuild.sh`)
- ✅ Comprehensive guides:
  - `BUILD_ON_MAC.md` - Detailed manual instructions
  - `TROUBLESHOOTING_IPHONE.md` - Every possible issue solved
  - `SETUP_IPHONE.md` - Original setup guide
- ✅ Pre-configured Xcode project
- ✅ All dependencies specified
- ✅ Sample data included

---

## 🎯 Success Path

```
Step 1: Install Xcode + Flutter (one time)
   ↓
Step 2: Run ./build_iphone.sh
   ↓
Step 3: Select your Apple ID in Xcode
   ↓
Step 4: Trust certificate on iPhone
   ↓
🎉 App is running!
   ↓
Make changes → ./quick_rebuild.sh
```

---

## 📊 System Requirements

- **Mac**: macOS 10.14 or later
- **Xcode**: 12.0 or later (free)
- **iPhone**: iOS 13.0 or later
- **Disk Space**: ~10GB free
- **Internet**: For initial downloads

---

## 🔗 Quick Links

- [Flutter Install Guide](https://docs.flutter.dev/get-started/install/macos)
- [Xcode Download](https://apps.apple.com/app/xcode/id497799835)
- [Flutter iOS Setup](https://docs.flutter.dev/get-started/install/macos#ios-setup)

---

## 💻 One-Line Commands

```bash
# Complete first-time setup
cd ~/Desktop && git clone <repo-url> budget_manager && cd budget_manager && chmod +x build_iphone.sh && ./build_iphone.sh

# Quick rebuild after changes
cd ~/Desktop/budget_manager && ./quick_rebuild.sh

# Full clean rebuild
cd ~/Desktop/budget_manager && flutter clean && flutter pub get && flutter run

# Open in Xcode
cd ~/Desktop/budget_manager && open ios/Runner.xcworkspace
```

---

## ✅ Pre-Flight Checklist

Before running the build script:

- [ ] Mac is running macOS 10.14+
- [ ] Xcode is installed and opened once
- [ ] Flutter is installed: `flutter --version` works
- [ ] iPhone is connected via USB
- [ ] iPhone is unlocked
- [ ] Tapped "Trust" on iPhone
- [ ] Developer Mode enabled on iPhone (iOS 16+)
- [ ] At least 10GB free disk space

All checked? Run:
```bash
./build_iphone.sh
```

---

## 🎮 Interactive Build

When you run the script, you'll see:

```
🚀 Starting iPhone build process...

📋 Step 1: Checking Flutter installation...
✅ Flutter is installed

📋 Step 2: Checking Xcode installation...
✅ Xcode is installed

📋 Step 3: Running Flutter Doctor...
[Flutter doctor output]

📋 Step 4: Cleaning previous builds...
✅ Cleaned

📋 Step 5: Getting Flutter dependencies...
✅ Dependencies installed

📋 Step 6: Checking for connected devices...
[Device list]
⚠️  Make sure your iPhone is connected
Press Enter when ready...

📋 Step 7: Opening Xcode for code signing...
[Xcode opens automatically]
Press Enter after configuring...

📋 Step 8: Building and installing...
Choose: 1) Debug or 2) Release
[Build starts]

🎉 Build complete!
✅ The app is running on your iPhone!
```

---

**Ready to start? Run this:**

```bash
cd ~/Desktop
git clone <your-repo-url> budget_manager
cd budget_manager
./build_iphone.sh
```

**That's all! Have fun budgeting! 💰📱✨**
