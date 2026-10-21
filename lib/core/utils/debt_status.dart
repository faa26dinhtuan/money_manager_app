import 'package:flutter/material.dart';
import 'package:money_manager_app/core/widgets/app_icon.dart';
import 'package:money_manager_app/core/theme/app_theme.dart';
import 'package:money_manager_app/data/models/debt.dart';
import 'package:money_manager_app/l10n/app_localizations.dart';

extension DebtTypeStyle on DebtType {
  Color get color {
    switch (this) {
      case DebtType.lend:
        return const Color(0xFF4C9BE8);
      case DebtType.borrow:
        return const Color(0xFFE8506E);
    }
  }

  AppIconData get icon {
    switch (this) {
      case DebtType.lend:
        return AppIcons.sent;
      case DebtType.borrow:
        return AppIcons.received;
    }
  }
}

enum DebtState {
  settled,
  overdue,
  ongoing;

  Color get color {
    switch (this) {
      case DebtState.settled:
        return AppTheme.primary;
      case DebtState.overdue:
        return Colors.red.shade400;
      case DebtState.ongoing:
        return Colors.grey.shade600;
    }
  }
}

DebtState debtStateOf(Debt debt, DateTime now) {
  if (debt.isSettled) return DebtState.settled;
  final days = debt.daysLeft(now);
  if (days != null && days < 0) return DebtState.overdue;
  return DebtState.ongoing;
}

String debtDueText(Debt debt, DateTime now, AppLocalizations l) {
  if (debt.isSettled) return l.settled;
  final days = debt.daysLeft(now);
  if (days == null) return l.noDueDate;
  if (days > 0) return l.daysRemaining(days);
  if (days == 0) return l.dueToday;
  return l.daysOverdue(-days);
}
