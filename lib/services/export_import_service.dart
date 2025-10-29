import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:csv/csv.dart';
import '../models/account.dart';
import '../models/bill.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../models/goal.dart';
import '../models/config.dart';
import 'budget_service.dart';

class ExportImportService {
  // Export all data to JSON
  static Future<String> exportToJSON() async {
    final data = {
      'accounts': BudgetService.getAccounts().map((a) => _accountToMap(a)).toList(),
      'bills': BudgetService.getBills().map((b) => _billToMap(b)).toList(),
      'transactions': BudgetService.getTransactions().map((t) => _transactionToMap(t)).toList(),
      'categories': BudgetService.getCategories().map((c) => _categoryToMap(c)).toList(),
      'goals': BudgetService.getGoals().map((g) => _goalToMap(g)).toList(),
      'config': _configToMap(BudgetService.getConfig()!),
      'exportDate': DateTime.now().toIso8601String(),
      'version': '1.0.0',
    };

    final jsonString = const JsonEncoder.withIndent('  ').convert(data);
    return jsonString;
  }

  // Export transactions to CSV
  static Future<String> exportTransactionsToCSV({DateTime? startDate, DateTime? endDate}) async {
    final transactions = BudgetService.getTransactions();
    
    // Filter by date if provided
    final filteredTransactions = transactions.where((t) {
      if (startDate != null && t.date.isBefore(startDate)) return false;
      if (endDate != null && t.date.isAfter(endDate)) return false;
      return true;
    }).toList();

    // Sort by date
    filteredTransactions.sort((a, b) => b.date.compareTo(a.date));

    // Create CSV data
    final List<List<dynamic>> rows = [
      ['Date', 'Type', 'Description', 'Category', 'Account', 'Amount', 'Notes'],
    ];

    for (var transaction in filteredTransactions) {
      rows.add([
        transaction.date.toIso8601String(),
        transaction.type,
        transaction.description,
        transaction.category,
        transaction.account,
        transaction.amount,
        transaction.notes ?? '',
      ]);
    }

    return const ListToCsvConverter().convert(rows);
  }

  // Save string to file and share
  static Future<void> saveAndShare(String content, String filename) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$filename');
      await file.writeAsString(content);
      
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Budget Manager Export',
      );
    } catch (e) {
      rethrow;
    }
  }

  // Import data from JSON
  static Future<void> importFromJSON(String jsonString) async {
    try {
      final data = json.decode(jsonString) as Map<String, dynamic>;
      
      // Import accounts
      if (data.containsKey('accounts')) {
        for (var accountData in data['accounts']) {
          final account = _accountFromMap(accountData);
          await BudgetService.addAccount(account);
        }
      }

      // Import categories
      if (data.containsKey('categories')) {
        for (var categoryData in data['categories']) {
          final category = _categoryFromMap(categoryData);
          await BudgetService.addCategory(category);
        }
      }

      // Import bills
      if (data.containsKey('bills')) {
        for (var billData in data['bills']) {
          final bill = _billFromMap(billData);
          await BudgetService.addBill(bill);
        }
      }

      // Import transactions
      if (data.containsKey('transactions')) {
        for (var transactionData in data['transactions']) {
          final transaction = _transactionFromMap(transactionData);
          await BudgetService.addTransaction(transaction);
        }
      }

      // Import goals
      if (data.containsKey('goals')) {
        for (var goalData in data['goals']) {
          final goal = _goalFromMap(goalData);
          await BudgetService.addGoal(goal);
        }
      }

      // Import config
      if (data.containsKey('config')) {
        final config = _configFromMap(data['config']);
        await BudgetService.updateConfig(config);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Helper methods for serialization
  static Map<String, dynamic> _accountToMap(Account account) {
    return {
      'name': account.name,
      'startingBalance': account.startingBalance,
      'overdraftLimit': account.overdraftLimit,
      'overdraftUsed': account.overdraftUsed,
      'autoPaychecks': account.autoPaychecks,
      'icon': account.icon,
    };
  }

  static Account _accountFromMap(Map<String, dynamic> map) {
    return Account(
      name: map['name'],
      startingBalance: map['startingBalance'],
      overdraftLimit: map['overdraftLimit'],
      overdraftUsed: map['overdraftUsed'],
      autoPaychecks: map['autoPaychecks'],
      icon: map['icon'],
    );
  }

  static Map<String, dynamic> _billToMap(Bill bill) {
    return {
      'name': bill.name,
      'defaultAmount': bill.defaultAmount,
      'dueDay': bill.dueDay,
      'account': bill.account,
      'notes': bill.notes,
      'amount': bill.amount,
      'paid': bill.paid,
      'paidDate': bill.paidDate?.toIso8601String(),
    };
  }

  static Bill _billFromMap(Map<String, dynamic> map) {
    return Bill(
      name: map['name'],
      defaultAmount: map['defaultAmount'],
      dueDay: map['dueDay'],
      account: map['account'],
      notes: map['notes'],
      amount: map['amount'],
      paid: map['paid'],
      paidDate: map['paidDate'] != null ? DateTime.parse(map['paidDate']) : null,
    );
  }

  static Map<String, dynamic> _transactionToMap(Transaction transaction) {
    return {
      'date': transaction.date.toIso8601String(),
      'type': transaction.type,
      'description': transaction.description,
      'category': transaction.category,
      'account': transaction.account,
      'amount': transaction.amount,
      'notes': transaction.notes,
    };
  }

  static Transaction _transactionFromMap(Map<String, dynamic> map) {
    return Transaction(
      date: DateTime.parse(map['date']),
      type: map['type'],
      description: map['description'],
      category: map['category'],
      account: map['account'],
      amount: map['amount'],
      notes: map['notes'],
    );
  }

  static Map<String, dynamic> _categoryToMap(Category category) {
    return {
      'name': category.name,
      'colorValue': category.colorValue,
      'iconCodePoint': category.iconCodePoint,
      'monthlyBudget': category.monthlyBudget,
      'isDefault': category.isDefault,
    };
  }

  static Category _categoryFromMap(Map<String, dynamic> map) {
    return Category(
      name: map['name'],
      colorValue: map['colorValue'],
      iconCodePoint: map['iconCodePoint'],
      monthlyBudget: map['monthlyBudget'],
      isDefault: map['isDefault'],
    );
  }

  static Map<String, dynamic> _goalToMap(Goal goal) {
    return {
      'name': goal.name,
      'targetAmount': goal.targetAmount,
      'currentAmount': goal.currentAmount,
      'startDate': goal.startDate.toIso8601String(),
      'targetDate': goal.targetDate.toIso8601String(),
      'colorValue': goal.colorValue,
      'iconCodePoint': goal.iconCodePoint,
      'notes': goal.notes,
      'isCompleted': goal.isCompleted,
      'completedDate': goal.completedDate?.toIso8601String(),
    };
  }

  static Goal _goalFromMap(Map<String, dynamic> map) {
    return Goal(
      name: map['name'],
      targetAmount: map['targetAmount'],
      currentAmount: map['currentAmount'],
      startDate: DateTime.parse(map['startDate']),
      targetDate: DateTime.parse(map['targetDate']),
      colorValue: map['colorValue'],
      iconCodePoint: map['iconCodePoint'],
      notes: map['notes'],
      isCompleted: map['isCompleted'],
      completedDate: map['completedDate'] != null
          ? DateTime.parse(map['completedDate'])
          : null,
    );
  }

  static Map<String, dynamic> _configToMap(Config config) {
    return {
      'firstPaycheckDate': config.firstPaycheckDate.toIso8601String(),
      'paycheckAmount': config.paycheckAmount,
      'payFrequencyDays': config.payFrequencyDays,
      'defaultDepositAccount': config.defaultDepositAccount,
      'viewingMonth': config.viewingMonth.toIso8601String(),
    };
  }

  static Config _configFromMap(Map<String, dynamic> map) {
    return Config(
      firstPaycheckDate: DateTime.parse(map['firstPaycheckDate']),
      paycheckAmount: map['paycheckAmount'],
      payFrequencyDays: map['payFrequencyDays'],
      defaultDepositAccount: map['defaultDepositAccount'],
      viewingMonth: DateTime.parse(map['viewingMonth']),
    );
  }
}
