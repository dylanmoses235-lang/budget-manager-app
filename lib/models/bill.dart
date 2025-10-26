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

  Bill({
    required this.name,
    required this.defaultAmount,
    required this.dueDay,
    required this.account,
    required this.notes,
    double? amount,
    this.paid = false,
    this.paidDate,
  }) : amount = amount ?? defaultAmount;

  // Get due date for current viewing month
  DateTime getDueDate(DateTime viewingMonth) {
    return DateTime(viewingMonth.year, viewingMonth.month, dueDay);
  }

  // Check if bill is past due
  bool isPastDue(DateTime viewingMonth) {
    final dueDate = getDueDate(viewingMonth);
    return DateTime.now().isAfter(dueDate) && !paid;
  }
}
