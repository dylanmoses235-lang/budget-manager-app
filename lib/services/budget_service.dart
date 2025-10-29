import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/account.dart';
import '../models/bill.dart';
import '../models/transaction.dart';
import '../models/config.dart';
import '../models/category.dart';
import '../models/recurring_transaction.dart';
import '../models/goal.dart';
import '../data/budget_data.dart';

class BudgetService {
  static const String accountsBox = 'accounts';
  static const String billsBox = 'bills';
  static const String transactionsBox = 'transactions';
  static const String configBox = 'config';
  static const String categoriesBox = 'categories';
  static const String recurringTransactionsBox = 'recurring_transactions';
  static const String goalsBox = 'goals';

  // Initialize Hive and register adapters
  static Future<void> initialize() async {
    await Hive.initFlutter();

    // Register type adapters
    Hive.registerAdapter(AccountAdapter());
    Hive.registerAdapter(BillAdapter());
    Hive.registerAdapter(TransactionAdapter());
    Hive.registerAdapter(ConfigAdapter());
    Hive.registerAdapter(CategoryAdapter());
    Hive.registerAdapter(RecurringTransactionAdapter());
    Hive.registerAdapter(GoalAdapter());

    // Open boxes
    await Hive.openBox<Account>(accountsBox);
    await Hive.openBox<Bill>(billsBox);
    await Hive.openBox<Transaction>(transactionsBox);
    await Hive.openBox<Config>(configBox);
    await Hive.openBox<Category>(categoriesBox);
    await Hive.openBox<RecurringTransaction>(recurringTransactionsBox);
    await Hive.openBox<Goal>(goalsBox);

    // Initialize default data if first run
    await _initializeDefaultData();
  }

  static Future<void> _initializeDefaultData() async {
    final accountsBoxRef = Hive.box<Account>(accountsBox);
    final billsBoxRef = Hive.box<Bill>(billsBox);
    final configBoxRef = Hive.box<Config>(configBox);
    final categoriesBoxRef = Hive.box<Category>(categoriesBox);

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
      );
      await configBoxRef.put('config', config);
    }

    // Initialize default categories if empty
    if (categoriesBoxRef.isEmpty) {
      final defaultCategories = [
        Category(
          name: 'Groceries',
          colorValue: Colors.green.value,
          iconCodePoint: Icons.shopping_cart.codePoint,
          monthlyBudget: 500,
          isDefault: true,
        ),
        Category(
          name: 'Utilities',
          colorValue: Colors.blue.value,
          iconCodePoint: Icons.bolt.codePoint,
          monthlyBudget: 300,
          isDefault: true,
        ),
        Category(
          name: 'Transportation',
          colorValue: Colors.orange.value,
          iconCodePoint: Icons.directions_car.codePoint,
          monthlyBudget: 200,
          isDefault: true,
        ),
        Category(
          name: 'Entertainment',
          colorValue: Colors.purple.value,
          iconCodePoint: Icons.movie.codePoint,
          monthlyBudget: 150,
          isDefault: true,
        ),
        Category(
          name: 'Healthcare',
          colorValue: Colors.red.value,
          iconCodePoint: Icons.local_hospital.codePoint,
          monthlyBudget: 200,
          isDefault: true,
        ),
        Category(
          name: 'Dining',
          colorValue: Colors.pink.value,
          iconCodePoint: Icons.restaurant.codePoint,
          monthlyBudget: 300,
          isDefault: true,
        ),
        Category(
          name: 'Shopping',
          colorValue: Colors.teal.value,
          iconCodePoint: Icons.shopping_bag.codePoint,
          monthlyBudget: 200,
          isDefault: true,
        ),
        Category(
          name: 'Other',
          colorValue: Colors.grey.value,
          iconCodePoint: Icons.category.codePoint,
          monthlyBudget: 0,
          isDefault: true,
        ),
      ];

      for (var category in defaultCategories) {
        await categoriesBoxRef.add(category);
      }
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

  // Update bill payment status
  static Future<void> updateBillPayment(Bill bill, bool paid) async {
    bill.paid = paid;
    bill.paidDate = paid ? DateTime.now() : null;
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
        .where((b) => b.paid)
        .fold(0, (sum, b) => sum + b.amount);
  }

  // Get unpaid bills total
  static double getUnpaidBillsTotal(DateTime month) {
    return getBillsForMonth(month)
        .where((b) => !b.paid)
        .fold(0, (sum, b) => sum + b.amount);
  }

  // ============== Category Methods ==============
  
  // Get all categories
  static List<Category> getCategories() {
    return Hive.box<Category>(categoriesBox).values.toList();
  }

  // Get category by name
  static Category? getCategoryByName(String name) {
    try {
      return Hive.box<Category>(categoriesBox)
          .values
          .firstWhere((category) => category.name == name);
    } catch (e) {
      return null;
    }
  }

  // Add category
  static Future<void> addCategory(Category category) async {
    await Hive.box<Category>(categoriesBox).add(category);
  }

  // Get spending by category for a month
  static Map<String, double> getCategorySpending(DateTime month) {
    final transactions = getTransactionsForMonth(month);
    final categorySpending = <String, double>{};

    for (var transaction in transactions) {
      if (transaction.isExpense) {
        categorySpending[transaction.category] =
            (categorySpending[transaction.category] ?? 0) +
                transaction.amount.abs();
      }
    }

    return categorySpending;
  }

  // ============== Recurring Transaction Methods ==============

  // Get all recurring transactions
  static List<RecurringTransaction> getRecurringTransactions() {
    return Hive.box<RecurringTransaction>(recurringTransactionsBox)
        .values
        .toList();
  }

  // Get active recurring transactions
  static List<RecurringTransaction> getActiveRecurringTransactions() {
    return getRecurringTransactions().where((rt) => rt.isActive).toList();
  }

  // Add recurring transaction
  static Future<void> addRecurringTransaction(
      RecurringTransaction recurringTransaction) async {
    await Hive.box<RecurringTransaction>(recurringTransactionsBox)
        .add(recurringTransaction);
  }

  // Process recurring transactions (generate due transactions)
  static Future<void> processRecurringTransactions() async {
    final recurringTransactions = getActiveRecurringTransactions();

    for (var recurring in recurringTransactions) {
      if (recurring.shouldGenerate()) {
        final transaction = recurring.generateTransaction();
        await addTransaction(transaction);
        await recurring.markGenerated();
      }
    }
  }

  // ============== Goal Methods ==============

  // Get all goals
  static List<Goal> getGoals() {
    return Hive.box<Goal>(goalsBox).values.toList();
  }

  // Get active goals (not completed)
  static List<Goal> getActiveGoals() {
    return getGoals().where((goal) => !goal.isCompleted).toList();
  }

  // Get completed goals
  static List<Goal> getCompletedGoals() {
    return getGoals().where((goal) => goal.isCompleted).toList();
  }

  // Add goal
  static Future<void> addGoal(Goal goal) async {
    await Hive.box<Goal>(goalsBox).add(goal);
  }

  // Get total goal progress
  static double getTotalGoalsProgress() {
    final goals = getActiveGoals();
    if (goals.isEmpty) return 0;

    double totalTarget = 0;
    double totalCurrent = 0;

    for (var goal in goals) {
      totalTarget += goal.targetAmount;
      totalCurrent += goal.currentAmount;
    }

    return totalTarget > 0 ? (totalCurrent / totalTarget * 100) : 0;
  }
}
