import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../services/budget_service.dart';
import '../models/config.dart';
import '../providers/budget_provider.dart';
import '../widgets/month_picker_dialog.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Config? config;
  double totalBalance = 0;
  double totalAvailable = 0;
  double monthIncome = 0;
  double monthExpenses = 0;
  double billsPaid = 0;
  double billsUnpaid = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      config = BudgetService.getConfig();
      totalBalance = BudgetService.getTotalBalance();
      totalAvailable = BudgetService.getTotalAvailable();
      
      final viewingMonth = config?.viewingMonth ?? DateTime.now();
      monthIncome = BudgetService.getMonthIncome(viewingMonth);
      monthExpenses = BudgetService.getMonthExpenses(viewingMonth);
      billsPaid = BudgetService.getBillsPaidThisMonth(viewingMonth);
      billsUnpaid = BudgetService.getUnpaidBillsTotal(viewingMonth);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final nextPaycheck = config?.getNextPaycheckDate();
    final paychecksReceived = config?.getPaychecksReceived() ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Dashboard'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadData();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Viewing Month Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Viewing Month',
                            style: theme.textTheme.titleSmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat.yMMMM().format(
                              config?.viewingMonth ?? DateTime.now(),
                            ),
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.calendar_month),
                        onPressed: () async {
                          final selectedMonth = await showMonthPicker(
                            context: context,
                            initialMonth: config?.viewingMonth ?? DateTime.now(),
                          );
                          if (selectedMonth != null && mounted) {
                            final provider = context.read<BudgetProvider>();
                            await provider.setViewingMonth(selectedMonth);
                            _loadData();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Account Balances
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Balance',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '\$${totalBalance.toStringAsFixed(2)}',
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: totalBalance >= 0
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Available (with overdraft):',
                              style: theme.textTheme.bodyMedium),
                          Text(
                            '\$${totalAvailable.toStringAsFixed(2)}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Next Paycheck
              if (nextPaycheck != null)
                Card(
                  color: theme.colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.payments,
                          size: 48,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Next Paycheck',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                              ),
                              Text(
                                '\$${config!.paycheckAmount.toStringAsFixed(2)}',
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                              ),
                              Text(
                                DateFormat.MMMd().format(nextPaycheck),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            Text(
                              '$paychecksReceived',
                              style: theme.textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                            Text(
                              'Received',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),

              // Bills Summary
              Row(
                children: [
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.check_circle,
                                    color: Colors.green, size: 20),
                                const SizedBox(width: 8),
                                Text('Bills Paid',
                                    style: theme.textTheme.titleSmall),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '\$${billsPaid.toStringAsFixed(2)}',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.pending,
                                    color: Colors.orange, size: 20),
                                const SizedBox(width: 8),
                                Text('Unpaid',
                                    style: theme.textTheme.titleSmall),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '\$${billsUnpaid.toStringAsFixed(2)}',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Monthly Summary
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'This Month',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(height: 24),
                      _buildSummaryRow(
                        'Income',
                        monthIncome,
                        Icons.arrow_upward,
                        Colors.green,
                        theme,
                      ),
                      const SizedBox(height: 12),
                      _buildSummaryRow(
                        'Expenses',
                        monthExpenses,
                        Icons.arrow_downward,
                        Colors.red,
                        theme,
                      ),
                      const Divider(height: 24),
                      _buildSummaryRow(
                        'Net Change',
                        monthIncome - monthExpenses,
                        Icons.trending_up,
                        (monthIncome - monthExpenses) >= 0
                            ? Colors.green
                            : Colors.red,
                        theme,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    double amount,
    IconData icon,
    Color color,
    ThemeData theme,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(label, style: theme.textTheme.bodyLarge),
          ],
        ),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
