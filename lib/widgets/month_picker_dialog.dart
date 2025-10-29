import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MonthPickerDialog extends StatefulWidget {
  final DateTime initialMonth;

  const MonthPickerDialog({
    super.key,
    required this.initialMonth,
  });

  @override
  State<MonthPickerDialog> createState() => _MonthPickerDialogState();
}

class _MonthPickerDialogState extends State<MonthPickerDialog> {
  late int selectedYear;
  late int selectedMonth;

  @override
  void initState() {
    super.initState();
    selectedYear = widget.initialMonth.year;
    selectedMonth = widget.initialMonth.month;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Select Month'),
      content: SizedBox(
        width: 300,
        height: 400,
        child: Column(
          children: [
            // Year selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    setState(() {
                      selectedYear--;
                    });
                  },
                ),
                Text(
                  selectedYear.toString(),
                  style: theme.textTheme.headlineSmall,
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    setState(() {
                      selectedYear++;
                    });
                  },
                ),
              ],
            ),
            const Divider(),
            // Month grid
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: 12,
                itemBuilder: (context, index) {
                  final month = index + 1;
                  final isSelected = month == selectedMonth &&
                      selectedYear == widget.initialMonth.year;
                  final monthName = DateFormat.MMM()
                      .format(DateTime(selectedYear, month));

                  return InkWell(
                    onTap: () {
                      setState(() {
                        selectedMonth = month;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.colorScheme.primaryContainer
                            : theme.colorScheme.surface,
                        border: Border.all(
                          color: month == selectedMonth
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outline,
                          width: month == selectedMonth ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          monthName,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: month == selectedMonth
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: month == selectedMonth
                                ? theme.colorScheme.primary
                                : null,
                          ),
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
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final selectedDate = DateTime(selectedYear, selectedMonth);
            Navigator.of(context).pop(selectedDate);
          },
          child: const Text('Select'),
        ),
      ],
    );
  }
}

// Helper function to show the dialog
Future<DateTime?> showMonthPicker({
  required BuildContext context,
  required DateTime initialMonth,
}) {
  return showDialog<DateTime>(
    context: context,
    builder: (context) => MonthPickerDialog(initialMonth: initialMonth),
  );
}
