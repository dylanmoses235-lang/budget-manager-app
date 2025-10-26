// Budget Manager Data - Parsed from Smart Monthly System CSV
// This contains all account, bill, category, and transaction type definitions

class BudgetData {
  // Account Names
  static const String cashApp = 'Cash App';
  static const String cashAppSavings = 'Cash App Savings';
  static const String cashAppBorrow = 'Cash App Borrow';
  static const String cashAppAfterpay = 'Cash App Afterpay (owed)';
  static const String cashAppStocks = 'Cash App Stocks';
  static const String cashAppBitcoin = 'Cash App Bitcoin';
  static const String usBankChecking = 'US Bank Checking 3883';
  static const String usBankSavings = 'US Bank Savings 0588';

  // Initial Account Data from CSV
  static final List<Map<String, dynamic>> initialAccounts = [
    {
      'name': cashApp,
      'startingBalance': 0.0,
      'overdraftLimit': 150.0,
      'overdraftUsed': 48.58,
      'autoPaychecks': true,
      'icon': 0xe54c, // wallet icon
    },
    {
      'name': cashAppSavings,
      'startingBalance': 50.03,
      'overdraftLimit': 0.0,
      'overdraftUsed': 0.0,
      'autoPaychecks': false,
      'icon': 0xe227, // savings icon
    },
    {
      'name': cashAppBorrow,
      'startingBalance': 0.0,
      'overdraftLimit': 450.0,
      'overdraftUsed': 0.0,
      'autoPaychecks': false,
      'icon': 0xe0e0, // credit card icon
    },
    {
      'name': cashAppAfterpay,
      'startingBalance': -207.53,
      'overdraftLimit': 0.0,
      'overdraftUsed': 0.0,
      'autoPaychecks': false,
      'icon': 0xe8e4, // payment icon
    },
    {
      'name': cashAppStocks,
      'startingBalance': 3.24,
      'overdraftLimit': 0.0,
      'overdraftUsed': 0.0,
      'autoPaychecks': false,
      'icon': 0xe8e5, // trending up icon
    },
    {
      'name': cashAppBitcoin,
      'startingBalance': 0.0,
      'overdraftLimit': 0.0,
      'overdraftUsed': 0.0,
      'autoPaychecks': false,
      'icon': 0xe263, // currency bitcoin icon
    },
    {
      'name': usBankChecking,
      'startingBalance': 98.49,
      'overdraftLimit': 0.0,
      'overdraftUsed': 0.0,
      'autoPaychecks': false,
      'icon': 0xe0e0, // account balance icon
    },
    {
      'name': usBankSavings,
      'startingBalance': 0.0,
      'overdraftLimit': 0.0,
      'overdraftUsed': 0.0,
      'autoPaychecks': false,
      'icon': 0xe227, // savings icon
    },
  ];

  // Initial Bills Data from CSV
  static final List<Map<String, dynamic>> initialBills = [
    {
      'name': 'Rent',
      'defaultAmount': 0.0,
      'dueDay': 1,
      'account': cashApp,
      'notes': 'Monthly rent',
    },
    {
      'name': 'Internet (AT&T)',
      'defaultAmount': 0.0,
      'dueDay': 6,
      'account': cashApp,
      'notes': 'Internet',
    },
    {
      'name': 'Phone (Visible)',
      'defaultAmount': 0.0,
      'dueDay': 15,
      'account': cashApp,
      'notes': 'Mobile',
    },
    {
      'name': 'Electric (OG&E)',
      'defaultAmount': 0.0,
      'dueDay': 6,
      'account': cashApp,
      'notes': 'Electric',
    },
    {
      'name': 'Apple Services',
      'defaultAmount': 0.0,
      'dueDay': 20,
      'account': cashApp,
      'notes': 'iCloud',
    },
  ];

  // Transaction Categories from CSV
  static const List<String> categories = [
    'Bill',
    'Paycheck',
    'Food',
    'Gas',
    'Shopping',
    'Entertainment',
    'Healthcare',
    'Transportation',
    'Savings',
    'Debt',
    'Other',
  ];

  // Transaction Types from CSV
  static const List<String> transactionTypes = [
    'Income',
    'Expense',
    'Bill',
    'Transfer',
  ];

  // Paycheck Configuration from CSV
  static const String firstPaycheckDate = '2025-10-29';
  static const double paycheckAmount = 1311.0;
  static const int payFrequencyDays = 14; // Bi-weekly
  static const String defaultDepositAccount = cashApp;

  // Month Configuration from CSV
  static const String defaultMonth = '2025-10-01';
}
