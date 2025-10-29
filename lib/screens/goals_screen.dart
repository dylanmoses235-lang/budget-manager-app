import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../providers/budget_provider.dart';
import '../models/goal.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BudgetProvider>();
    final activeGoals = provider.goals.where((g) => !g.isCompleted).toList();
    final completedGoals = provider.goals.where((g) => g.isCompleted).toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Savings Goals'),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Active', icon: Icon(Icons.flag)),
              Tab(text: 'Completed', icon: Icon(Icons.check_circle)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildGoalsList(context, activeGoals, false),
            _buildGoalsList(context, completedGoals, true),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showGoalDialog(context),
          icon: const Icon(Icons.add),
          label: const Text('New Goal'),
        ),
      ),
    );
  }

  Widget _buildGoalsList(
    BuildContext context,
    List<Goal> goals,
    bool isCompleted,
  ) {
    if (goals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isCompleted ? Icons.check_circle_outline : Icons.flag_outlined,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              isCompleted ? 'No completed goals yet' : 'No active goals yet',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: goals.length,
      itemBuilder: (context, index) {
        final goal = goals[index];
        return _buildGoalCard(context, goal);
      },
    );
  }

  Widget _buildGoalCard(BuildContext context, Goal goal) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showGoalDetails(context, goal),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: goal.color.withOpacity(0.2),
                    child: Icon(goal.icon, color: goal.color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          goal.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (!goal.isCompleted)
                          Text(
                            '${goal.daysRemaining} days remaining',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: goal.daysRemaining < 30
                                  ? Colors.orange
                                  : null,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (goal.isOnTrack && !goal.isCompleted)
                    const Chip(
                      label: Text('On Track'),
                      backgroundColor: Colors.green,
                      labelStyle: TextStyle(color: Colors.white),
                      padding: EdgeInsets.symmetric(horizontal: 8),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              LinearPercentIndicator(
                lineHeight: 20,
                percent: goal.percentageCompleted / 100,
                center: Text(
                  '${goal.percentageCompleted.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                progressColor: goal.isCompleted
                    ? Colors.green
                    : goal.isOnTrack
                        ? Colors.blue
                        : Colors.orange,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                barRadius: const Radius.circular(10),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current',
                        style: theme.textTheme.bodySmall,
                      ),
                      Text(
                        '\$${goal.currentAmount.toStringAsFixed(2)}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Target',
                        style: theme.textTheme.bodySmall,
                      ),
                      Text(
                        '\$${goal.targetAmount.toStringAsFixed(2)}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (!goal.isCompleted && goal.suggestedMonthlyContribution > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          size: 16,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Suggested: \$${goal.suggestedMonthlyContribution.toStringAsFixed(2)}/month',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
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

  void _showGoalDialog(BuildContext context, {Goal? goal}) {
    showDialog(
      context: context,
      builder: (context) => GoalDialog(goal: goal),
    );
  }

  void _showGoalDetails(BuildContext context, Goal goal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => GoalDetailsSheet(goal: goal),
    );
  }
}

class GoalDialog extends StatefulWidget {
  final Goal? goal;

  const GoalDialog({super.key, this.goal});

  @override
  State<GoalDialog> createState() => _GoalDialogState();
}

class _GoalDialogState extends State<GoalDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _targetController;
  late TextEditingController _currentController;
  late DateTime _targetDate;
  late Color _selectedColor;
  late IconData _selectedIcon;

  final List<Color> _colors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.red,
    Colors.pink,
    Colors.teal,
    Colors.amber,
  ];

  final List<IconData> _icons = [
    Icons.savings,
    Icons.flight,
    Icons.home,
    Icons.directions_car,
    Icons.school,
    Icons.card_giftcard,
    Icons.computer,
    Icons.celebration,
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.goal?.name ?? '');
    _targetController = TextEditingController(
      text: widget.goal?.targetAmount.toStringAsFixed(2) ?? '',
    );
    _currentController = TextEditingController(
      text: widget.goal?.currentAmount.toStringAsFixed(2) ?? '0',
    );
    _targetDate = widget.goal?.targetDate ?? DateTime.now().add(const Duration(days: 365));
    _selectedColor = widget.goal?.color ?? Colors.blue;
    _selectedIcon = widget.goal?.icon ?? Icons.savings;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    _currentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.goal == null ? 'New Goal' : 'Edit Goal'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Goal Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter a name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _targetController,
                decoration: const InputDecoration(
                  labelText: 'Target Amount',
                  border: OutlineInputBorder(),
                  prefixText: '\$',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Please enter an amount';
                  if (double.tryParse(value!) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _currentController,
                decoration: const InputDecoration(
                  labelText: 'Current Amount',
                  border: OutlineInputBorder(),
                  prefixText: '\$',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Please enter an amount';
                  if (double.tryParse(value!) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Target Date'),
                subtitle: Text(DateFormat.yMMMd().format(_targetDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _targetDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 3650)),
                  );
                  if (date != null) {
                    setState(() => _targetDate = date);
                  }
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saveGoal,
          child: const Text('Save'),
        ),
      ],
    );
  }

  Future<void> _saveGoal() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<BudgetProvider>();
    final goal = widget.goal;

    if (goal == null) {
      final newGoal = Goal(
        name: _nameController.text,
        targetAmount: double.parse(_targetController.text),
        currentAmount: double.parse(_currentController.text),
        startDate: DateTime.now(),
        targetDate: _targetDate,
        colorValue: _selectedColor.value,
        iconCodePoint: _selectedIcon.codePoint,
      );
      await provider.addGoal(newGoal);
    } else {
      goal.name = _nameController.text;
      goal.targetAmount = double.parse(_targetController.text);
      goal.currentAmount = double.parse(_currentController.text);
      goal.targetDate = _targetDate;
      await provider.updateGoal(goal);
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}

class GoalDetailsSheet extends StatelessWidget {
  final Goal goal;

  const GoalDetailsSheet({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              CircleAvatar(
                radius: 40,
                backgroundColor: goal.color.withOpacity(0.2),
                child: Icon(goal.icon, size: 40, color: goal.color),
              ),
              const SizedBox(height: 16),
              Text(
                goal.name,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatCard(
                    context,
                    'Current',
                    '\$${goal.currentAmount.toStringAsFixed(2)}',
                    Icons.account_balance_wallet,
                    Colors.green,
                  ),
                  _buildStatCard(
                    context,
                    'Remaining',
                    '\$${goal.remainingAmount.toStringAsFixed(2)}',
                    Icons.trending_up,
                    Colors.orange,
                  ),
                  _buildStatCard(
                    context,
                    'Target',
                    '\$${goal.targetAmount.toStringAsFixed(2)}',
                    Icons.flag,
                    Colors.blue,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (!goal.isCompleted) ...[
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => _showContributionDialog(context),
                        icon: const Icon(Icons.add),
                        label: const Text('Add Contribution'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          // Show edit dialog
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit Goal'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(label, style: theme.textTheme.bodySmall),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showContributionDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Contribution'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Amount',
            prefixText: '\$',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final amount = double.tryParse(controller.text);
              if (amount != null && amount > 0) {
                await context.read<BudgetProvider>().addGoalContribution(goal, amount);
                if (context.mounted) {
                  Navigator.pop(context);
                  Navigator.pop(context); // Close the details sheet too
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
