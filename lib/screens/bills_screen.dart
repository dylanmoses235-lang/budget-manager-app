import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/budget_service.dart';
import '../models/bill.dart';

class BillsScreen extends StatefulWidget {
  const BillsScreen({super.key});

  @override
  State<BillsScreen> createState() => _BillsScreenState();
}

class _BillsScreenState extends State<BillsScreen> {
  List<Bill> bills = [];
  DateTime viewingMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    final config = BudgetService.getConfig();
    viewingMonth = config?.viewingMonth ?? DateTime.now();
    _loadBills();
  }

  void _loadBills() {
    try {
      setState(() {
        bills = BudgetService.getBillsForMonth(viewingMonth)
          ..sort((a, b) => a.dueDay.compareTo(b.dueDay));
      });
    } catch (e, stackTrace) {
      print('❌ Error loading bills: $e');
      print('Stack: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error loading bills. Please restart the app.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalBills = bills.fold(0.0, (sum, b) => sum + b.getAmountForMonth(viewingMonth));
    final paidBills = bills.where((b) => b.isPaidForMonth(viewingMonth)).fold(0.0, (sum, b) => sum + b.getAmountForMonth(viewingMonth));
    final unpaidBills = totalBills - paidBills;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bills'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Bills Summary Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryColumn(
                  'Total',
                  totalBills,
                  Colors.blue,
                  theme,
                ),
                Container(width: 1, height: 40, color: Colors.grey[300]),
                _buildSummaryColumn(
                  'Paid',
                  paidBills,
                  Colors.green,
                  theme,
                ),
                Container(width: 1, height: 40, color: Colors.grey[300]),
                _buildSummaryColumn(
                  'Unpaid',
                  unpaidBills,
                  Colors.orange,
                  theme,
                ),
              ],
            ),
          ),

          // Bills List
          Expanded(
            child: bills.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No bills configured',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: bills.length,
                    itemBuilder: (context, index) {
                      final bill = bills[index];
                      final dueDate = bill.getDueDate(viewingMonth);
                      final isPastDue = bill.isPastDue(viewingMonth);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: CircleAvatar(
                            backgroundColor: bill.paid
                                ? Colors.green[100]
                                : isPastDue
                                    ? Colors.red[100]
                                    : Colors.orange[100],
                            child: Icon(
                              bill.isPaidForMonth(viewingMonth)
                                  ? Icons.check_circle
                                  : isPastDue
                                      ? Icons.warning
                                      : Icons.schedule,
                              color: bill.isPaidForMonth(viewingMonth)
                                  ? Colors.green
                                  : isPastDue
                                      ? Colors.red
                                      : Colors.orange,
                            ),
                          ),
                          title: Text(
                            bill.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text('Due: ${DateFormat.MMMd().format(dueDate)}'),
                              Text('Account: ${bill.account}'),
                              if (bill.notes.isNotEmpty)
                                Text(
                                  bill.notes,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.grey,
                                  ),
                                ),
                            ],
                          ),
                          trailing: SizedBox(
                            width: 80,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '\$${bill.getAmountForMonth(viewingMonth).toStringAsFixed(2)}',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: bill.isPaidForMonth(viewingMonth) ? Colors.green : Colors.grey[700],
                                  ),
                                ),
                                Transform.scale(
                                  scale: 0.7,
                                  child: Checkbox(
                                    value: bill.isPaidForMonth(viewingMonth),
                                    onChanged: (value) {
                                      _toggleBillPayment(bill, value ?? false);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          onTap: () {
                            _showEditBillDialog(bill);
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryColumn(
    String label,
    double amount,
    Color color,
    ThemeData theme,
  ) {
    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Future<void> _toggleBillPayment(Bill bill, bool paid) async {
    await BudgetService.updateBillPayment(bill, paid, viewingMonth);
    _loadBills();
  }

  void _showEditBillDialog(Bill bill) {
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
                _loadBills();
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
