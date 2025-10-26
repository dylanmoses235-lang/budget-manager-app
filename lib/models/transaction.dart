import 'package:hive/hive.dart';

part 'transaction.g.dart';

@HiveType(typeId: 2)
class Transaction extends HiveObject {
  @HiveField(0)
  DateTime date;

  @HiveField(1)
  String type; // Income, Expense, Bill, Transfer

  @HiveField(2)
  String description;

  @HiveField(3)
  String category;

  @HiveField(4)
  String account;

  @HiveField(5)
  double amount; // Negative for spending, positive for income

  @HiveField(6)
  String? notes;

  Transaction({
    required this.date,
    required this.type,
    required this.description,
    required this.category,
    required this.account,
    required this.amount,
    this.notes,
  });

  // Check if transaction is in current viewing month
  bool isInMonth(DateTime viewingMonth) {
    return date.year == viewingMonth.year && date.month == viewingMonth.month;
  }

  // Helper to determine if this is income or expense
  bool get isIncome => amount > 0;
  bool get isExpense => amount < 0;
}
