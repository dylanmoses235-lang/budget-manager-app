# Force-Close Debugging Guide

## 🔍 How to Debug the Force-Close Issue

To help identify exactly what's happening when the app crashes after force-close, please follow these steps:

---

## Step 1: Pull Latest Changes

```bash
cd ~/budget-manager-app
git pull
```

---

## Step 2: Run with Verbose Logging

```bash
flutter run --verbose 2>&1 | tee force_close_test.log
```

This command will:
- Run the app with verbose output
- Save ALL output to `force_close_test.log`
- Still display output in terminal

---

## Step 3: Perform Force-Close Test

1. **Wait for app to fully load**
   - Wait until you see: `✅ Database initialized successfully on attempt 1`
   - Navigate around the app (Dashboard, Bills, Accounts, etc.)

2. **Force close the app**
   - Double-click home button (or swipe up on newer iPhones)
   - Swipe up on the Budget Manager app to force close it
   - **Important:** Make sure it's completely terminated

3. **Reopen the app**
   - Tap the app icon to launch again
   - **Watch the console output carefully**

4. **Keep the terminal open**
   - Don't close the terminal
   - Let it capture everything

---

## Step 4: What to Look For

### ✅ Successful Reopen (What we want to see):

```
flutter: 🚀 App starting...
flutter: ⏳ Initialization attempt 1...
flutter: 🚀 Starting BudgetService initialization...
flutter: 🔄 Initializing Hive...
flutter: ✅ Hive.initFlutter() completed
flutter: ✅ Registered AccountAdapter
flutter: ✅ Registered BillAdapter
flutter: ✅ Registered TransactionAdapter
flutter: ✅ Registered ConfigAdapter
flutter: 📦 Opening Hive boxes...
flutter:   ✅ Box accounts opened successfully
flutter:   ✅ Box bills opened successfully
flutter:   ✅ Box transactions opened successfully
flutter:   ✅ Box config opened successfully
flutter: ✅ All boxes opened successfully
flutter: ✅ Database initialized successfully on attempt 1
```

### ❌ Crash Scenarios (What we're trying to fix):

#### Scenario A: Immediate Crash on Launch
```
flutter: 🚀 App starting...
Lost connection to device.
```
OR
```
flutter: 🚀 App starting...
💥 UNCAUGHT ERROR IN ZONE:
Error: [some error message]
Lost connection to device.
```

#### Scenario B: Crash During Initialization
```
flutter: 🚀 Starting BudgetService initialization...
flutter: ❌ Hive.initFlutter() failed: [error]
Lost connection to device.
```

#### Scenario C: Crash After Initialization
```
flutter: ✅ Database initialized successfully on attempt 1
[app loads]
💥 FLUTTER ERROR CAUGHT:
Exception: [some error]
Lost connection to device.
```

#### Scenario D: Crash on Resume/Lifecycle
```
flutter: 📱 App lifecycle changed: AppLifecycleState.resumed
flutter: 🔄 App resumed, verifying database...
Lost connection to device.
```

---

## Step 5: Share the Information

Please provide the following:

### A. Console Output
Copy the relevant console output showing:
- The last successful messages before force-close
- All messages when reopening the app
- The error message (if any)
- The "Lost connection to device" message

### B. Crash Scenario
Which scenario above matches what you're seeing? Or describe what's different.

### C. Log File
Share the `force_close_test.log` file that was created, especially the section around the crash.

### D. Timing
- How long after reopening does the crash occur?
  - Immediately?
  - After 1-2 seconds?
  - After navigating somewhere?
  - When tapping something?

---

## Alternative: Check iOS Console

If the Flutter console doesn't show enough detail, check the iOS device console:

### On Mac:
1. Open **Console.app** (in Applications/Utilities)
2. Select your iPhone from the devices list
3. Filter by "budget" or "Budget Manager"
4. Perform the force-close test
5. Look for crash logs or error messages

### Look for:
- Crash reports mentioning "budget_manager" or "Runner"
- Exception messages
- Signal errors (SIGABRT, SIGSEGV, etc.)
- Memory warnings

---

## Common Issues and Solutions

### Issue 1: Hive Path Not Set
**Symptom:** `HiveError: You need to initialize Hive or provide a path`

**Should be fixed by:** Commit 2e2697c (already applied)

**If still occurring:** This means Hive.initFlutter() is failing silently

---

### Issue 2: Box Corruption
**Symptom:** Errors about corrupted boxes or unable to read data

**Solution:** Delete and reinstall app to clear all data:
```bash
flutter clean
flutter run
```
Then completely uninstall from device and reinstall.

---

### Issue 3: Memory Issue
**Symptom:** Crash with no error message, just "Lost connection"

**Possible causes:**
- App using too much memory
- iOS killing app due to resource constraints
- Check iOS Console for memory warnings

---

### Issue 4: Lifecycle State Issue
**Symptom:** Crash when `AppLifecycleState.resumed` is triggered

**Should be fixed by:** Commit b1266d5 (already applied)

**If still occurring:** We may need to disable lifecycle verification

---

## Quick Test Script

Save this as `test_force_close.sh` and run it:

```bash
#!/bin/bash
echo "Starting force-close test..."
echo "Step 1: Cleaning and building..."
flutter clean
flutter pub get

echo ""
echo "Step 2: Running app..."
echo "  → Wait for app to fully load"
echo "  → Then force-close the app"
echo "  → Then reopen it"
echo "  → Watch for errors below"
echo ""

flutter run 2>&1 | tee force_close_debug.log
```

---

## Expected Behavior After Fix

After reopening from force-close, you should see:

1. **Fresh Initialization** (not resume)
   ```
   flutter: 🚀 App starting...
   flutter: ⏳ Initialization attempt 1...
   ```

2. **Successful Hive Setup**
   ```
   flutter: ✅ Hive.initFlutter() completed
   flutter: ✅ All boxes opened successfully
   ```

3. **App Loads Normally**
   - Dashboard displays
   - All screens accessible
   - Data intact

4. **NO Crash**
   - No "Lost connection to device"
   - No error screens
   - Stable and usable

---

## Need More Help?

If the issue persists after latest fixes (commit 2e2697c):

1. Share the console output from Step 5
2. Note which crash scenario matches (A, B, C, or D)
3. Check if it's consistent (happens every time) or intermittent
4. Try deleting and reinstalling the app completely

The comprehensive error zone should now catch and log ANY error that occurs, making it much easier to identify the root cause.
