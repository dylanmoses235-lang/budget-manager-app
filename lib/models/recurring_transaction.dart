import 'package:hive/hive.dart';
import 'transaction.dart';

part 'recurring_transaction.g.dart';

enum RecurrenceFrequency {
  daily,
  weekly,
  biweekly,
  monthly,
  quarterly,
  yearly,
}

@HiveType(typeId: 5)
class RecurringTransaction extends HiveObject {
  @HiveField(0)
  String description;

  @HiveField(1)
  String type; // Income, Expense, Bill, Transfer

  @HiveField(2)
  String category;

  @HiveField(3)
  String account;

  @HiveField(4)
  double amount;

  @HiveField(5)
  DateTime startDate;

  @HiveField(6)
  DateTime? endDate;

  @HiveField(7)
  int frequency; // Store as int for Hive

  @HiveField(8)
  int dayOfMonth; // For monthly recurrence (1-31)

  @HiveField(9)
  bool isActive;

  @HiveField(10)
  DateTime? lastGenerated;

  @HiveField(11)
  String? notes;

  RecurringTransaction({
    required this.description,
    required this.type,
    required this.category,
    required this.account,
    required this.amount,
    required this.startDate,
    this.endDate,
    required this.frequency,
    this.dayOfMonth = 1,
    this.isActive = true,
    this.lastGenerated,
    this.notes,
  });

  RecurrenceFrequency get frequencyEnum =>
      RecurrenceFrequency.values[frequency];

  String get frequencyLabel {
    switch (frequencyEnum) {
      case RecurrenceFrequency.daily:
        return 'Daily';
      case RecurrenceFrequency.weekly:
        return 'Weekly';
      case RecurrenceFrequency.biweekly:
        return 'Bi-weekly';
      case RecurrenceFrequency.monthly:
        return 'Monthly';
      case RecurrenceFrequency.quarterly:
        return 'Quarterly';
      case RecurrenceFrequency.yearly:
        return 'Yearly';
    }
  }

  // Get next occurrence date
  DateTime? getNextOccurrence() {
    if (!isActive) return null;
    
    final now = DateTime.now();
    DateTime nextDate = lastGenerated ?? startDate;

    // If end date is set and we've passed it, return null
    if (endDate != null && now.isAfter(endDate!)) return null;

    // Calculate next date based on frequency
    switch (frequencyEnum) {
      case RecurrenceFrequency.daily:
        nextDate = nextDate.add(const Duration(days: 1));
        break;
      case RecurrenceFrequency.weekly:
        nextDate = nextDate.add(const Duration(days: 7));
        break;
      case RecurrenceFrequency.biweekly:
        nextDate = nextDate.add(const Duration(days: 14));
        break;
      case RecurrenceFrequency.monthly:
        nextDate = DateTime(
          nextDate.month == 12 ? nextDate.year + 1 : nextDate.year,
          nextDate.month == 12 ? 1 : nextDate.month + 1,
          dayOfMonth,
        );
        break;
      case RecurrenceFrequency.quarterly:
        nextDate = DateTime(
          nextDate.month >= 10 ? nextDate.year + 1 : nextDate.year,
          (nextDate.month + 3) % 12,
          dayOfMonth,
        );
        break;
      case RecurrenceFrequency.yearly:
        nextDate = DateTime(
          nextDate.year + 1,
          nextDate.month,
          dayOfMonth,
        );
        break;
    }

    return nextDate;
  }

  // Check if a transaction should be generated
  bool shouldGenerate() {
    if (!isActive) return false;

    final now = DateTime.now();
    final next = getNextOccurrence();

    if (next == null) return false;
    if (next.isAfter(now)) return false;
    if (endDate != null && next.isAfter(endDate!)) return false;

    return true;
  }

  // Generate a transaction from this recurring transaction
  Transaction generateTransaction() {
    return Transaction(
      date: DateTime.now(),
      type: type,
      description: description,
      category: category,
      account: account,
      amount: amount,
      notes: notes,
    );
  }

  // Update last generated date
  Future<void> markGenerated() async {
    lastGenerated = DateTime.now();
    await save();
  }
}
