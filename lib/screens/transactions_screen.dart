import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/budget_service.dart';
import '../models/transaction.dart';
import '../data/budget_data.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  List<Transaction> transactions = [];
  DateTime viewingMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    final config = BudgetService.getConfig();
    viewingMonth = config?.viewingMonth ?? DateTime.now();
    _loadTransactions();
  }

  void _loadTransactions() {
    try {
      setState(() {
        transactions = BudgetService.getTransactionsForMonth(viewingMonth);
      });
    } catch (e, stackTrace) {
      print('❌ Error loading transactions: $e');
      print('Stack: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error loading transactions. Please restart the app.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final income = transactions.where((t) => t.isIncome).fold(0.0, (sum, t) => sum + t.amount);
    final expenses = transactions.where((t) => t.isExpense).fold(0.0, (sum, t) => sum + t.amount.abs());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Implement filter
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary Header
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
                  'Income',
                  income,
                  Icons.arrow_upward,
                  Colors.green,
                  theme,
                ),
                Container(width: 1, height: 40, color: Colors.grey[300]),
                _buildSummaryColumn(
                  'Expenses',
                  expenses,
                  Icons.arrow_downward,
                  Colors.red,
                  theme,
                ),
                Container(width: 1, height: 40, color: Colors.grey[300]),
                _buildSummaryColumn(
                  'Net',
                  income - expenses,
                  Icons.trending_up,
                  income - expenses >= 0 ? Colors.green : Colors.red,
                  theme,
                ),
              ],
            ),
          ),

          // Transactions List
          Expanded(
            child: transactions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No transactions yet',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap + to add your first transaction',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = transactions[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: CircleAvatar(
                            backgroundColor: transaction.isIncome
                                ? Colors.green[100]
                                : Colors.red[100],
                            child: Icon(
                              transaction.isIncome
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward,
                              color: transaction.isIncome
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                          title: Text(
                            transaction.description,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text('${transaction.category} • ${transaction.account}'),
                              Text(DateFormat.MMMd().format(transaction.date)),
                              if (transaction.notes != null && transaction.notes!.isNotEmpty)
                                Text(
                                  transaction.notes!,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.grey,
                                  ),
                                ),
                            ],
                          ),
                          trailing: Text(
                            '${transaction.isIncome ? '+' : '-'}\$${transaction.amount.abs().toStringAsFixed(2)}',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: transaction.isIncome ? Colors.green : Colors.red,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showAddTransactionDialog();
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Transaction'),
      ),
    );
  }

  Widget _buildSummaryColumn(
    String label,
    double amount,
    IconData icon,
    Color color,
    ThemeData theme,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall,
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

  void _showAddTransactionDialog() {
    final descriptionController = TextEditingController();
    final amountController = TextEditingController();
    final notesController = TextEditingController();
    
    String selectedType = BudgetData.transactionTypes[0];
    String selectedCategory = BudgetData.categories[0];
    String selectedAccount = BudgetData.defaultDepositAccount;
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Transaction'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: "McDonald's, Electric bill, etc.",
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    prefixText: '\$',
                    hintText: 'Use negative for expenses',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: BudgetData.transactionTypes
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedType = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: BudgetData.categories
                      .map((category) => DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedCategory = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedAccount,
                  decoration: const InputDecoration(labelText: 'Account'),
                  items: BudgetService.getAccounts()
                      .map((account) => DropdownMenuItem(
                            value: account.name,
                            child: Text(account.name),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedAccount = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Date'),
                  subtitle: Text(DateFormat.yMMMd().format(selectedDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      setDialogState(() {
                        selectedDate = picked;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optional)',
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final description = descriptionController.text.trim();
                final amountText = amountController.text.trim();
                
                if (description.isEmpty || amountText.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill in description and amount'),
                    ),
                  );
                  return;
                }

                final amount = double.tryParse(amountText);
                if (amount == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a valid amount'),
                    ),
                  );
                  return;
                }

                final transaction = Transaction(
                  date: selectedDate,
                  type: selectedType,
                  description: description,
                  category: selectedCategory,
                  account: selectedAccount,
                  amount: amount,
                  notes: notesController.text.trim().isEmpty
                      ? null
                      : notesController.text.trim(),
                );

                await BudgetService.addTransaction(transaction);
                _loadTransactions();
                
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Transaction added successfully'),
                    ),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}
