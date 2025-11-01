import 'package:hive/hive.dart';

part 'bill.g.dart';

@HiveType(typeId: 1)
class Bill extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  double defaultAmount;

  @HiveField(2)
  int dueDay;

  @HiveField(3)
  String account;

  @HiveField(4)
  String notes;

  @HiveField(5)
  double amount;

  @HiveField(6)
  bool paid;

  @HiveField(7)
  DateTime? paidDate;

  @HiveField(8)
  Map<String, bool> monthlyPaidStatus; // Key: "2025-11", Value: true/false

  @HiveField(9)
  Map<String, double> monthlyAmounts; // Key: "2025-11", Value: actual amount paid

  Bill({
    required this.name,
    required this.defaultAmount,
    required this.dueDay,
    required this.account,
    required this.notes,
    double? amount,
    this.paid = false,
    this.paidDate,
    Map<String, bool>? monthlyPaidStatus,
    Map<String, double>? monthlyAmounts,
  }) : amount = amount ?? defaultAmount,
       monthlyPaidStatus = monthlyPaidStatus ?? {},
       monthlyAmounts = monthlyAmounts ?? {};

  // Get due date for current viewing month
  DateTime getDueDate(DateTime viewingMonth) {
    return DateTime(viewingMonth.year, viewingMonth.month, dueDay);
  }

  // Check if bill is past due for a specific month
  bool isPastDue(DateTime viewingMonth) {
    final dueDate = getDueDate(viewingMonth);
    return DateTime.now().isAfter(dueDate) && !isPaidForMonth(viewingMonth);
  }

  // Get month key for storage (e.g., "2025-11")
  static String getMonthKey(DateTime month) {
    return '${month.year}-${month.month.toString().padLeft(2, '0')}';
  }

  // Check if paid for a specific month
  bool isPaidForMonth(DateTime month) {
    final key = getMonthKey(month);
    return monthlyPaidStatus[key] ?? false;
  }

  // Get amount for a specific month (returns default if not set)
  double getAmountForMonth(DateTime month) {
    final key = getMonthKey(month);
    return monthlyAmounts[key] ?? defaultAmount;
  }

  // Set amount for a specific month
  void setAmountForMonth(DateTime month, double amount) {
    final key = getMonthKey(month);
    monthlyAmounts[key] = amount;
    
    // Update legacy amount field for current month
    if (_isSameMonth(month, DateTime.now())) {
      this.amount = amount;
    }
  }

  // Mark as paid/unpaid for a specific month
  void setPaidForMonth(DateTime month, bool isPaid) {
    final key = getMonthKey(month);
    monthlyPaidStatus[key] = isPaid;
    
    // Update legacy fields for current month compatibility
    if (_isSameMonth(month, DateTime.now())) {
      paid = isPaid;
      paidDate = isPaid ? DateTime.now() : null;
    }
  }

  bool _isSameMonth(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month;
  }
}
