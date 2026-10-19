import 'package:flutter/material.dart';
import 'package:money_manager_app/core/theme/app_theme.dart';
import 'package:money_manager_app/data/models/debt.dart';

extension DebtTypeStyle on DebtType {
  Color get color {
    switch (this) {
      case DebtType.lend:
        return const Color(0xFF4C9BE8);
      case DebtType.borrow:
        return const Color(0xFFE8506E);
    }
  }

  IconData get icon {
    switch (this) {
      case DebtType.lend:
        return Icons.call_made;
      case DebtType.borrow:
        return Icons.call_received;
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
        return Colors.black54;
    }
  }
}

DebtState debtStateOf(Debt debt, DateTime now) {
  if (debt.isSettled) return DebtState.settled;
  final days = debt.daysLeft(now);
  if (days != null && days < 0) return DebtState.overdue;
  return DebtState.ongoing;
}

String debtDueText(Debt debt, DateTime now) {
  if (debt.isSettled) return 'Đã tất toán';
  final days = debt.daysLeft(now);
  if (days == null) return 'Không có hạn';
  if (days > 0) return 'Còn $days ngày';
  if (days == 0) return 'Đến hạn hôm nay';
  return 'Quá hạn ${-days} ngày';
}
