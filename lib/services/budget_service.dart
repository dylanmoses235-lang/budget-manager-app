import 'package:hive_flutter/hive_flutter.dart';
import '../models/account.dart';
import '../models/bill.dart';
import '../models/transaction.dart';
import '../models/config.dart';
import '../data/budget_data.dart';

class BudgetService {
  static const String accountsBox = 'accounts';
  static const String billsBox = 'bills';
  static const String transactionsBox = 'transactions';
  static const String configBox = 'config';

  // Initialize Hive and register adapters
  static Future<void> initialize() async {
    try {
      await Hive.initFlutter();

      // Register type adapters
      if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(AccountAdapter());
      if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(BillAdapter());
      if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(TransactionAdapter());
      if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(ConfigAdapter());

      // Try to open boxes with error recovery
      await _openBoxSafely<Account>(accountsBox);
      await _openBoxSafely<Bill>(billsBox);
      await _openBoxSafely<Transaction>(transactionsBox);
      await _openBoxSafely<Config>(configBox);

      // Initialize default data if first run
      await _initializeDefaultData();
    } catch (e) {
      // If initialization fails, delete corrupted boxes and retry
      print('Error initializing Hive: $e');
      await _resetDatabase();
      // Retry initialization
      await initialize();
    }
  }

  // Safely open a box with corruption recovery
  static Future<void> _openBoxSafely<T>(String boxName) async {
    try {
      if (!Hive.isBoxOpen(boxName)) {
        await Hive.openBox<T>(boxName);
      }
    } catch (e) {
      print('Error opening box $boxName: $e');
      // Delete corrupted box and try again
      await Hive.deleteBoxFromDisk(boxName);
      await Hive.openBox<T>(boxName);
    }
  }

  // Reset database by deleting all corrupted boxes
  static Future<void> _resetDatabase() async {
    try {
      await Hive.deleteBoxFromDisk(accountsBox);
      await Hive.deleteBoxFromDisk(billsBox);
      await Hive.deleteBoxFromDisk(transactionsBox);
      await Hive.deleteBoxFromDisk(configBox);
    } catch (e) {
      print('Error resetting database: $e');
    }
  }

  static Future<void> _initializeDefaultData() async {
    final accountsBoxRef = Hive.box<Account>(accountsBox);
    final billsBoxRef = Hive.box<Bill>(billsBox);
    final configBoxRef = Hive.box<Config>(configBox);

    // Initialize accounts if empty
    if (accountsBoxRef.isEmpty) {
      for (var accountData in BudgetData.initialAccounts) {
        final account = Account(
          name: accountData['name'],
          startingBalance: accountData['startingBalance'],
          overdraftLimit: accountData['overdraftLimit'],
          overdraftUsed: accountData['overdraftUsed'],
          autoPaychecks: accountData['autoPaychecks'],
          icon: accountData['icon'],
        );
        await accountsBoxRef.add(account);
      }
    }

    // Initialize bills if empty
    if (billsBoxRef.isEmpty) {
      for (var billData in BudgetData.initialBills) {
        final bill = Bill(
          name: billData['name'],
          defaultAmount: billData['defaultAmount'],
          dueDay: billData['dueDay'],
          account: billData['account'],
          notes: billData['notes'],
        );
        await billsBoxRef.add(bill);
      }
    }

    // Initialize config if empty
    if (configBoxRef.isEmpty) {
      final config = Config(
        firstPaycheckDate: DateTime.parse(BudgetData.firstPaycheckDate),
        paycheckAmount: BudgetData.paycheckAmount,
        payFrequencyDays: BudgetData.payFrequencyDays,
        defaultDepositAccount: BudgetData.defaultDepositAccount,
        viewingMonth: DateTime.parse(BudgetData.defaultMonth),
        splitPaycheck: BudgetData.splitPaycheck,
        primaryDepositAmount: BudgetData.primaryDepositAmount,
        secondaryDepositAccount: BudgetData.secondaryDepositAccount,
      );
      await configBoxRef.put('config', config);
    }
  }

  // Get all accounts
  static List<Account> getAccounts() {
    return Hive.box<Account>(accountsBox).values.toList();
  }

  // Get account by name
  static Account? getAccountByName(String name) {
    return Hive.box<Account>(accountsBox)
        .values
        .firstWhere((account) => account.name == name);
  }

  // Get all bills
  static List<Bill> getBills() {
    return Hive.box<Bill>(billsBox).values.toList();
  }

  // Get bills for current viewing month
  static List<Bill> getBillsForMonth(DateTime month) {
    return getBills();
  }

  // Get all transactions
  static List<Transaction> getTransactions() {
    return Hive.box<Transaction>(transactionsBox).values.toList();
  }

  // Get transactions for current viewing month
  static List<Transaction> getTransactionsForMonth(DateTime month) {
    return getTransactions()
        .where((t) => t.isInMonth(month))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  // Get transactions for specific account
  static List<Transaction> getTransactionsForAccount(String accountName) {
    return getTransactions()
        .where((t) => t.account == accountName)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  // Get config
  static Config? getConfig() {
    return Hive.box<Config>(configBox).get('config');
  }

  // Update config
  static Future<void> updateConfig(Config config) async {
    await Hive.box<Config>(configBox).put('config', config);
  }

  // Add transaction
  static Future<void> addTransaction(Transaction transaction) async {
    await Hive.box<Transaction>(transactionsBox).add(transaction);
  }

  // Add account
  static Future<void> addAccount(Account account) async {
    await Hive.box<Account>(accountsBox).add(account);
  }

  // Add bill
  static Future<void> addBill(Bill bill) async {
    await Hive.box<Bill>(billsBox).add(bill);
  }

  // Update bill payment status for specific month
  static Future<void> updateBillPayment(Bill bill, bool paid, [DateTime? month]) async {
    final targetMonth = month ?? DateTime.now();
    bill.setPaidForMonth(targetMonth, paid);
    await bill.save();
  }

  // Calculate total account balance (all accounts combined)
  static double getTotalBalance() {
    final accounts = getAccounts();
    final transactions = getTransactions();
    
    double total = 0;
    for (var account in accounts) {
      total += account.startingBalance;
    }
    
    // Add all transactions
    for (var transaction in transactions) {
      total += transaction.amount;
    }
    
    return total;
  }

  // Calculate balance for specific account
  static double getAccountBalance(String accountName) {
    final account = getAccountByName(accountName);
    if (account == null) return 0;

    final transactions = getTransactionsForAccount(accountName);
    double balance = account.startingBalance;
    
    for (var transaction in transactions) {
      balance += transaction.amount;
    }
    
    return balance;
  }

  // Calculate total available (including overdraft)
  static double getTotalAvailable() {
    final accounts = getAccounts();
    double total = getTotalBalance();
    
    for (var account in accounts) {
      total += (account.overdraftLimit - account.overdraftUsed);
    }
    
    return total;
  }

  // Get total income for month
  static double getMonthIncome(DateTime month) {
    return getTransactionsForMonth(month)
        .where((t) => t.isIncome)
        .fold(0, (sum, t) => sum + t.amount);
  }

  // Get total expenses for month
  static double getMonthExpenses(DateTime month) {
    return getTransactionsForMonth(month)
        .where((t) => t.isExpense)
        .fold(0, (sum, t) => sum + t.amount.abs());
  }

  // Get bills paid this month
  static double getBillsPaidThisMonth(DateTime month) {
    return getBillsForMonth(month)
        .where((b) => b.isPaidForMonth(month))
        .fold(0, (sum, b) => sum + b.getAmountForMonth(month));
  }

  // Get unpaid bills total
  static double getUnpaidBillsTotal(DateTime month) {
    return getBillsForMonth(month)
        .where((b) => !b.isPaidForMonth(month))
        .fold(0, (sum, b) => sum + b.getAmountForMonth(month));
  }
}
