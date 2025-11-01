import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/account.dart';
import '../models/bill.dart';
import '../models/transaction.dart';
import '../models/config.dart';

class DataExportService {
  /// Export all app data to JSON
  static Future<Map<String, dynamic>> exportAllData() async {
    final accountsBox = Hive.box<Account>('accounts');
    final billsBox = Hive.box<Bill>('bills');
    final transactionsBox = Hive.box<Transaction>('transactions');
    final configBox = Hive.box<Config>('config');

    // Convert accounts to JSON
    final accounts = accountsBox.values.map((account) => {
      'name': account.name,
      'startingBalance': account.startingBalance,
      'overdraftLimit': account.overdraftLimit,
      'overdraftUsed': account.overdraftUsed,
      'autoPaychecks': account.autoPaychecks,
      'icon': account.icon,
    }).toList();

    // Convert bills to JSON
    final bills = billsBox.values.map((bill) => {
      'name': bill.name,
      'defaultAmount': bill.defaultAmount,
      'dueDay': bill.dueDay,
      'account': bill.account,
      'notes': bill.notes,
      'monthlyPaidStatus': bill.monthlyPaidStatus,
      'monthlyAmounts': bill.monthlyAmounts,
    }).toList();

    // Convert transactions to JSON
    final transactions = transactionsBox.values.map((transaction) => {
      'description': transaction.description,
      'amount': transaction.amount,
      'date': transaction.date.toIso8601String(),
      'category': transaction.category,
      'type': transaction.type,
      'account': transaction.account,
      'notes': transaction.notes,
    }).toList();

    // Convert config to JSON
    final config = configBox.get('config');
    final configJson = config != null ? {
      'firstPaycheckDate': config.firstPaycheckDate.toIso8601String(),
      'paycheckAmount': config.paycheckAmount,
      'payFrequencyDays': config.payFrequencyDays,
      'defaultDepositAccount': config.defaultDepositAccount,
      'viewingMonth': config.viewingMonth.toIso8601String(),
      'splitPaycheck': config.splitPaycheck,
      'primaryDepositAmount': config.primaryDepositAmount,
      'secondaryDepositAccount': config.secondaryDepositAccount,
    } : null;

    return {
      'exportDate': DateTime.now().toIso8601String(),
      'appVersion': '1.0.0',
      'accounts': accounts,
      'bills': bills,
      'transactions': transactions,
      'config': configJson,
    };
  }

  /// Export data and share as file
  static Future<void> exportAndShare() async {
    try {
      // Get export data
      final data = await exportAllData();
      
      // Convert to pretty JSON
      final jsonString = const JsonEncoder.withIndent('  ').convert(data);
      
      // Get temporary directory
      final tempDir = await getTemporaryDirectory();
      final fileName = 'budget_backup_${DateTime.now().millisecondsSinceEpoch}.json';
      final file = File('${tempDir.path}/$fileName');
      
      // Write file
      await file.writeAsString(jsonString);
      
      // Share file
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Budget Manager Backup',
        text: 'My budget data backup - ${DateTime.now().toString().split('.')[0]}',
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Import data from JSON file
  static Future<void> importFromFile() async {
    try {
      // Pick file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.isEmpty) {
        throw Exception('No file selected');
      }

      final file = File(result.files.single.path!);
      final jsonString = await file.readAsString();
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      await importData(data);
    } catch (e) {
      rethrow;
    }
  }

  /// Import data from JSON map
  static Future<void> importData(Map<String, dynamic> data) async {
    final accountsBox = Hive.box<Account>('accounts');
    final billsBox = Hive.box<Bill>('bills');
    final transactionsBox = Hive.box<Transaction>('transactions');
    final configBox = Hive.box<Config>('config');

    // Clear existing data
    await accountsBox.clear();
    await billsBox.clear();
    await transactionsBox.clear();
    await configBox.clear();

    // Import accounts
    if (data['accounts'] != null) {
      for (var accountData in data['accounts']) {
        final account = Account(
          name: accountData['name'],
          startingBalance: accountData['startingBalance']?.toDouble() ?? 0.0,
          overdraftLimit: accountData['overdraftLimit']?.toDouble() ?? 0.0,
          overdraftUsed: accountData['overdraftUsed']?.toDouble() ?? 0.0,
          autoPaychecks: accountData['autoPaychecks'] ?? false,
          icon: accountData['icon'] ?? 0xe54c,
        );
        await accountsBox.add(account);
      }
    }

    // Import bills
    if (data['bills'] != null) {
      for (var billData in data['bills']) {
        final bill = Bill(
          name: billData['name'],
          defaultAmount: billData['defaultAmount']?.toDouble() ?? 0.0,
          dueDay: billData['dueDay'] ?? 1,
          account: billData['account'] ?? '',
          notes: billData['notes'] ?? '',
        );
        
        // Restore monthly data
        if (billData['monthlyPaidStatus'] != null) {
          bill.monthlyPaidStatus = Map<String, bool>.from(
            billData['monthlyPaidStatus']
          );
        }
        if (billData['monthlyAmounts'] != null) {
          bill.monthlyAmounts = Map<String, double>.from(
            (billData['monthlyAmounts'] as Map).map(
              (key, value) => MapEntry(key.toString(), value.toDouble())
            )
          );
        }
        
        await billsBox.add(bill);
      }
    }

    // Import transactions
    if (data['transactions'] != null) {
      for (var transactionData in data['transactions']) {
        final transaction = Transaction(
          description: transactionData['description'] ?? '',
          amount: transactionData['amount']?.toDouble() ?? 0.0,
          date: DateTime.parse(transactionData['date']),
          category: transactionData['category'] ?? 'Other',
          type: transactionData['type'] ?? 'Expense',
          account: transactionData['account'] ?? '',
          notes: transactionData['notes'],
        );
        await transactionsBox.add(transaction);
      }
    }

    // Import config
    if (data['config'] != null) {
      final configData = data['config'];
      final config = Config(
        firstPaycheckDate: DateTime.parse(configData['firstPaycheckDate']),
        paycheckAmount: configData['paycheckAmount']?.toDouble() ?? 0.0,
        payFrequencyDays: configData['payFrequencyDays'] ?? 14,
        defaultDepositAccount: configData['defaultDepositAccount'] ?? '',
        viewingMonth: DateTime.parse(configData['viewingMonth']),
        splitPaycheck: configData['splitPaycheck'] ?? false,
        primaryDepositAmount: configData['primaryDepositAmount']?.toDouble(),
        secondaryDepositAccount: configData['secondaryDepositAccount'],
      );
      await configBox.put('config', config);
    }
  }

  /// Get a preview of what will be imported
  static Future<Map<String, int>> getImportPreview(Map<String, dynamic> data) async {
    return {
      'accounts': (data['accounts'] as List?)?.length ?? 0,
      'bills': (data['bills'] as List?)?.length ?? 0,
      'transactions': (data['transactions'] as List?)?.length ?? 0,
      'hasConfig': data['config'] != null ? 1 : 0,
    };
  }
}
