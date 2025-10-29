import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'category.g.dart';

@HiveType(typeId: 4)
class Category extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  int colorValue; // Store color as int

  @HiveField(2)
  int iconCodePoint; // Store icon as codePoint

  @HiveField(3)
  double monthlyBudget;

  @HiveField(4)
  bool isDefault; // Default categories can't be deleted

  Category({
    required this.name,
    required this.colorValue,
    required this.iconCodePoint,
    this.monthlyBudget = 0,
    this.isDefault = false,
  });

  Color get color => Color(colorValue);
  IconData get icon => IconData(iconCodePoint, fontFamily: 'MaterialIcons');

  // Calculate spent amount for a given month
  double getSpentAmount(DateTime month, List transactions) {
    return transactions
        .where((t) =>
            t.category == name &&
            t.date.year == month.year &&
            t.date.month == month.month &&
            t.isExpense)
        .fold(0.0, (sum, t) => sum + t.amount.abs());
  }

  // Calculate remaining budget
  double getRemainingBudget(DateTime month, List transactions) {
    return monthlyBudget - getSpentAmount(month, transactions);
  }

  // Calculate percentage used
  double getPercentageUsed(DateTime month, List transactions) {
    if (monthlyBudget == 0) return 0;
    return (getSpentAmount(month, transactions) / monthlyBudget * 100)
        .clamp(0, 100);
  }

  // Check if over budget
  bool isOverBudget(DateTime month, List transactions) {
    return getSpentAmount(month, transactions) > monthlyBudget;
  }
}
