# 🔄 Update Instructions for Your Mac

## ✅ What I Fixed:

1. **✅ Added Cred.ai Account** - Now shows separately from Cash App
2. **✅ Updated All Account Balances** - Cash App: $119.17, Cred.ai: $9.43, etc.
3. **✅ Fixed Split Paychecks** - $1,000 to Cash App, remainder to Cred.ai
4. **✅ Fixed UI Overflow** - Bills screen checkbox sizing issue resolved

---

## 📱 Steps to Update Your iPhone App:

### 1. Pull Latest Changes

In Terminal on your Mac:

```bash
cd /Users/dylanmoses/smart_money_tracker_v2
git pull origin main
```

### 2. Regenerate Hive Type Adapters

Since I modified the database schema (added split paycheck fields), you need to regenerate the Hive adapters:

```bash
flutter pub get
flutter packages pub run build_runner build --delete-conflicting-outputs
```

This will regenerate the `config.g.dart` file with the new fields.

### 3. Restart the App

The easiest way is to completely rebuild:

```bash
# Stop the current running app (press 'q' in the terminal where it's running)
# OR press Ctrl+C

# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

---

## 🎯 What Changed:

### Split Paycheck Configuration

Your $1,311 paycheck now splits automatically:
- **$1,000** → Cash App
- **$311** → Cred.ai (remainder)

Both accounts are set to `autoPaychecks: true` so they'll receive their portions automatically.

### Updated Account Data

```
Cash App:        $119.17 (overdraft $99.19 used of $150)
Cred.ai:         $9.43
Cash App Savings: $4.07
Cash App Stocks:  $4.03
Cash App Bitcoin: $0.00
Cash App Borrow:  -$357.00 owed
Cash App Afterpay: -$207.53 owed
US Bank Checking: -$193.81
US Bank Savings:  $0.00
```

### Updated Bills

```
Electric (OG&E): $182.15 due Nov 5, 2025
Internet (AT&T): $5.33 due Nov 9, 2025
```

---

## ⚠️ Important Notes:

1. **Database Reset**: Since we modified the Config model structure, you might need to clear app data on your iPhone:
   - Delete the app from your iPhone
   - Reinstall with `flutter run`
   - This will load all the new account data

2. **UI Fixed**: The bills screen overflow issue is resolved - the checkbox and amount now fit properly

3. **Month Picker**: The "Month picker not implemented" warnings in console are normal - that feature isn't built yet

---

## 🐛 If You See Errors:

### "Type 'Config' is not a subtype of type 'Config'"

This means Hive is confused by the model changes. Solution:

```bash
# Delete the app completely
# Then reinstall
flutter clean
flutter pub get
flutter run
```

### "MissingPluginException"

```bash
# Stop the app
# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

### Build Runner Errors

```bash
# Force regenerate all generated files
flutter packages pub run build_runner clean
flutter packages pub run build_runner build --delete-conflicting-outputs
```

---

## 📊 Testing the Split Paycheck:

After updating, the app should show:
1. Both Cash App and Cred.ai marked for "auto paychecks"
2. When you add a paycheck transaction (manually or via the auto-paycheck feature), it should create two transactions:
   - $1,000 to Cash App
   - $311 to Cred.ai

---

## 🎉 You're All Set!

After running these commands, your app should:
- ✅ Show correct balances
- ✅ Have Cred.ai as a separate account
- ✅ Split paychecks automatically
- ✅ No more UI overflow errors

Run the update commands and let me know if you hit any issues!
