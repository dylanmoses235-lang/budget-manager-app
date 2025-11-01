import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/budget_service.dart';
import '../models/config.dart';
import '../models/bill.dart';

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
                        onPressed: _showMonthPicker,
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
                      child: InkWell(
                        onTap: () => _showBillsList(true),
                        borderRadius: BorderRadius.circular(12),
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
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Card(
                      child: InkWell(
                        onTap: () => _showBillsList(false),
                        borderRadius: BorderRadius.circular(12),
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

  Future<void> _showMonthPicker() async {
    final currentMonth = config?.viewingMonth ?? DateTime.now();
    
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: currentMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDatePickerMode: DatePickerMode.year,
      helpText: 'Select Month',
    );

    if (pickedDate != null && mounted) {
      final newMonth = DateTime(pickedDate.year, pickedDate.month, 1);
      config!.viewingMonth = newMonth;
      await BudgetService.updateConfig(config!);
      _loadData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Viewing month changed to ${DateFormat.yMMMM().format(newMonth)}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _showBillsList(bool showPaid) {
    final viewingMonth = config?.viewingMonth ?? DateTime.now();
    final allBills = BudgetService.getBillsForMonth(viewingMonth);
    final filteredBills = allBills.where((b) => 
      b.isPaidForMonth(viewingMonth) == showPaid
    ).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    showPaid ? Icons.check_circle : Icons.pending,
                    color: showPaid ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    showPaid ? 'Bills Paid' : 'Unpaid Bills',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: filteredBills.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            showPaid ? Icons.check_circle_outline : Icons.pending_outlined,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            showPaid ? 'No paid bills yet' : 'All bills are paid!',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredBills.length,
                      itemBuilder: (context, index) {
                        final bill = filteredBills[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            onTap: () {
                              Navigator.pop(context);
                              _showEditBillDialog(bill);
                            },
                            leading: CircleAvatar(
                              backgroundColor: showPaid ? Colors.green.shade50 : Colors.orange.shade50,
                              child: Icon(
                                showPaid ? Icons.check : Icons.schedule,
                                color: showPaid ? Colors.green : Colors.orange,
                              ),
                            ),
                            title: Text(
                              bill.name,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              'Due: ${DateFormat.MMMd().format(bill.getDueDate(viewingMonth))}',
                            ),
                            trailing: Text(
                              '\$${bill.getAmountForMonth(viewingMonth).toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: showPaid ? Colors.green : Colors.orange,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleBillPayment(bill, bool paid) async {
    final viewingMonth = config?.viewingMonth ?? DateTime.now();
    await BudgetService.updateBillPayment(bill, paid, viewingMonth);
    _loadData();
  }

  void _showEditBillDialog(bill) {
    final viewingMonth = config?.viewingMonth ?? DateTime.now();
    final amountController = TextEditingController(
      text: bill.getAmountForMonth(viewingMonth).toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${bill.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              decoration: InputDecoration(
                labelText: 'Amount for ${DateFormat.yMMM().format(viewingMonth)}',
                prefixText: '\$',
                helperText: 'Default: \$${bill.defaultAmount.toStringAsFixed(2)}',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Mark as paid'),
              trailing: Checkbox(
                value: bill.isPaidForMonth(viewingMonth),
                onChanged: (value) {
                  Navigator.pop(context);
                  _toggleBillPayment(bill, value ?? false);
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text);
              if (amount != null) {
                bill.setAmountForMonth(viewingMonth, amount);
                bill.save();
                _loadData();
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
