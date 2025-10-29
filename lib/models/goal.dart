import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'goal.g.dart';

@HiveType(typeId: 6)
class Goal extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  double targetAmount;

  @HiveField(2)
  double currentAmount;

  @HiveField(3)
  DateTime startDate;

  @HiveField(4)
  DateTime targetDate;

  @HiveField(5)
  int colorValue;

  @HiveField(6)
  int iconCodePoint;

  @HiveField(7)
  String? notes;

  @HiveField(8)
  bool isCompleted;

  @HiveField(9)
  DateTime? completedDate;

  Goal({
    required this.name,
    required this.targetAmount,
    this.currentAmount = 0,
    required this.startDate,
    required this.targetDate,
    required this.colorValue,
    required this.iconCodePoint,
    this.notes,
    this.isCompleted = false,
    this.completedDate,
  });

  Color get color => Color(colorValue);
  IconData get icon => IconData(iconCodePoint, fontFamily: 'MaterialIcons');

  // Calculate percentage completed
  double get percentageCompleted {
    if (targetAmount == 0) return 0;
    return (currentAmount / targetAmount * 100).clamp(0, 100);
  }

  // Calculate remaining amount
  double get remainingAmount => (targetAmount - currentAmount).clamp(0, targetAmount);

  // Calculate days remaining
  int get daysRemaining {
    final now = DateTime.now();
    if (targetDate.isBefore(now)) return 0;
    return targetDate.difference(now).inDays;
  }

  // Calculate suggested monthly contribution
  double get suggestedMonthlyContribution {
    if (isCompleted || daysRemaining <= 0) return 0;
    final monthsRemaining = (daysRemaining / 30).ceil();
    if (monthsRemaining == 0) return remainingAmount;
    return remainingAmount / monthsRemaining;
  }

  // Check if goal is on track
  bool get isOnTrack {
    if (isCompleted) return true;
    final totalDays = targetDate.difference(startDate).inDays;
    final elapsedDays = DateTime.now().difference(startDate).inDays;
    if (totalDays <= 0) return false;
    
    final expectedProgress = (elapsedDays / totalDays) * targetAmount;
    return currentAmount >= expectedProgress;
  }

  // Add contribution
  Future<void> addContribution(double amount) async {
    currentAmount += amount;
    if (currentAmount >= targetAmount && !isCompleted) {
      isCompleted = true;
      completedDate = DateTime.now();
    }
    await save();
  }

  // Remove contribution
  Future<void> removeContribution(double amount) async {
    currentAmount = (currentAmount - amount).clamp(0, targetAmount);
    if (currentAmount < targetAmount && isCompleted) {
      isCompleted = false;
      completedDate = null;
    }
    await save();
  }
}
