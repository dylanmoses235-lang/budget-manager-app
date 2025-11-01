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
    print('🚀 Starting BudgetService initialization...');
    
    try {
      await Hive.initFlutter();
      print('✅ Hive.initFlutter() completed');
    } catch (e, stackTrace) {
      print('❌ Hive.initFlutter() failed: $e');
      print('Stack: $stackTrace');
      rethrow;
    }

    // Register type adapters (check first to avoid duplicate registration)
    try {
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(AccountAdapter());
        print('✅ Registered AccountAdapter');
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(BillAdapter());
        print('✅ Registered BillAdapter');
      }
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(TransactionAdapter());
        print('✅ Registered TransactionAdapter');
      }
      if (!Hive.isAdapterRegistered(3)) {
        Hive.registerAdapter(ConfigAdapter());
        print('✅ Registered ConfigAdapter');
      }
    } catch (e, stackTrace) {
      print('❌ Adapter registration failed: $e');
      print('Stack: $stackTrace');
      rethrow;
    }

    // Open boxes with aggressive error recovery
    print('📦 Opening Hive boxes...');
    await _openBoxSafely<Account>(accountsBox);
    await _openBoxSafely<Bill>(billsBox);
    await _openBoxSafely<Transaction>(transactionsBox);
    await _openBoxSafely<Config>(configBox);
    print('✅ All boxes opened successfully');

    // Initialize default data if first run
    print('📝 Initializing default data...');
    await _initializeDefaultData();
    print('✅ Default data initialized');
    print('🎉 BudgetService initialization complete!');
  }

  // Safely open a box - delete and recreate on ANY error
  static Future<void> _openBoxSafely<T>(String boxName) async {
    print('  📂 Opening box: $boxName');
    
    try {
      if (Hive.isBoxOpen(boxName)) {
        print('  ℹ️  Box $boxName already open');
        return;
      }
      
      await Hive.openBox<T>(boxName);
      print('  ✅ Box $boxName opened successfully');
    } catch (e, stackTrace) {
      // ANY error means corrupted - nuke it and start fresh
      print('  ⚠️  Corruption detected in $boxName: $e');
      print('  🔧 Attempting recovery...');
      
      try {
        // Try to close if it's somehow open
        if (Hive.isBoxOpen(boxName)) {
          print('  📕 Closing corrupted box...');
          await Hive.box(boxName).close();
        }
      } catch (closeError) {
        print('  ⚠️  Close error (ignoring): $closeError');
      }
      
      // Delete corrupted files
      try {
        print('  🗑️  Deleting corrupted box from disk...');
        await Hive.deleteBoxFromDisk(boxName);
        print('  ✅ Corrupted box deleted');
      } catch (deleteError) {
        print('  ⚠️  Delete error (ignoring): $deleteError');
      }
      
      // Open fresh box
      try {
        print('  🆕 Creating fresh box...');
        await Hive.openBox<T>(boxName);
        print('  ✅ Fresh box $boxName created successfully');
      } catch (createError, createStack) {
        print('  ❌ FATAL: Cannot create fresh box $boxName: $createError');
        print('  Stack: $createStack');
        rethrow;
      }
    }
  }

  static Future<void> _initializeDefaultData() async {
    try {
      final accountsBoxRef = Hive.box<Account>(accountsBox);
      final billsBoxRef = Hive.box<Bill>(billsBox);
      final configBoxRef = Hive.box<Config>(configBox);

      // Initialize accounts if empty
      if (accountsBoxRef.isEmpty) {
        print('  💰 Initializing default accounts...');
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
        print('  ✅ ${accountsBoxRef.length} accounts initialized');
      } else {
        print('  ℹ️  Found ${accountsBoxRef.length} existing accounts');
      }

      // Initialize bills if empty
      if (billsBoxRef.isEmpty) {
        print('  📋 Initializing default bills...');
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
        print('  ✅ ${billsBoxRef.length} bills initialized');
      } else {
        print('  ℹ️  Found ${billsBoxRef.length} existing bills');
      }

      // Initialize config if empty
      if (configBoxRef.isEmpty) {
        print('  ⚙️  Initializing default config...');
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
        print('  ✅ Config initialized');
      } else {
        print('  ℹ️  Config already exists');
      }
    } catch (e, stackTrace) {
      print('  ❌ Error initializing default data: $e');
      print('  Stack: $stackTrace');
      rethrow;
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
