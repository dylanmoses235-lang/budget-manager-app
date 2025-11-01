import '../models/paycheck_plan.dart';
import '../models/bill.dart';
import '../models/config.dart';

class PaycheckPlanner {
  // Generate paycheck plans for the next N paychecks
  static List<PaycheckPlan> generatePlans(
    Config config,
    List<Bill> bills,
    int numberOfPaychecks,
  ) {
    final plans = <PaycheckPlan>[];
    DateTime currentDate = config.firstPaycheckDate;
    final now = DateTime.now();

    // Find the next paycheck date from today
    while (currentDate.isBefore(now)) {
      currentDate = currentDate.add(Duration(days: config.payFrequencyDays));
    }

    // Generate plans for the specified number of paychecks
    for (int i = 0; i < numberOfPaychecks; i++) {
      final nextPaycheckDate = currentDate.add(
        Duration(days: config.payFrequencyDays),
      );

      // Find bills due between this paycheck and the next
      final billsDueInPeriod = _getBillsDueInPeriod(
        bills,
        currentDate,
        nextPaycheckDate,
      );

      final plan = PaycheckPlan(
        paycheckDate: currentDate,
        amount: config.paycheckAmount,
        assignedBillNames: billsDueInPeriod.map((b) => b.name).toList(),
        isReceived: currentDate.isBefore(now) || 
                   _isSameDay(currentDate, now),
      );

      plans.add(plan);
      currentDate = nextPaycheckDate;
    }

    return plans;
  }

  // Get bills due between two dates
  static List<Bill> _getBillsDueInPeriod(
    List<Bill> bills,
    DateTime startDate,
    DateTime endDate,
  ) {
    return bills.where((bill) {
      // Handle bills in current month
      DateTime billDueDate = DateTime(
        startDate.year,
        startDate.month,
        bill.dueDay,
      );

      // If bill day already passed this month, check next month
      if (billDueDate.isBefore(startDate)) {
        billDueDate = DateTime(
          startDate.month == 12 ? startDate.year + 1 : startDate.year,
          startDate.month == 12 ? 1 : startDate.month + 1,
          bill.dueDay,
        );
      }

      // Check if bill is due in the period
      return (billDueDate.isAfter(startDate) || _isSameDay(billDueDate, startDate)) &&
             (billDueDate.isBefore(endDate) || _isSameDay(billDueDate, endDate));
    }).toList();
  }

  // Generate forecasts for all plans
  static List<PaycheckForecast> generateForecasts(
    List<PaycheckPlan> plans,
    List<Bill> bills,
  ) {
    final forecasts = <PaycheckForecast>[];

    for (int i = 0; i < plans.length; i++) {
      final current = plans[i];
      final next = i + 1 < plans.length ? plans[i + 1] : null;

      final forecast = PaycheckForecast.analyze(current, next, bills);
      forecasts.add(forecast);
    }

    return forecasts;
  }

  // Get summary of upcoming financial situation
  static PaycheckSummary getSummary(
    List<PaycheckPlan> plans,
    List<Bill> bills,
  ) {
    if (plans.isEmpty) {
      return PaycheckSummary(
        totalIncome: 0,
        totalBills: 0,
        totalDeficit: 0,
        totalSurplus: 0,
        paychecksWithDeficit: 0,
        criticalAlerts: [],
      );
    }

    double totalIncome = 0;
    double totalBills = 0;
    double totalDeficit = 0;
    double totalSurplus = 0;
    int paychecksWithDeficit = 0;
    List<String> criticalAlerts = [];

    for (final plan in plans) {
      totalIncome += plan.amount;
      final planBills = plan.getTotalBills(bills);
      totalBills += planBills;

      if (plan.hasDeficit(bills)) {
        paychecksWithDeficit++;
        totalDeficit += plan.getDeficitAmount(bills);
        criticalAlerts.add(
          '${_formatDate(plan.paycheckDate)}: Short \$${plan.getDeficitAmount(bills).toStringAsFixed(2)}',
        );
      } else {
        totalSurplus += plan.getSurplusAmount(bills);
      }
    }

    return PaycheckSummary(
      totalIncome: totalIncome,
      totalBills: totalBills,
      totalDeficit: totalDeficit,
      totalSurplus: totalSurplus,
      paychecksWithDeficit: paychecksWithDeficit,
      criticalAlerts: criticalAlerts,
    );
  }

  static String _formatDate(DateTime date) {
    return '${date.month}/${date.day}';
  }

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class PaycheckSummary {
  final double totalIncome;
  final double totalBills;
  final double totalDeficit;
  final double totalSurplus;
  final int paychecksWithDeficit;
  final List<String> criticalAlerts;

  PaycheckSummary({
    required this.totalIncome,
    required this.totalBills,
    required this.totalDeficit,
    required this.totalSurplus,
    required this.paychecksWithDeficit,
    required this.criticalAlerts,
  });

  double get netAmount => totalIncome - totalBills;
  bool get hasDeficits => paychecksWithDeficit > 0;
}
