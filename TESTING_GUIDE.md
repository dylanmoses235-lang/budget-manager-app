# Budget Manager - Testing Guide for Crash Fixes

## Quick Testing Checklist

### ✅ RenderFlex Overflow Fix
- [ ] Launch app
- [ ] Navigate to Bills screen
- [ ] Verify no yellow/black striped overflow indicators
- [ ] Check that bill amounts and checkboxes display correctly
- [ ] Scroll through bill list

### ✅ Force-Close Recovery Fix

#### Test 1: Basic Force Close
1. [ ] Open the app
2. [ ] Let it fully load (see dashboard)
3. [ ] Force close the app (double-tap home, swipe up on app)
4. [ ] Reopen the app
5. [ ] **Expected**: App loads normally without crash
6. [ ] **Expected**: All data displays correctly

#### Test 2: Force Close from Bills Screen
1. [ ] Open the app
2. [ ] Navigate to Bills screen
3. [ ] Force close the app
4. [ ] Reopen the app
5. [ ] **Expected**: App loads normally
6. [ ] Navigate back to Bills screen
7. [ ] **Expected**: Bills display correctly

#### Test 3: Multiple Force Closes
1. [ ] Open app
2. [ ] Force close
3. [ ] Reopen
4. [ ] Force close again
5. [ ] Reopen
6. [ ] Repeat 3-5 times
7. [ ] **Expected**: App remains stable

#### Test 4: Background/Foreground Cycling
1. [ ] Open app
2. [ ] Press home button (background app)
3. [ ] Open another app
4. [ ] Return to Budget Manager
5. [ ] **Expected**: App resumes normally
6. [ ] Repeat several times

#### Test 5: Extended Background Period
1. [ ] Open app
2. [ ] Background it (home button)
3. [ ] Wait 5+ minutes
4. [ ] Return to app
5. [ ] **Expected**: App resumes, may reinitialize database
6. [ ] **Expected**: Data remains intact

## What to Look For

### ✅ Good Signs (Success)
- App loads without errors
- All screens are accessible
- Data displays correctly
- No crash dialogs
- Bills, accounts, and transactions all show proper data
- Console shows successful box verification/reopening messages

### ❌ Bad Signs (Issues to Report)
- App crashes on launch
- White/black screen that doesn't load
- Error dialogs appear
- Data is missing
- Screens fail to load
- Console shows repeated initialization failures

## Console Log Monitoring

When testing, watch for these log patterns:

### Successful Recovery
```
📱 App lifecycle changed: AppLifecycleState.resumed
🔄 App resumed, verifying database...
🔍 Checking if Hive boxes are still open...
✅ accounts box is open
✅ bills box is open
✅ transactions box is open
✅ config box is open
✅ Config read successfully
✅ Database fully verified and accessible
```

### Box Reopening (Also Good)
```
⚠️  Some boxes are closed, reopening...
🔄 Reopening all boxes...
⚠️  Box accounts was closed, reopening...
✅ Box accounts reopened successfully
✅ Boxes reopened successfully
```

### Full Reinitialization (Acceptable)
```
❌ Database verification failed: ...
⚠️  Database not accessible after resume, full reinitialization required...
✅ All Hive boxes closed
⏳ Initialization attempt 1...
✅ Database initialized successfully on attempt 1
```

### Critical Error (Report This)
```
❌ Initialization attempt 3 failed: ...
💥 Failed to initialize after 3 attempts
```

## Reporting Issues

If you encounter problems, please provide:

1. **What you did**: Exact steps to reproduce
2. **What happened**: Description of the crash/error
3. **Expected behavior**: What should have happened
4. **Console logs**: Copy relevant console output
5. **Device info**: iOS version, device model
6. **Frequency**: Does it happen every time or intermittently?

## Quick Commands for Testing

### Run app on device:
```bash
cd ~/budget-manager-app
flutter run
```

### View detailed logs:
```bash
cd ~/budget-manager-app
flutter run --verbose
```

### Clean and rebuild if needed:
```bash
cd ~/budget-manager-app
flutter clean
flutter pub get
cd ios
pod deintegrate
pod install
cd ..
flutter run
```

## Success Criteria

All tests pass when:
- ✅ No crashes occur during any test scenario
- ✅ App consistently recovers from force-close
- ✅ All data remains accessible after recovery
- ✅ Bills screen displays without overflow errors
- ✅ Console logs show successful verification/recovery
- ✅ User experience is smooth and stable

## Notes

- Force-close recovery happens automatically
- You should see log messages indicating database verification
- The app may take 1-2 seconds longer to resume after force-close (normal)
- If reinitialization happens, you'll see "Initialization attempt" messages
- All recovery is automatic - no user action required
