import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/budget_provider.dart';
import '../models/transaction.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  int _selectedPeriod = 0; // 0 = This Month, 1 = Last 3 Months, 2 = Last 6 Months

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<BudgetProvider>();
    final viewingMonth = provider.viewingMonth;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period selector
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(
                  value: 0,
                  label: Text('This Month'),
                  icon: Icon(Icons.calendar_today),
                ),
                ButtonSegment(
                  value: 1,
                  label: Text('3 Months'),
                  icon: Icon(Icons.calendar_view_week),
                ),
                ButtonSegment(
                  value: 2,
                  label: Text('6 Months'),
                  icon: Icon(Icons.calendar_view_month),
                ),
              ],
              selected: {_selectedPeriod},
              onSelectionChanged: (Set<int> newSelection) {
                setState(() {
                  _selectedPeriod = newSelection.first;
                });
              },
            ),
            const SizedBox(height: 24),

            // Income vs Expenses Chart
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Income vs Expenses',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 250,
                      child: _buildIncomeExpensesChart(provider),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Category Breakdown
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Spending by Category',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 300,
                      child: _buildCategoryPieChart(provider, viewingMonth),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Spending Trend
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Spending Trend',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 250,
                      child: _buildSpendingTrendChart(provider),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Budget Progress by Category
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Budget Progress',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildBudgetProgress(provider, viewingMonth, theme),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomeExpensesChart(BudgetProvider provider) {
    final months = _getMonthsToDisplay();
    final incomeData = <double>[];
    final expenseData = <double>[];

    for (var month in months) {
      incomeData.add(provider.getMonthIncome(month));
      expenseData.add(provider.getMonthExpenses(month));
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: _getMaxValue(incomeData, expenseData) * 1.2,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final month = months[group.x.toInt()];
              final label = rodIndex == 0 ? 'Income' : 'Expenses';
              return BarTooltipItem(
                '$label\n\$${rod.toY.toStringAsFixed(2)}',
                const TextStyle(color: Colors.white),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= months.length) return const Text('');
                final month = months[value.toInt()];
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    DateFormat.MMM().format(month),
                    style: const TextStyle(fontSize: 12),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 60,
              getTitlesWidget: (value, meta) {
                return Text(
                  '\$${(value / 1000).toStringAsFixed(0)}k',
                  style: const TextStyle(fontSize: 12),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
        ),
        barGroups: List.generate(months.length, (index) {
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: incomeData[index],
                color: Colors.green,
                width: 15,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
              BarChartRodData(
                toY: expenseData[index],
                color: Colors.red,
                width: 15,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildCategoryPieChart(BudgetProvider provider, DateTime month) {
    final categorySpending = <String, double>{};
    final transactions = provider.getTransactionsForMonth(month);

    for (var transaction in transactions) {
      if (transaction.isExpense) {
        categorySpending[transaction.category] =
            (categorySpending[transaction.category] ?? 0) +
                transaction.amount.abs();
      }
    }

    if (categorySpending.isEmpty) {
      return const Center(
        child: Text('No expenses this month'),
      );
    }

    final total = categorySpending.values.reduce((a, b) => a + b);
    final categories = categorySpending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.pink,
      Colors.teal,
      Colors.amber,
    ];

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: PieChart(
            PieChartData(
              sections: List.generate(categories.length, (index) {
                final entry = categories[index];
                final percentage = (entry.value / total * 100);
                return PieChartSectionData(
                  value: entry.value,
                  title: '${percentage.toStringAsFixed(1)}%',
                  color: colors[index % colors.length],
                  radius: 100,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }),
              sectionsSpace: 2,
              centerSpaceRadius: 0,
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              categories.length.clamp(0, 8),
              (index) {
                final entry = categories[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: colors[index % colors.length],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          entry.key,
                          style: const TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSpendingTrendChart(BudgetProvider provider) {
    final months = _getMonthsToDisplay();
    final spendingData = <FlSpot>[];

    for (var i = 0; i < months.length; i++) {
      final expenses = provider.getMonthExpenses(months[i]);
      spendingData.add(FlSpot(i.toDouble(), expenses));
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= months.length) return const Text('');
                final month = months[value.toInt()];
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    DateFormat.MMM().format(month),
                    style: const TextStyle(fontSize: 12),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 60,
              getTitlesWidget: (value, meta) {
                return Text(
                  '\$${(value / 1000).toStringAsFixed(0)}k',
                  style: const TextStyle(fontSize: 12),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spendingData,
            isCurved: true,
            color: Colors.red,
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.red.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetProgress(
    BudgetProvider provider,
    DateTime month,
    ThemeData theme,
  ) {
    final categories = provider.categories.where((c) => c.monthlyBudget > 0).toList();

    if (categories.isEmpty) {
      return const Center(child: Text('No budgets set'));
    }

    return Column(
      children: categories.map((category) {
        final spent = category.getSpentAmount(month, provider.transactions);
        final percentage = category.getPercentageUsed(month, provider.transactions);
        final isOverBudget = category.isOverBudget(month, provider.transactions);

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(category.icon, size: 20, color: category.color),
                      const SizedBox(width: 8),
                      Text(category.name, style: theme.textTheme.titleSmall),
                    ],
                  ),
                  Text(
                    '\$${spent.toStringAsFixed(2)} / \$${category.monthlyBudget.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: isOverBudget ? Colors.red : null,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: (percentage / 100).clamp(0, 1),
                  minHeight: 12,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isOverBudget ? Colors.red : Colors.green,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${percentage.toStringAsFixed(1)}% used',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  List<DateTime> _getMonthsToDisplay() {
    final now = DateTime.now();
    final months = <DateTime>[];

    switch (_selectedPeriod) {
      case 0: // This month
        months.add(DateTime(now.year, now.month));
        break;
      case 1: // Last 3 months
        for (var i = 2; i >= 0; i--) {
          final month = DateTime(now.year, now.month - i);
          months.add(month);
        }
        break;
      case 2: // Last 6 months
        for (var i = 5; i >= 0; i--) {
          final month = DateTime(now.year, now.month - i);
          months.add(month);
        }
        break;
    }

    return months;
  }

  double _getMaxValue(List<double> list1, List<double> list2) {
    double max = 0;
    for (var value in list1) {
      if (value > max) max = value;
    }
    for (var value in list2) {
      if (value > max) max = value;
    }
    return max;
  }
}
