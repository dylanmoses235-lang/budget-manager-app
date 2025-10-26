import 'package:hive/hive.dart';

part 'account.g.dart';

@HiveType(typeId: 0)
class Account extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  double startingBalance;

  @HiveField(2)
  double overdraftLimit;

  @HiveField(3)
  double overdraftUsed;

  @HiveField(4)
  bool autoPaychecks;

  @HiveField(5)
  int icon;

  Account({
    required this.name,
    required this.startingBalance,
    required this.overdraftLimit,
    required this.overdraftUsed,
    required this.autoPaychecks,
    required this.icon,
  });

  // Calculate available balance (base balance + transactions - overdraft used)
  double get baseBalance => startingBalance;
  
  // Total available includes overdraft
  double get totalAvailable => baseBalance + overdraftLimit - overdraftUsed;
  
  // Actual balance (will be calculated with transactions)
  double get actualBalance => startingBalance;
}
