import 'package:flutter/material.dart';
import 'package:money_manager_app/core/theme/app_theme.dart';
import 'package:money_manager_app/data/models/goal.dart';

enum GoalState {
  completed,
  overdue,
  ongoing;

  Color get color {
    switch (this) {
      case GoalState.completed:
        return AppTheme.primary;
      case GoalState.overdue:
        return Colors.red.shade400;
      case GoalState.ongoing:
        return Colors.black54;
    }
  }
}

GoalState goalStateOf(Goal goal, DateTime now) {
  if (goal.isCompleted) return GoalState.completed;
  final days = goal.daysLeft(now);
  if (days != null && days < 0) return GoalState.overdue;
  return GoalState.ongoing;
}

String goalDeadlineText(Goal goal, DateTime now) {
  if (goal.isCompleted) return 'Đã hoàn thành';
  final days = goal.daysLeft(now);
  if (days == null) return 'Không giới hạn thời gian';
  if (days > 0) return 'Còn $days ngày';
  if (days == 0) return 'Hết hạn hôm nay';
  return 'Quá hạn ${-days} ngày';
}
