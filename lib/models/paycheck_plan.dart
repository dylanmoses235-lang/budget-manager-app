import 'package:hive/hive.dart';
import 'bill.dart';

part 'paycheck_plan.g.dart';

@HiveType(typeId: 4)
class PaycheckPlan extends HiveObject {
  @HiveField(0)
  DateTime paycheckDate;

  @HiveField(1)
  double amount;

  @HiveField(2)
  List<String> assignedBillNames; // Names of bills to pay from this paycheck

  @HiveField(3)
  bool isReceived;

  PaycheckPlan({
    required this.paycheckDate,
    required this.amount,
    required this.assignedBillNames,
    this.isReceived = false,
  });

  // Calculate total bills assigned to this paycheck
  double getTotalBills(List<Bill> allBills) {
    final month = DateTime(paycheckDate.year, paycheckDate.month, 1);
    return allBills
        .where((bill) => assignedBillNames.contains(bill.name))
        .fold(0, (sum, bill) => sum + bill.getAmountForMonth(month));
  }

  // Calculate remaining amount after bills
  double getRemainingAmount(List<Bill> allBills) {
    return amount - getTotalBills(allBills);
  }

  // Check if this paycheck has a deficit
  bool hasDeficit(List<Bill> allBills) {
    return getRemainingAmount(allBills) < 0;
  }

  // Get the deficit amount (positive number)
  double getDeficitAmount(List<Bill> allBills) {
    final remaining = getRemainingAmount(allBills);
    return remaining < 0 ? remaining.abs() : 0;
  }

  // Get the surplus amount
  double getSurplusAmount(List<Bill> allBills) {
    final remaining = getRemainingAmount(allBills);
    return remaining > 0 ? remaining : 0;
  }

  // Get bills due before next paycheck
  List<Bill> getBillsDueBeforeNext(List<Bill> allBills, DateTime nextPaycheckDate) {
    return allBills.where((bill) {
      // Calculate bill due date in the current month
      final billDueDate = DateTime(
        paycheckDate.year,
        paycheckDate.month,
        bill.dueDay,
      );
      
      // Bill is due after this paycheck but before next
      return billDueDate.isAfter(paycheckDate) &&
             billDueDate.isBefore(nextPaycheckDate);
    }).toList();
  }
}

// Helper class for paycheck forecasting
class PaycheckForecast {
  final PaycheckPlan currentPlan;
  final PaycheckPlan? nextPlan;
  final double recommendedSavings;
  final String savingsReason;
  final bool needsAttention;

  PaycheckForecast({
    required this.currentPlan,
    this.nextPlan,
    this.recommendedSavings = 0,
    this.savingsReason = '',
    this.needsAttention = false,
  });

  // Calculate if this paycheck can help the next one
  static PaycheckForecast analyze(
    PaycheckPlan current,
    PaycheckPlan? next,
    List<Bill> allBills,
  ) {
    if (next == null) {
      return PaycheckForecast(currentPlan: current);
    }

    final currentSurplus = current.getSurplusAmount(allBills);
    final nextDeficit = next.getDeficitAmount(allBills);

    if (nextDeficit > 0 && currentSurplus > 0) {
      final recommendedAmount = nextDeficit > currentSurplus ? currentSurplus : nextDeficit;
      
      return PaycheckForecast(
        currentPlan: current,
        nextPlan: next,
        recommendedSavings: recommendedAmount,
        savingsReason: 'Save \$${recommendedAmount.toStringAsFixed(2)} for next paycheck (short \$${nextDeficit.toStringAsFixed(2)})',
        needsAttention: true,
      );
    }

    if (nextDeficit > 0 && currentSurplus == 0) {
      return PaycheckForecast(
        currentPlan: current,
        nextPlan: next,
        savingsReason: 'Next paycheck will be short \$${nextDeficit.toStringAsFixed(2)} - no surplus to save',
        needsAttention: true,
      );
    }

    return PaycheckForecast(
      currentPlan: current,
      nextPlan: next,
    );
  }
}
