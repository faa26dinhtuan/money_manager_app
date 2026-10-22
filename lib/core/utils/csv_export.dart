import 'package:money_manager_app/core/extensions/model_l10n.dart';
import 'package:money_manager_app/core/utils/date_range.dart';
import 'package:money_manager_app/core/utils/debt_status.dart';
import 'package:money_manager_app/core/utils/formatters.dart';
import 'package:money_manager_app/core/utils/goal_status.dart';
import 'package:money_manager_app/data/services/app_store.dart';
import 'package:money_manager_app/l10n/app_localizations.dart';

enum ExportSection { transactions, wallets, budgets, goals, debts, recurrings }

String _cell(String value) {
  if (value.contains(RegExp(r'[",\r\n]'))) {
    return '"${value.replaceAll('"', '""')}"';
  }
  return value;
}

String _amount(double value) =>
    value == value.roundToDouble() ? value.toStringAsFixed(0) : value.toString();

String _date(DateTime? d) => d == null ? '' : formatDate(d);

String _line(List<String> row) => row.map(_cell).join(',');

String _section(String title, List<String> header, List<List<String>> rows) {
  if (rows.isEmpty) return '';
  return [_line([title]), _line(header), ...rows.map(_line)].join('\r\n');
}

String exportToCsv(
  AppStore store,
  Set<ExportSection> selected,
  AppLocalizations l,
) {
  final now = DateTime.now();
  final month = DateRange.of(Period.month, now);

  String walletName(String? id) =>
      id == null ? '' : (store.walletById(id)?.nameOf(l) ?? '');
  String categoryName(String id) =>
      store.categoryById(id)?.nameOf(l) ?? l.other;

  final transactions = [...store.transactions]
    ..sort((a, b) => b.date.compareTo(a.date));

  final parts = <ExportSection, List<String>>{
    ExportSection.transactions: [
      _section(
        l.exportSectionTransactions.toUpperCase(),
        [l.date, l.type, l.category, l.wallet, l.amount, l.currencyCodeLabel, l.note],
        [
          for (final t in transactions)
            [
              _date(t.date),
              t.type.labelOf(l),
              categoryName(t.categoryId),
              walletName(t.walletId),
              _amount(t.amount),
              store.walletById(t.walletId)?.currencyCode ?? '',
              t.note,
            ],
        ],
      ),
    ],
    ExportSection.wallets: [
      _section(
        l.exportSectionWallets.toUpperCase(),
        [l.walletName, l.currencyCodeLabel, l.initialBalance, l.currentBalance],
        [
          for (final w in store.wallets)
            [
              w.nameOf(l),
              w.currencyCode,
              _amount(w.initialBalance),
              _amount(store.walletBalance(w.id)),
            ],
        ],
      ),
    ],
    ExportSection.budgets: [
      _section(
        l.csvBudgetTitle(now.month, now.year),
        [l.category, l.currencyCodeLabel, l.limitLabel, l.spent, l.remaining],
        [
          for (final b in store.allBudgets)
            () {
              final spent = store.spentOfCategory(
                b.categoryId,
                month,
                currencyCode: b.currencyCode,
              );
              return [
                categoryName(b.categoryId),
                b.currencyCode,
                _amount(b.limit),
                _amount(spent),
                _amount(b.limit - spent),
              ];
            }(),
        ],
      ),
    ],
    ExportSection.goals: [
      _section(
        l.exportSectionGoals.toUpperCase(),
        [
          l.goalName,
          l.currencyCodeLabel,
          l.targetAmount,
          l.savedLabel,
          l.remaining,
          l.progress,
          l.deadline,
          l.status,
        ],
        [
          for (final g in store.allGoals)
            [
              g.name,
              g.currencyCode,
              _amount(g.target),
              _amount(g.saved),
              _amount(g.remaining),
              formatPercent(g.progress * 100),
              _date(g.deadline),
              goalDeadlineText(g, now, l),
            ],
        ],
      ),
      _section(
        l.csvGoalHistory.toUpperCase(),
        [l.goalName, l.date, l.type, l.amount, l.currencyCodeLabel, l.wallet, l.note],
        [
          for (final g in store.allGoals)
            for (final e
                in [...g.entries]..sort((a, b) => b.date.compareTo(a.date)))
              [
                g.name,
                _date(e.date),
                e.isDeposit ? l.deposit : l.withdraw,
                _amount(e.amount.abs()),
                g.currencyCode,
                walletName(e.walletId),
                e.note,
              ],
        ],
      ),
    ],
    ExportSection.debts: [
      _section(
        l.exportSectionDebts.toUpperCase(),
        [
          l.type,
          l.person,
          l.currencyCodeLabel,
          l.amount,
          l.paid,
          l.remaining,
          l.createdDate,
          l.dueDate,
          l.wallet,
          l.status,
          l.note,
        ],
        [
          for (final d in store.allDebts)
            [
              d.type.labelOf(l),
              d.person,
              d.currencyCode,
              _amount(d.amount),
              _amount(d.paid),
              _amount(d.remaining),
              _date(d.date),
              _date(d.dueDate),
              walletName(d.walletId),
              debtDueText(d, now, l),
              d.note,
            ],
        ],
      ),
      _section(
        l.csvDebtPayments.toUpperCase(),
        [l.person, l.type, l.date, l.amount, l.currencyCodeLabel, l.wallet, l.note],
        [
          for (final d in store.allDebts)
            for (final p
                in [...d.payments]..sort((a, b) => b.date.compareTo(a.date)))
              [
                d.person,
                d.type.paymentLabelOf(l),
                _date(p.date),
                _amount(p.amount),
                d.currencyCode,
                walletName(p.walletId),
                p.note,
              ],
        ],
      ),
    ],
    ExportSection.recurrings: [
      _section(
        l.exportSectionRecurrings.toUpperCase(),
        [
          l.type,
          l.category,
          l.wallet,
          l.amount,
          l.currencyCodeLabel,
          l.frequency,
          l.startDate,
          l.nextDate,
          l.endDate,
          l.status,
          l.note,
        ],
        [
          for (final r in store.allRecurrings)
            [
              r.type.labelOf(l),
              categoryName(r.categoryId),
              walletName(r.walletId),
              _amount(r.amount),
              store.walletById(r.walletId)?.currencyCode ?? '',
              r.frequency.labelOf(l),
              _date(r.startDate),
              _date(r.nextDate),
              _date(r.endDate),
              r.isFinished ? l.finished : (r.active ? l.active : l.paused),
              r.note,
            ],
        ],
      ),
    ],
  };

  return [
    for (final section in ExportSection.values)
      if (selected.contains(section)) ...parts[section]!,
  ].where((s) => s.isNotEmpty).join('\r\n\r\n');
}
