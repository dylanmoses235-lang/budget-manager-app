# 💰 Budget Manager

A comprehensive Flutter application for smart monthly budget tracking and financial management. Track accounts, bills, transactions, set savings goals, analyze spending patterns, and make informed financial decisions.

![Flutter](https://img.shields.io/badge/Flutter-3.9.2-blue)
![Dart](https://img.shields.io/badge/Dart-3.9.2-blue)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-green)
![License](https://img.shields.io/badge/License-MIT-yellow)

## ✨ Features

### 📊 Core Features

#### Dashboard
- **Monthly Overview**: Quick view of total balance, available funds, and net change
- **Paycheck Tracking**: Track upcoming paychecks and paychecks received
- **Bills Summary**: See paid and unpaid bills at a glance
- **Month Picker**: Navigate between different months seamlessly
- **Pull to Refresh**: Update data instantly

#### Account Management
- **Multiple Accounts**: Manage checking, savings, credit cards, and investment accounts
- **Overdraft Tracking**: Monitor overdraft limits and usage
- **Auto Paycheck Deposits**: Automatically add paychecks to designated accounts
- **Real-time Balances**: Calculate balances based on transactions
- **Custom Icons**: Personalize accounts with custom icons

#### Bill Tracking
- **Recurring Bills**: Set up monthly bills with due dates
- **Payment Status**: Mark bills as paid/unpaid
- **Due Date Reminders**: Get notified before bills are due
- **Past Due Tracking**: Identify overdue bills
- **Account Assignment**: Link bills to specific accounts

#### Transaction Management
- **Quick Entry**: Add income, expenses, bills, and transfers
- **Categorization**: Organize transactions by category
- **Notes**: Add detailed notes to transactions
- **Date Tracking**: Full transaction history by date
- **Account Filtering**: View transactions by account

### 📈 Analytics & Insights

#### Charts & Visualizations
- **Income vs Expenses**: Bar chart comparing monthly income and expenses
- **Spending by Category**: Pie chart showing spending distribution
- **Spending Trends**: Line chart tracking expense patterns over time
- **Budget Progress**: Visual indicators for category budget usage

#### Time Periods
- **This Month**: Current month analysis
- **Last 3 Months**: Quarterly trend analysis
- **Last 6 Months**: Semi-annual spending patterns

### 🎯 Budget Categories

#### Category Features
- **Custom Categories**: Create unlimited spending categories
- **Monthly Budgets**: Set budget limits for each category
- **Color Coding**: Assign colors for quick identification
- **Icon Selection**: Choose from 16+ icons
- **Budget Tracking**: Monitor spending vs budget in real-time
- **Over-Budget Alerts**: Visual warnings when exceeding budgets
- **Default Categories**: Pre-configured essential categories:
  - Groceries
  - Utilities
  - Transportation
  - Entertainment
  - Healthcare
  - Dining
  - Shopping
  - Other

### 🎯 Savings Goals

#### Goal Management
- **Multiple Goals**: Track multiple savings goals simultaneously
- **Progress Tracking**: Visual progress bars and percentage completed
- **Target Dates**: Set deadline for goal completion
- **Contribution History**: Track all contributions
- **Smart Suggestions**: Get recommended monthly contributions
- **On-Track Indicator**: Know if you're on pace to meet your goal
- **Goal Categories**: Organize goals by type (vacation, car, house, etc.)
- **Completion Celebration**: Mark goals as complete

### 🔄 Recurring Transactions

#### Automation Features
- **Frequency Options**:
  - Daily
  - Weekly
  - Bi-weekly
  - Monthly
  - Quarterly
  - Yearly
- **Auto-Generation**: Automatically create transactions based on schedule
- **Start/End Dates**: Define recurring transaction lifespan
- **Active/Inactive**: Enable or disable recurring transactions
- **Paycheck Automation**: Set up automatic paycheck deposits

### 💾 Data Management

#### Export Options
- **JSON Backup**: Complete backup of all data
- **CSV Export**: Export transactions to CSV for Excel/Google Sheets
- **Date Range Filters**: Export specific time periods
- **Share Integration**: Share exports via any app

#### Import Options
- **JSON Import**: Restore from backup files
- **Data Merge**: Import adds to existing data (doesn't overwrite)
- **Validation**: Automatic data validation on import

### 🔔 Notifications (Coming Soon)

- **Bill Reminders**: Notifications 3 days before, 1 day before, and on due date
- **Paycheck Alerts**: Get notified when paychecks are coming
- **Over-Budget Warnings**: Alerts when exceeding category budgets
- **Goal Milestones**: Celebrate reaching goal milestones

### 🎨 UI/UX Features

- **Material Design 3**: Modern, clean interface
- **Dark Mode**: Full dark theme support
- **Responsive Layout**: Works on phones, tablets, and web
- **Smooth Animations**: Polished user experience
- **Pull-to-Refresh**: Easy data updates
- **Bottom Navigation**: Quick access to main features
- **Floating Action Buttons**: Quick add functionality
- **Color-Coded Visuals**: Easy-to-understand charts and indicators

## 🚀 Getting Started

### Prerequisites

```bash
Flutter SDK: 3.9.2 or higher
Dart SDK: 3.9.2 or higher
```

### Installation

1. **Clone the repository**
```bash
git clone <your-repo-url>
cd budget_manager
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Run the app**
```bash
# Development mode
flutter run

# Release mode
flutter run --release

# Web
flutter run -d chrome

# Specific device
flutter devices
flutter run -d <device-id>
```

### Building

```bash
# Android APK
flutter build apk --release

# iOS
flutter build ios --release

# Web
flutter build web

# Windows
flutter build windows

# macOS
flutter build macos

# Linux
flutter build linux
```

## 📦 Dependencies

### Core
- **flutter**: SDK
- **hive**: 2.2.3 - Local database
- **hive_flutter**: 1.1.0 - Flutter integration for Hive
- **provider**: 6.1.5+1 - State management
- **intl**: 0.19.0 - Internationalization and date formatting

### UI Components
- **cupertino_icons**: ^1.0.8 - iOS-style icons
- **percent_indicator**: 4.2.3 - Progress indicators
- **fl_chart**: ^0.69.0 - Beautiful charts
- **flutter_slidable**: ^3.1.1 - Swipeable list items

### Notifications
- **flutter_local_notifications**: ^18.0.1 - Local push notifications
- **timezone**: ^0.9.4 - Timezone support for notifications

### File Handling
- **path_provider**: ^2.1.4 - Access device directories
- **csv**: ^6.0.0 - CSV file handling
- **file_picker**: ^8.1.2 - File selection
- **share_plus**: ^10.1.0 - Share files
- **permission_handler**: ^11.3.1 - Runtime permissions

### Utilities
- **introduction_screen**: ^3.1.14 - Onboarding screens
- **uuid**: ^4.5.1 - Generate unique IDs
- **collection**: ^1.19.1 - Collection utilities

## 📱 Screenshots

*Coming soon - Screenshots will be added showcasing:*
- Dashboard view
- Analytics charts
- Category management
- Goals tracking
- Transaction list
- Settings panel

## 🏗️ Architecture

### Project Structure

```
lib/
├── data/              # Initial data and constants
│   └── budget_data.dart
├── models/            # Data models
│   ├── account.dart
│   ├── bill.dart
│   ├── category.dart
│   ├── config.dart
│   ├── goal.dart
│   ├── recurring_transaction.dart
│   └── transaction.dart
├── providers/         # State management
│   └── budget_provider.dart
├── screens/           # UI screens
│   ├── accounts_screen.dart
│   ├── analytics_screen.dart
│   ├── bills_screen.dart
│   ├── categories_screen.dart
│   ├── dashboard_screen.dart
│   ├── goals_screen.dart
│   ├── settings_screen.dart
│   └── transactions_screen.dart
├── services/          # Business logic
│   ├── budget_service.dart
│   ├── export_import_service.dart
│   └── notification_service.dart
├── widgets/           # Reusable widgets
│   └── month_picker_dialog.dart
└── main.dart          # App entry point
```

### Data Flow

1. **Hive Database** stores all data locally
2. **BudgetService** handles database operations
3. **BudgetProvider** manages app state
4. **Screens** consume Provider data
5. **User actions** update Provider
6. **Provider** updates database through service

## 🎯 Roadmap

### Phase 1 - Core Features ✅
- [x] Account management
- [x] Bill tracking
- [x] Transaction management
- [x] Dashboard
- [x] Settings

### Phase 2 - Analytics & Insights ✅
- [x] Budget categories
- [x] Charts and visualizations
- [x] Spending analysis
- [x] Budget tracking
- [x] Goals tracking

### Phase 3 - Advanced Features ✅
- [x] Data export/import
- [x] Provider state management
- [x] Month picker
- [x] Recurring transactions model

### Phase 4 - Polish (In Progress)
- [ ] Local notifications
- [ ] Search and filtering
- [ ] Swipe actions on lists
- [ ] Empty states with illustrations
- [ ] Onboarding tutorial

### Phase 5 - Testing & Documentation
- [ ] Unit tests
- [ ] Widget tests
- [ ] Integration tests
- [ ] API documentation
- [ ] User guide

### Future Enhancements
- [ ] Cloud sync
- [ ] Multi-user support
- [ ] Bank integration APIs
- [ ] Receipt scanning (OCR)
- [ ] AI-powered insights
- [ ] Budget forecasting
- [ ] Multi-currency support
- [ ] Investment tracking
- [ ] Debt payoff calculator
- [ ] Custom reports

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Hive team for the fast local database
- FL Chart team for beautiful charts
- All open-source contributors

## 📞 Support

For support, please open an issue in the GitHub repository.

## 🔧 Development Tips

### Database Inspection
To inspect Hive database:
```dart
// Print all data
print('Accounts: ${BudgetService.getAccounts()}');
print('Bills: ${BudgetService.getBills()}');
print('Transactions: ${BudgetService.getTransactions()}');
```

### Reset Database
To clear all data:
```dart
await Hive.deleteBoxFromDisk('accounts');
await Hive.deleteBoxFromDisk('bills');
await Hive.deleteBoxFromDisk('transactions');
await Hive.deleteBoxFromDisk('config');
await Hive.deleteBoxFromDisk('categories');
await Hive.deleteBoxFromDisk('recurring_transactions');
await Hive.deleteBoxFromDisk('goals');
```

### Generate Hive Adapters
If you modify models:
```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

## 📊 Performance

- **Fast startup**: Local-first architecture
- **Smooth scrolling**: Optimized list rendering
- **Small app size**: ~20MB installed
- **Battery efficient**: Minimal background processing
- **Offline-first**: Works without internet

## 🌟 Key Highlights

✅ **100% Offline** - No internet required  
✅ **Privacy First** - All data stored locally  
✅ **No Ads** - Clean, ad-free experience  
✅ **Free Forever** - No subscriptions or in-app purchases  
✅ **Cross-Platform** - Android, iOS, Web, Desktop  
✅ **Open Source** - Transparent and customizable  

---

Made with ❤️ using Flutter
