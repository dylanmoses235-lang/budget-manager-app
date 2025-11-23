import 'dart:async';
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
    print('📊 Memory check: ${DateTime.now()}');
    
    try {
      // Always call initFlutter - it's safe to call multiple times
      // Hive will handle already-initialized state internally
      print('🔄 Initializing Hive with timeout protection...');
      
      // Add timeout protection for init
      await Hive.initFlutter().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('⚠️ Hive.initFlutter() timed out, may have succeeded anyway');
          return;
        },
      );
      print('✅ Hive.initFlutter() completed');
      
      // Small delay to ensure filesystem is ready
      await Future.delayed(const Duration(milliseconds: 100));
      
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
    
    int attempts = 0;
    bool opened = false;
    
    while (!opened && attempts < 3) {
      try {
        if (Hive.isBoxOpen(boxName)) {
          print('  ℹ️  Box $boxName already open');
          
          // VERIFY it's actually accessible by reading from it
          try {
            final box = Hive.box<T>(boxName);
            box.values.length; // Force read to check accessibility
            print('  ✅ Box $boxName verified accessible');
            opened = true;
            return;
          } catch (verifyError) {
            print('  ⚠️  Box $boxName is open but NOT accessible: $verifyError');
            print('  🔧 Closing and deleting corrupted box...');
            
            try {
              await Hive.box(boxName).close().timeout(const Duration(seconds: 3));
            } catch (e) {
              print('  ⚠️  Close error: $e (ignoring)');
            }
            
            try {
              await Hive.deleteBoxFromDisk(boxName).timeout(const Duration(seconds: 3));
              print('  ✅ Deleted inaccessible box');
            } catch (e) {
              print('  ⚠️  Delete error: $e (ignoring)');
            }
            
            // Continue to open fresh box below
          }
        }
        
        // Add timeout protection
        await Hive.openBox<T>(boxName).timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw TimeoutException('Opening $boxName timed out');
          },
        );
        print('  ✅ Box $boxName opened successfully');
        
        // Verify it's actually usable
        try {
          final box = Hive.box<T>(boxName);
          box.values.length; // Force read
          print('  ✅ Box $boxName verified usable');
        } catch (verifyError) {
          throw Exception('Box opened but not usable: $verifyError');
        }
        
        opened = true;
      } catch (e, stackTrace) {
        attempts++;
        print('  ⚠️  Error with $boxName (attempt $attempts): $e');
        
        if (attempts >= 3) {
          print('  ❌ Failed to open $boxName after 3 attempts');
          rethrow;
        }
        
        // ANY error means corrupted - nuke it and start fresh
        print('  🔧 Attempting recovery...');
        
        try {
          // Try to close if it's somehow open
          if (Hive.isBoxOpen(boxName)) {
            print('  📕 Force closing...');
            await Hive.box(boxName).close().timeout(const Duration(seconds: 3));
          }
        } catch (closeError) {
          print('  ⚠️  Close error (ignoring): $closeError');
        }
        
        // Delete corrupted files
        try {
          print('  🗑️  Deleting from disk...');
          await Hive.deleteBoxFromDisk(boxName).timeout(const Duration(seconds: 3));
          print('  ✅ Deleted');
        } catch (deleteError) {
          print('  ⚠️  Delete error (ignoring): $deleteError');
        }
        
        // Wait before retry
        await Future.delayed(Duration(milliseconds: 300 * attempts));
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

  // Reopen all boxes if they were closed (e.g., after force close)
  static Future<void> reopenBoxes() async {
    print('🔄 Reopening all boxes...');
    await _ensureBoxOpen<Account>(accountsBox);
    await _ensureBoxOpen<Bill>(billsBox);
    await _ensureBoxOpen<Transaction>(transactionsBox);
    await _ensureBoxOpen<Config>(configBox);
    print('✅ All boxes reopened');
  }

  // Ensure a box is open before accessing it
  static Future<void> _ensureBoxOpen<T>(String boxName) async {
    if (!Hive.isBoxOpen(boxName)) {
      print('⚠️  Box $boxName was closed, reopening...');
      try {
        await Hive.openBox<T>(boxName);
        print('✅ Box $boxName reopened successfully');
      } catch (e) {
        print('❌ Failed to reopen $boxName: $e');
        // Try to recover by deleting and recreating
        await _openBoxSafely<T>(boxName);
      }
    } else {
      print('✅ Box $boxName already open');
    }
  }

  // Get all accounts
  static List<Account> getAccounts() {
    try {
      if (!Hive.isBoxOpen(accountsBox)) {
        print('⚠️  Accounts box not open, returning empty list');
        return [];
      }
      final box = Hive.box<Account>(accountsBox);
      return box.values.toList();
    } catch (e) {
      print('❌ Error getting accounts: $e');
      return [];
    }
  }

  // Get account by name
  static Account? getAccountByName(String name) {
    try {
      final box = Hive.box<Account>(accountsBox);
      return box.values.firstWhere(
        (account) => account.name == name,
        orElse: () => throw Exception('Account not found'),
      );
    } catch (e) {
      print('❌ Error getting account by name: $e');
      return null;
    }
  }

  // Get all bills
  static List<Bill> getBills() {
    try {
      if (!Hive.isBoxOpen(billsBox)) {
        print('⚠️  Bills box not open, returning empty list');
        return [];
      }
      final box = Hive.box<Bill>(billsBox);
      return box.values.toList();
    } catch (e) {
      print('❌ Error getting bills: $e');
      return [];
    }
  }

  // Get bills for current viewing month
  static List<Bill> getBillsForMonth(DateTime month) {
    return getBills();
  }

  // Get all transactions
  static List<Transaction> getTransactions() {
    try {
      if (!Hive.isBoxOpen(transactionsBox)) {
        print('⚠️  Transactions box not open, returning empty list');
        return [];
      }
      final box = Hive.box<Transaction>(transactionsBox);
      return box.values.toList();
    } catch (e) {
      print('❌ Error getting transactions: $e');
      return [];
    }
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
    try {
      if (!Hive.isBoxOpen(configBox)) {
        print('⚠️  Config box not open, returning null');
        return null;
      }
      final box = Hive.box<Config>(configBox);
      return box.get('config');
    } catch (e) {
      print('❌ Error getting config: $e');
      return null;
    }
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
