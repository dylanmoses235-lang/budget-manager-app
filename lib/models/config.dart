import 'package:hive/hive.dart';

part 'config.g.dart';

@HiveType(typeId: 3)
class Config extends HiveObject {
  @HiveField(0)
  DateTime firstPaycheckDate;

  @HiveField(1)
  double paycheckAmount;

  @HiveField(2)
  int payFrequencyDays;

  @HiveField(3)
  String defaultDepositAccount;

  @HiveField(4)
  DateTime viewingMonth;

  Config({
    required this.firstPaycheckDate,
    required this.paycheckAmount,
    required this.payFrequencyDays,
    required this.defaultDepositAccount,
    required this.viewingMonth,
  });

  // Calculate next paycheck date
  DateTime getNextPaycheckDate() {
    final now = DateTime.now();
    DateTime nextPaycheck = firstPaycheckDate;

    while (nextPaycheck.isBefore(now)) {
      nextPaycheck = nextPaycheck.add(Duration(days: payFrequencyDays));
    }

    return nextPaycheck;
  }

  // Calculate how many paychecks have been received
  int getPaychecksReceived() {
    final now = DateTime.now();
    if (now.isBefore(firstPaycheckDate)) return 0;

    final daysSinceFirst = now.difference(firstPaycheckDate).inDays;
    return (daysSinceFirst / payFrequencyDays).floor() + 1;
  }

  // Calculate total paycheck deposits received
  double getTotalPaychecksReceived() {
    return getPaychecksReceived() * paycheckAmount;
  }
}
