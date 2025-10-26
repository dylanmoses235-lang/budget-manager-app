import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/budget_service.dart';
import '../models/config.dart';
import '../models/account.dart';
import '../models/bill.dart';
import '../data/budget_data.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Config? config;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  void _loadConfig() {
    setState(() {
      config = BudgetService.getConfig();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Paycheck Settings
          Card(
            child: Column(
              children: [
                ListTile(
                  title: Text(
                    'Paycheck Settings',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  leading: const Icon(Icons.payments),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('First Paycheck Date'),
                  subtitle: Text(
                    DateFormat.yMMMd().format(config?.firstPaycheckDate ?? DateTime.now()),
                  ),
                  trailing: const Icon(Icons.edit),
                  onTap: () => _editPaycheckDate(),
                ),
                ListTile(
                  title: const Text('Paycheck Amount'),
                  subtitle: Text('\$${config?.paycheckAmount.toStringAsFixed(2) ?? '0.00'}'),
                  trailing: const Icon(Icons.edit),
                  onTap: () => _editPaycheckAmount(),
                ),
                ListTile(
                  title: const Text('Pay Frequency'),
                  subtitle: Text('Every ${config?.payFrequencyDays ?? 0} days'),
                  trailing: const Icon(Icons.edit),
                  onTap: () => _editPayFrequency(),
                ),
                ListTile(
                  title: const Text('Default Deposit Account'),
                  subtitle: Text(config?.defaultDepositAccount ?? ''),
                  trailing: const Icon(Icons.edit),
                  onTap: () => _editDefaultAccount(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Viewing Month
          Card(
            child: Column(
              children: [
                ListTile(
                  title: Text(
                    'Viewing Month',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  leading: const Icon(Icons.calendar_month),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Current Month'),
                  subtitle: Text(
                    DateFormat.yMMMM().format(config?.viewingMonth ?? DateTime.now()),
                  ),
                  trailing: const Icon(Icons.edit),
                  onTap: () => _editViewingMonth(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Account Management
          Card(
            child: Column(
              children: [
                ListTile(
                  title: Text(
                    'Manage Accounts',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  leading: const Icon(Icons.account_balance_wallet),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('View & Edit Accounts'),
                  subtitle: Text('${BudgetService.getAccounts().length} accounts'),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () => _manageAccounts(),
                ),
                ListTile(
                  title: const Text('Add New Account'),
                  leading: const Icon(Icons.add_circle, color: Colors.green),
                  onTap: () => _addAccount(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Bill Management
          Card(
            child: Column(
              children: [
                ListTile(
                  title: Text(
                    'Manage Bills',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  leading: const Icon(Icons.receipt_long),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('View & Edit Bills'),
                  subtitle: Text('${BudgetService.getBills().length} bills'),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () => _manageBills(),
                ),
                ListTile(
                  title: const Text('Add New Bill'),
                  leading: const Icon(Icons.add_circle, color: Colors.green),
                  onTap: () => _addBill(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Data Management
          Card(
            child: Column(
              children: [
                ListTile(
                  title: Text(
                    'Data Management',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  leading: const Icon(Icons.storage),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Total Transactions'),
                  subtitle: Text('${BudgetService.getTransactions().length} transactions'),
                  trailing: const Icon(Icons.info_outline),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Paycheck Settings Editors
  void _editPaycheckDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: config?.firstPaycheckDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    
    if (picked != null && config != null) {
      config!.firstPaycheckDate = picked;
      await BudgetService.updateConfig(config!);
      _loadConfig();
    }
  }

  void _editPaycheckAmount() {
    final controller = TextEditingController(
      text: config?.paycheckAmount.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Paycheck Amount'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Amount',
            prefixText: '\$',
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(controller.text);
              if (amount != null && config != null) {
                config!.paycheckAmount = amount;
                await BudgetService.updateConfig(config!);
                _loadConfig();
              }
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _editPayFrequency() {
    final controller = TextEditingController(
      text: config?.payFrequencyDays.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Pay Frequency'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Days between paychecks',
            hintText: '14 for bi-weekly, 7 for weekly',
          ),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final days = int.tryParse(controller.text);
              if (days != null && config != null) {
                config!.payFrequencyDays = days;
                await BudgetService.updateConfig(config!);
                _loadConfig();
              }
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _editDefaultAccount() {
    String? selectedAccount = config?.defaultDepositAccount;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Default Deposit Account'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: BudgetService.getAccounts().map((account) {
              return RadioListTile<String>(
                title: Text(account.name),
                value: account.name,
                groupValue: selectedAccount,
                onChanged: (value) {
                  setDialogState(() {
                    selectedAccount = value;
                  });
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedAccount != null && config != null) {
                  config!.defaultDepositAccount = selectedAccount!;
                  await BudgetService.updateConfig(config!);
                  _loadConfig();
                }
                if (mounted) Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _editViewingMonth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: config?.viewingMonth ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    
    if (picked != null && config != null) {
      // Set to first day of selected month
      config!.viewingMonth = DateTime(picked.year, picked.month, 1);
      await BudgetService.updateConfig(config!);
      _loadConfig();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Viewing month updated! Restart app to see changes.'),
          ),
        );
      }
    }
  }

  // Account Management
  void _manageAccounts() {
    final accounts = BudgetService.getAccounts();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Manage Accounts'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: accounts.length,
            itemBuilder: (context, index) {
              final account = accounts[index];
              return ListTile(
                leading: Icon(IconData(account.icon, fontFamily: 'MaterialIcons')),
                title: Text(account.name),
                subtitle: Text('\$${account.startingBalance.toStringAsFixed(2)}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: () {
                        Navigator.pop(context);
                        _editAccount(account);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                      onPressed: () {
                        Navigator.pop(context);
                        _deleteAccount(account);
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _addAccount() {
    final nameController = TextEditingController();
    final balanceController = TextEditingController(text: '0.00');
    final overdraftController = TextEditingController(text: '0.00');
    final overdraftUsedController = TextEditingController(text: '0.00');
    bool autoPaychecks = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add New Account'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Account Name'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: balanceController,
                  decoration: const InputDecoration(
                    labelText: 'Starting Balance',
                    prefixText: '\$',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: overdraftController,
                  decoration: const InputDecoration(
                    labelText: 'Overdraft Limit',
                    prefixText: '\$',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: overdraftUsedController,
                  decoration: const InputDecoration(
                    labelText: 'Overdraft Used',
                    prefixText: '\$',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Auto Paychecks'),
                  subtitle: const Text('Automatically add paychecks to this account'),
                  value: autoPaychecks,
                  onChanged: (value) {
                    setDialogState(() {
                      autoPaychecks = value;
                    });
                  },
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
                final name = nameController.text.trim();
                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter account name')),
                  );
                  return;
                }

                final balance = double.tryParse(balanceController.text) ?? 0;
                final overdraft = double.tryParse(overdraftController.text) ?? 0;
                final overdraftUsed = double.tryParse(overdraftUsedController.text) ?? 0;

                final account = Account(
                  name: name,
                  startingBalance: balance,
                  overdraftLimit: overdraft,
                  overdraftUsed: overdraftUsed,
                  autoPaychecks: autoPaychecks,
                  icon: 0xe54c, // Default wallet icon
                );

                await BudgetService.addAccount(account);
                
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Account added successfully')),
                  );
                  setState(() {});
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _editAccount(Account account) {
    final nameController = TextEditingController(text: account.name);
    final balanceController = TextEditingController(text: account.startingBalance.toString());
    final overdraftController = TextEditingController(text: account.overdraftLimit.toString());
    final overdraftUsedController = TextEditingController(text: account.overdraftUsed.toString());
    bool autoPaychecks = account.autoPaychecks;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Account'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Account Name'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: balanceController,
                  decoration: const InputDecoration(
                    labelText: 'Starting Balance',
                    prefixText: '\$',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: overdraftController,
                  decoration: const InputDecoration(
                    labelText: 'Overdraft Limit',
                    prefixText: '\$',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: overdraftUsedController,
                  decoration: const InputDecoration(
                    labelText: 'Overdraft Used',
                    prefixText: '\$',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Auto Paychecks'),
                  subtitle: const Text('Automatically add paychecks to this account'),
                  value: autoPaychecks,
                  onChanged: (value) {
                    setDialogState(() {
                      autoPaychecks = value;
                    });
                  },
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
                account.name = nameController.text.trim();
                account.startingBalance = double.tryParse(balanceController.text) ?? 0;
                account.overdraftLimit = double.tryParse(overdraftController.text) ?? 0;
                account.overdraftUsed = double.tryParse(overdraftUsedController.text) ?? 0;
                account.autoPaychecks = autoPaychecks;
                
                await account.save();
                
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Account updated successfully')),
                  );
                  setState(() {});
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteAccount(Account account) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: Text('Are you sure you want to delete "${account.name}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await account.delete();
              
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Account deleted')),
                );
                setState(() {});
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // Bill Management
  void _manageBills() {
    final bills = BudgetService.getBills();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Manage Bills'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: bills.length,
            itemBuilder: (context, index) {
              final bill = bills[index];
              return ListTile(
                title: Text(bill.name),
                subtitle: Text('Due: Day ${bill.dueDay} • \$${bill.defaultAmount.toStringAsFixed(2)}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: () {
                        Navigator.pop(context);
                        _editBill(bill);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                      onPressed: () {
                        Navigator.pop(context);
                        _deleteBill(bill);
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _addBill() {
    final nameController = TextEditingController();
    final amountController = TextEditingController(text: '0.00');
    final dueDayController = TextEditingController(text: '1');
    final notesController = TextEditingController();
    String selectedAccount = BudgetData.defaultDepositAccount;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add New Bill'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Bill Name'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(
                    labelText: 'Default Amount',
                    prefixText: '\$',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: dueDayController,
                  decoration: const InputDecoration(
                    labelText: 'Due Day (1-31)',
                  ),
                  keyboardType: TextInputType.number,
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
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(labelText: 'Notes'),
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
                final name = nameController.text.trim();
                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter bill name')),
                  );
                  return;
                }

                final amount = double.tryParse(amountController.text) ?? 0;
                final dueDay = int.tryParse(dueDayController.text) ?? 1;

                final bill = Bill(
                  name: name,
                  defaultAmount: amount,
                  dueDay: dueDay.clamp(1, 31),
                  account: selectedAccount,
                  notes: notesController.text.trim(),
                );

                await BudgetService.addBill(bill);
                
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Bill added successfully')),
                  );
                  setState(() {});
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _editBill(Bill bill) {
    final nameController = TextEditingController(text: bill.name);
    final amountController = TextEditingController(text: bill.defaultAmount.toString());
    final dueDayController = TextEditingController(text: bill.dueDay.toString());
    final notesController = TextEditingController(text: bill.notes);
    String selectedAccount = bill.account;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Bill'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Bill Name'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(
                    labelText: 'Default Amount',
                    prefixText: '\$',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: dueDayController,
                  decoration: const InputDecoration(
                    labelText: 'Due Day (1-31)',
                  ),
                  keyboardType: TextInputType.number,
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
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(labelText: 'Notes'),
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
                bill.name = nameController.text.trim();
                bill.defaultAmount = double.tryParse(amountController.text) ?? 0;
                bill.dueDay = (int.tryParse(dueDayController.text) ?? 1).clamp(1, 31);
                bill.account = selectedAccount;
                bill.notes = notesController.text.trim();
                
                await bill.save();
                
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Bill updated successfully')),
                  );
                  setState(() {});
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteBill(Bill bill) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Bill'),
        content: Text('Are you sure you want to delete "${bill.name}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await bill.delete();
              
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Bill deleted')),
                );
                setState(() {});
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
