import 'package:flutter/foundation.dart';
import '../models/account.dart';
import '../models/bill.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../models/recurring_transaction.dart';
import '../models/goal.dart';
import '../models/config.dart';
import '../services/budget_service.dart';

class BudgetProvider with ChangeNotifier {
  Config? _config;
  List<Account> _accounts = [];
  List<Bill> _bills = [];
  List<Transaction> _transactions = [];
  List<Category> _categories = [];
  List<RecurringTransaction> _recurringTransactions = [];
  List<Goal> _goals = [];

  // Getters
  Config? get config => _config;
  List<Account> get accounts => _accounts;
  List<Bill> get bills => _bills;
  List<Transaction> get transactions => _transactions;
  List<Category> get categories => _categories;
  List<RecurringTransaction> get recurringTransactions =>
      _recurringTransactions;
  List<Goal> get goals => _goals;

  DateTime get viewingMonth => _config?.viewingMonth ?? DateTime.now();

  // Initialize and load all data
  Future<void> loadData() async {
    _config = BudgetService.getConfig();
    _accounts = BudgetService.getAccounts();
    _bills = BudgetService.getBills();
    _transactions = BudgetService.getTransactions();
    _categories = BudgetService.getCategories();
    _recurringTransactions = BudgetService.getRecurringTransactions();
    _goals = BudgetService.getGoals();
    notifyListeners();
  }

  // Config operations
  Future<void> updateConfig(Config config) async {
    await BudgetService.updateConfig(config);
    _config = config;
    notifyListeners();
  }

  Future<void> setViewingMonth(DateTime month) async {
    if (_config != null) {
      _config!.viewingMonth = month;
      await BudgetService.updateConfig(_config!);
      notifyListeners();
    }
  }

  // Account operations
  Future<void> addAccount(Account account) async {
    await BudgetService.addAccount(account);
    _accounts = BudgetService.getAccounts();
    notifyListeners();
  }

  Future<void> updateAccount(Account account) async {
    await account.save();
    _accounts = BudgetService.getAccounts();
    notifyListeners();
  }

  Future<void> deleteAccount(Account account) async {
    await account.delete();
    _accounts = BudgetService.getAccounts();
    notifyListeners();
  }

  // Bill operations
  Future<void> addBill(Bill bill) async {
    await BudgetService.addBill(bill);
    _bills = BudgetService.getBills();
    notifyListeners();
  }

  Future<void> updateBill(Bill bill) async {
    await bill.save();
    _bills = BudgetService.getBills();
    notifyListeners();
  }

  Future<void> deleteBill(Bill bill) async {
    await bill.delete();
    _bills = BudgetService.getBills();
    notifyListeners();
  }

  Future<void> toggleBillPayment(Bill bill) async {
    await BudgetService.updateBillPayment(bill, !bill.paid);
    _bills = BudgetService.getBills();
    notifyListeners();
  }

  // Transaction operations
  Future<void> addTransaction(Transaction transaction) async {
    await BudgetService.addTransaction(transaction);
    _transactions = BudgetService.getTransactions();
    notifyListeners();
  }

  Future<void> updateTransaction(Transaction transaction) async {
    await transaction.save();
    _transactions = BudgetService.getTransactions();
    notifyListeners();
  }

  Future<void> deleteTransaction(Transaction transaction) async {
    await transaction.delete();
    _transactions = BudgetService.getTransactions();
    notifyListeners();
  }

  // Category operations
  Future<void> addCategory(Category category) async {
    await BudgetService.addCategory(category);
    _categories = BudgetService.getCategories();
    notifyListeners();
  }

  Future<void> updateCategory(Category category) async {
    await category.save();
    _categories = BudgetService.getCategories();
    notifyListeners();
  }

  Future<void> deleteCategory(Category category) async {
    if (!category.isDefault) {
      await category.delete();
      _categories = BudgetService.getCategories();
      notifyListeners();
    }
  }

  // Recurring transaction operations
  Future<void> addRecurringTransaction(
      RecurringTransaction recurringTransaction) async {
    await BudgetService.addRecurringTransaction(recurringTransaction);
    _recurringTransactions = BudgetService.getRecurringTransactions();
    notifyListeners();
  }

  Future<void> updateRecurringTransaction(
      RecurringTransaction recurringTransaction) async {
    await recurringTransaction.save();
    _recurringTransactions = BudgetService.getRecurringTransactions();
    notifyListeners();
  }

  Future<void> deleteRecurringTransaction(
      RecurringTransaction recurringTransaction) async {
    await recurringTransaction.delete();
    _recurringTransactions = BudgetService.getRecurringTransactions();
    notifyListeners();
  }

  Future<void> processRecurringTransactions() async {
    await BudgetService.processRecurringTransactions();
    _transactions = BudgetService.getTransactions();
    _recurringTransactions = BudgetService.getRecurringTransactions();
    notifyListeners();
  }

  // Goal operations
  Future<void> addGoal(Goal goal) async {
    await BudgetService.addGoal(goal);
    _goals = BudgetService.getGoals();
    notifyListeners();
  }

  Future<void> updateGoal(Goal goal) async {
    await goal.save();
    _goals = BudgetService.getGoals();
    notifyListeners();
  }

  Future<void> deleteGoal(Goal goal) async {
    await goal.delete();
    _goals = BudgetService.getGoals();
    notifyListeners();
  }

  Future<void> addGoalContribution(Goal goal, double amount) async {
    await goal.addContribution(amount);
    _goals = BudgetService.getGoals();
    notifyListeners();
  }

  // Computed values
  double getTotalBalance() => BudgetService.getTotalBalance();
  double getTotalAvailable() => BudgetService.getTotalAvailable();
  double getMonthIncome(DateTime month) =>
      BudgetService.getMonthIncome(month);
  double getMonthExpenses(DateTime month) =>
      BudgetService.getMonthExpenses(month);
  double getBillsPaidThisMonth(DateTime month) =>
      BudgetService.getBillsPaidThisMonth(month);
  double getUnpaidBillsTotal(DateTime month) =>
      BudgetService.getUnpaidBillsTotal(month);
  
  List<Transaction> getTransactionsForMonth(DateTime month) =>
      BudgetService.getTransactionsForMonth(month);
  
  List<Bill> getBillsForMonth(DateTime month) =>
      BudgetService.getBillsForMonth(month);
}
