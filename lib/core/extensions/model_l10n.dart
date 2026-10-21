import 'package:flutter/widgets.dart';
import 'package:money_manager_app/core/extensions/l10n_extensions.dart';
import 'package:money_manager_app/core/utils/currency.dart';
import 'package:money_manager_app/core/utils/csv_export.dart';
import 'package:money_manager_app/core/utils/date_range.dart';
import 'package:money_manager_app/core/utils/formatters.dart';
import 'package:money_manager_app/data/models/category.dart';
import 'package:money_manager_app/data/models/debt.dart';
import 'package:money_manager_app/data/models/recurring_transaction.dart';
import 'package:money_manager_app/data/models/wallet.dart';
import 'package:money_manager_app/l10n/app_localizations.dart';

extension CategoryL10n on Category {
  String localizedName(BuildContext context) => nameOf(context.l10n);

  String nameOf(AppLocalizations l) {
    switch (id) {
      case 'food':
        return l.catFood;
      case 'grocery':
        return l.catGrocery;
      case 'shop':
        return l.catShop;
      case 'home':
        return l.catHome;
      case 'transport':
        return l.catTransport;
      case 'health':
        return l.catHealth;
      case 'bill':
        return l.catBill;
      case 'entertain':
        return l.catEntertain;
      case 'other_e':
        return l.other;
      case 'salary':
        return l.catSalary;
      case 'bonus':
        return l.catBonus;
      case 'invest':
        return l.catInvest;
      case 'other_i':
      case 'other_income':
        return l.catOtherIncome;
      default:
        return name;
    }
  }
}

extension WalletL10n on Wallet {
  String localizedName(BuildContext context) => nameOf(context.l10n);

  String nameOf(AppLocalizations l) {
    if (id == 'cash') return l.cashWallet;
    if (id == 'bank') return l.bankWallet;
    return name;
  }
}

extension PeriodL10n on Period {
  String localizedLabel(BuildContext context) {
    final l = context.l10n;
    switch (this) {
      case Period.day:
        return l.day;
      case Period.week:
        return l.week;
      case Period.month:
        return l.month;
      case Period.year:
        return l.year;
      case Period.custom:
        return l.customPeriod;
    }
  }
}

extension TxTypeL10n on TxType {
  String localizedLabel(BuildContext context) => labelOf(context.l10n);

  String labelOf(AppLocalizations l) {
    return this == TxType.expense ? l.expenseUpper : l.incomeUpper;
  }

  String localizedName(BuildContext context) {
    return this == TxType.expense ? context.l10n.expense : context.l10n.income;
  }
}

extension FrequencyL10n on Frequency {
  String localizedLabel(BuildContext context) => labelOf(context.l10n);

  String labelOf(AppLocalizations l) {
    switch (this) {
      case Frequency.daily:
        return l.freqDaily;
      case Frequency.weekly:
        return l.freqWeekly;
      case Frequency.monthly:
        return l.freqMonthly;
      case Frequency.yearly:
        return l.freqYearly;
    }
  }
}

extension DebtTypeL10n on DebtType {
  String localizedLabel(BuildContext context) {
    return this == DebtType.lend ? context.l10n.lend : context.l10n.borrow;
  }

  String localizedPaymentLabel(BuildContext context) =>
      paymentLabelOf(context.l10n);

  String labelOf(AppLocalizations l) {
    return this == DebtType.lend ? l.lend : l.borrow;
  }

  String paymentLabelOf(AppLocalizations l) {
    return this == DebtType.lend ? l.collectDebt : l.payDebt;
  }

  String localizedPaidLabel(BuildContext context) {
    return this == DebtType.lend ? context.l10n.collected : context.l10n.paid;
  }
}

String localizedDateRangeLabel(
  BuildContext context,
  Period p,
  DateTime a, [
  DateRange? custom,
]) {
  final l = context.l10n;
  switch (p) {
    case Period.day:
      return isSameDay(a, DateTime.now())
          ? '${l.today}, ${formatDayMonth(a)}'
          : formatDate(a);
    case Period.week:
      final r = DateRange.of(p, a);
      final last = r.end.subtract(const Duration(days: 1));
      return '${formatDayMonth(r.start)} – ${formatDayMonth(last)}';
    case Period.month:
      return l.monthLabel(a.month, a.year);
    case Period.year:
      return l.yearLabel(a.year);
    case Period.custom:
      if (custom == null) return l.selectDateRange;
      final customLast = custom.end.subtract(const Duration(days: 1));
      return '${formatDate(custom.start)} – ${formatDate(customLast)}';
  }
}

extension AppCurrencyL10n on AppCurrency {
  String localizedName(BuildContext context) {
    final l = context.l10n;
    switch (code) {
      case 'VND':
        return l.curVnd;
      case 'USD':
        return l.curUsd;
      case 'EUR':
        return l.curEur;
      case 'GBP':
        return l.curGbp;
      case 'JPY':
        return l.curJpy;
      case 'CNY':
        return l.curCny;
      case 'KRW':
        return l.curKrw;
      case 'THB':
        return l.curThb;
      case 'SGD':
        return l.curSgd;
      case 'AUD':
        return l.curAud;
      case 'CAD':
        return l.curCad;
      case 'CHF':
        return l.curChf;
      case 'INR':
        return l.curInr;
      case 'HKD':
        return l.curHkd;
      case 'MYR':
        return l.curMyr;
      case 'IDR':
        return l.curIdr;
      case 'PHP':
        return l.curPhp;
      case 'TWD':
        return l.curTwd;
      default:
        return name;
    }
  }
}

extension ExportSectionL10n on ExportSection {
  String localizedLabel(BuildContext context) {
    final l = context.l10n;
    switch (this) {
      case ExportSection.transactions:
        return l.exportSectionTransactions;
      case ExportSection.wallets:
        return l.exportSectionWallets;
      case ExportSection.budgets:
        return l.exportSectionBudgets;
      case ExportSection.goals:
        return l.exportSectionGoals;
      case ExportSection.debts:
        return l.exportSectionDebts;
      case ExportSection.recurrings:
        return l.exportSectionRecurrings;
    }
  }
}
