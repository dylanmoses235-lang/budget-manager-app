import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/bill.dart';
import '../models/config.dart';
import '../models/paycheck_plan.dart';
import '../services/budget_service.dart';
import '../services/paycheck_planner.dart';

class ForecastScreen extends StatefulWidget {
  const ForecastScreen({super.key});

  @override
  State<ForecastScreen> createState() => _ForecastScreenState();
}

class _ForecastScreenState extends State<ForecastScreen> {
  int _forecastWeeks = 8; // Default to 8 weeks (4 paychecks)

  @override
  Widget build(BuildContext context) {
    final config = BudgetService.getConfig();
    final bills = BudgetService.getBills();

    if (config == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Paycheck Forecast')),
        body: const Center(child: Text('No paycheck configuration found')),
      );
    }

    final numberOfPaychecks = (_forecastWeeks / 2).ceil(); // Bi-weekly
    final plans = PaycheckPlanner.generatePlans(config, bills, numberOfPaychecks);
    final forecasts = PaycheckPlanner.generateForecasts(plans, bills);
    final summary = PaycheckPlanner.getSummary(plans, bills);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Paycheck Forecast'),
        actions: [
          PopupMenuButton<int>(
            initialValue: _forecastWeeks,
            onSelected: (weeks) {
              setState(() {
                _forecastWeeks = weeks;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 4, child: Text('2 Weeks (1 paycheck)')),
              const PopupMenuItem(value: 8, child: Text('4 Weeks (2 paychecks)')),
              const PopupMenuItem(value: 12, child: Text('6 Weeks (3 paychecks)')),
              const PopupMenuItem(value: 16, child: Text('8 Weeks (4 paychecks)')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary Card at top
          _buildSummaryCard(summary),
          
          // List of paycheck forecasts
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: forecasts.length,
              itemBuilder: (context, index) {
                return _buildPaycheckCard(
                  forecasts[index],
                  bills,
                  index == 0, // First paycheck is "current"
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(PaycheckSummary summary) {
    final theme = Theme.of(context);
    final hasIssues = summary.hasDeficits;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: hasIssues ? Colors.orange.shade50 : Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasIssues ? Colors.orange : Colors.green,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                hasIssues ? Icons.warning_amber_rounded : Icons.check_circle,
                color: hasIssues ? Colors.orange : Colors.green,
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasIssues ? 'Attention Needed' : 'Looking Good!',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: hasIssues ? Colors.orange.shade900 : Colors.green.shade900,
                      ),
                    ),
                    Text(
                      'Next $_forecastWeeks weeks overview',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryItem(
                'Total Income',
                '\$${summary.totalIncome.toStringAsFixed(2)}',
                Colors.green,
              ),
              _buildSummaryItem(
                'Total Bills',
                '\$${summary.totalBills.toStringAsFixed(2)}',
                Colors.red,
              ),
              _buildSummaryItem(
                'Net',
                '\$${summary.netAmount.toStringAsFixed(2)}',
                summary.netAmount >= 0 ? Colors.green : Colors.red,
              ),
            ],
          ),
          if (summary.criticalAlerts.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, size: 20, color: Colors.orange.shade900),
                      const SizedBox(width: 8),
                      Text(
                        'Critical Alerts',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...summary.criticalAlerts.map((alert) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '• $alert',
                      style: TextStyle(color: Colors.orange.shade900),
                    ),
                  )),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildPaycheckCard(
    PaycheckForecast forecast,
    List<Bill> allBills,
    bool isCurrent,
  ) {
    final theme = Theme.of(context);
    final plan = forecast.currentPlan;
    final billsDue = allBills.where((b) => 
      plan.assignedBillNames.contains(b.name)
    ).toList();
    
    final totalBills = plan.getTotalBills(allBills);
    final remaining = plan.getRemainingAmount(allBills);
    final hasDeficit = remaining < 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: isCurrent ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: hasDeficit ? Colors.red : 
                 forecast.needsAttention ? Colors.orange : 
                 Colors.green.shade200,
          width: hasDeficit || forecast.needsAttention ? 2 : 1,
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.all(16),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: hasDeficit ? Colors.red.shade50 :
                     forecast.needsAttention ? Colors.orange.shade50 :
                     Colors.green.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              hasDeficit ? Icons.warning_rounded :
              forecast.needsAttention ? Icons.savings_outlined :
              Icons.check_circle_outline,
              color: hasDeficit ? Colors.red :
                     forecast.needsAttention ? Colors.orange :
                     Colors.green,
            ),
          ),
          title: Row(
            children: [
              Text(
                DateFormat('MMM dd, yyyy').format(plan.paycheckDate),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isCurrent) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'CURRENT',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Paycheck: \$${plan.amount.toStringAsFixed(2)}'),
                  Text('Bills: \$${totalBills.toStringAsFixed(2)}'),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                hasDeficit 
                  ? 'Short: \$${remaining.abs().toStringAsFixed(2)}'
                  : 'Left over: \$${remaining.toStringAsFixed(2)}',
                style: TextStyle(
                  color: hasDeficit ? Colors.red : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (forecast.needsAttention && forecast.savingsReason.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.lightbulb_outline, size: 16, color: Colors.orange.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          forecast.savingsReason,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange.shade900,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          children: [
            const Divider(),
            const SizedBox(height: 8),
            if (billsDue.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'No bills due in this period',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ...billsDue.map((bill) => _buildBillItem(bill, plan.paycheckDate)),
          ],
        ),
      ),
    );
  }

  Widget _buildBillItem(Bill bill, DateTime paycheckDate) {
    final month = DateTime(paycheckDate.year, paycheckDate.month, 1);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                bill.dueDay.toString(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bill.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (bill.notes.isNotEmpty)
                  Text(
                    bill.notes,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            '\$${bill.getAmountForMonth(month).toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
