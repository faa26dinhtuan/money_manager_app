import 'package:flutter/material.dart';
import 'package:money_manager_app/core/theme/app_theme.dart';

enum BudgetLevel {
  safe,
  warning,
  over;

  static const double warningRatio = 0.8;

  static BudgetLevel of(double spent, double limit) {
    if (limit <= 0) return BudgetLevel.safe;
    if (spent > limit) return BudgetLevel.over;
    if (spent / limit >= warningRatio) return BudgetLevel.warning;
    return BudgetLevel.safe;
  }

  Color get color {
    switch (this) {
      case BudgetLevel.safe:
        return AppTheme.primary;
      case BudgetLevel.warning:
        return const Color(0xFFF59E0B);
      case BudgetLevel.over:
        return Colors.red.shade400;
    }
  }
}
