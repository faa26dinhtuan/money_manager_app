import 'package:flutter/material.dart';
import 'package:money_manager_app/core/theme/app_theme.dart';
import 'package:money_manager_app/data/models/goal.dart';
import 'package:money_manager_app/l10n/app_localizations.dart';

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
        return Colors.grey.shade600;
    }
  }
}

GoalState goalStateOf(Goal goal, DateTime now) {
  if (goal.isCompleted) return GoalState.completed;
  final days = goal.daysLeft(now);
  if (days != null && days < 0) return GoalState.overdue;
  return GoalState.ongoing;
}

String goalDeadlineText(Goal goal, DateTime now, AppLocalizations l) {
  if (goal.isCompleted) return l.completed;
  final days = goal.daysLeft(now);
  if (days == null) return l.noDeadline;
  if (days > 0) return l.daysRemaining(days);
  if (days == 0) return l.dueToday;
  return l.daysOverdue(-days);
}
