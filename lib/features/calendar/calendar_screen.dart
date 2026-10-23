import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:money_manager_app/core/extensions/l10n_extensions.dart';
import 'package:money_manager_app/core/extensions/model_l10n.dart';
import 'package:money_manager_app/core/theme/app_colors.dart';
import 'package:money_manager_app/core/theme/app_theme.dart';
import 'package:money_manager_app/core/utils/date_range.dart';
import 'package:money_manager_app/core/utils/formatters.dart';
import 'package:money_manager_app/core/widgets/app_icon.dart';
import 'package:money_manager_app/core/widgets/category_icon.dart';
import 'package:money_manager_app/core/widgets/settings_button.dart';
import 'package:money_manager_app/core/widgets/type_tabs.dart';
import 'package:money_manager_app/core/widgets/wallet_selector.dart';
import 'package:money_manager_app/data/models/category.dart';
import 'package:money_manager_app/data/models/transaction.dart';
import 'package:money_manager_app/data/services/app_store.dart';
import 'package:money_manager_app/features/transactions/add_transaction_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final _store = AppStore.instance;
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime _selectedDay = DateTime.now();
  TxType _type = TxType.expense;

  void _moveMonth(int amount) {
    HapticFeedback.selectionClick();
    setState(() {
      _month = DateTime(_month.year, _month.month + amount);
      final lastDay = DateTime(_month.year, _month.month + 1, 0).day;
      _selectedDay = DateTime(
        _month.year,
        _month.month,
        _selectedDay.day.clamp(1, lastDay).toInt(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return ListenableBuilder(
      listenable: _store,
      builder: (context, _) {
        final monthRange = DateRange.of(Period.month, _month);
        final walletId = _store.selectedWalletId;
        final expenses = _store.query(
          TxType.expense,
          monthRange,
          walletId: walletId,
        );
        final incomes = _store.query(
          TxType.income,
          monthRange,
          walletId: walletId,
        );
        final selectedTransactions = [...expenses, ...incomes]
          ..removeWhere((t) => !isSameDay(t.date, _selectedDay))
          ..sort((a, b) => b.date.compareTo(a.date));
        final daily = <DateTime, double>{};
        for (final t in _type == TxType.expense ? expenses : incomes) {
          final day = DateTime(t.date.year, t.date.month, t.date.day);
          daily.update(day, (sum) => sum + t.amount, ifAbsent: () => t.amount);
        }

        return Scaffold(
          appBar: AppBar(
            leadingWidth: 156,
            leading: const Align(
              alignment: Alignment.centerLeft,
              child: WalletSelector(),
            ),
            title: Text(l.calendar),
            actions: const [SettingsButton()],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            children: [
              _MonthHeader(
                label: l.monthLabel(_month.month, _month.year),
                onPrevious: () => _moveMonth(-1),
                onNext: () => _moveMonth(1),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      label: l.incomeSummary,
                      amount: _sum(incomes),
                      color: context.positiveColor,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _SummaryCard(
                      label: l.expenseSummary,
                      amount: _sum(expenses),
                      color: context.negativeColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TypeTabs(
                type: _type,
                onChanged: (type) => setState(() => _type = type),
              ),
              const SizedBox(height: 8),
              _CalendarGrid(
                month: _month,
                selectedDay: _selectedDay,
                amounts: daily,
                type: _type,
                onSelect: (day) {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedDay = day);
                },
              ),
              const SizedBox(height: 18),
              Text(
                DateFormat.yMMMMd(Localizations.localeOf(context).toLanguageTag())
                    .format(_selectedDay),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              if (selectedTransactions.isEmpty)
                _EmptyDay(message: l.noTransactionsInRange)
              else
                for (final transaction in selectedTransactions)
                  _TransactionRow(
                    transaction: transaction,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AddTransactionScreen(
                          transaction: transaction,
                        ),
                      ),
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }

  double _sum(List<Transaction> items) =>
      items.fold<double>(0, (sum, item) => sum + item.amount);
}

class _MonthHeader extends StatelessWidget {
  const _MonthHeader({
    required this.label,
    required this.onPrevious,
    required this.onNext,
  });

  final String label;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onPrevious,
          tooltip: context.l10n.previousMonth,
          icon: const AppIcon(AppIcons.chevronLeft),
        ),
        Expanded(
          child: Center(
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: onNext,
          tooltip: context.l10n.nextMonth,
          icon: const AppIcon(AppIcons.chevronRight),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.amount,
    required this.color,
  });

  final String label;
  final double amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: context.cardDecoration(radius: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: context.textSecondary, fontSize: 12)),
          const SizedBox(height: 5),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              formatMoney(amount),
              style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 17),
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  const _CalendarGrid({
    required this.month,
    required this.selectedDay,
    required this.amounts,
    required this.type,
    required this.onSelect,
  });

  final DateTime month;
  final DateTime selectedDay;
  final Map<DateTime, double> amounts;
  final TxType type;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final weekdays = [
      l.weekdayMon,
      l.weekdayTue,
      l.weekdayWed,
      l.weekdayThu,
      l.weekdayFri,
      l.weekdaySat,
      l.weekdaySun,
    ];
    final firstOffset = DateTime(month.year, month.month, 1).weekday - 1;
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final count = ((firstOffset + daysInMonth + 6) ~/ 7) * 7;
    final color = type == TxType.expense
        ? context.negativeColor
        : context.positiveColor;
    return Column(
      children: [
        Row(
          children: [
            for (var i = 0; i < 7; i++)
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      weekdays[i],
                      style: TextStyle(
                        color: i == 6 ? context.negativeColor : context.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: count,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisExtent: 66,
          ),
          itemBuilder: (context, index) {
            final dayNumber = index - firstOffset + 1;
            if (dayNumber < 1 || dayNumber > daysInMonth) {
              return const SizedBox.shrink();
            }
            final day = DateTime(month.year, month.month, dayNumber);
            final amount = amounts[day];
            final selected = isSameDay(day, selectedDay);
            final today = isSameDay(day, DateTime.now());
            return Padding(
              padding: const EdgeInsets.all(2),
              child: Material(
                color: selected ? AppTheme.primary.withValues(alpha: 0.15) : Colors.transparent,
                borderRadius: BorderRadius.circular(11),
                child: InkWell(
                  borderRadius: BorderRadius.circular(11),
                  onTap: () => onSelect(day),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(3, 5, 3, 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          width: 25,
                          height: 25,
                          alignment: Alignment.center,
                          decoration: today
                              ? BoxDecoration(
                                  color: AppTheme.primary,
                                  borderRadius: BorderRadius.circular(9),
                                )
                              : null,
                          child: Text(
                            '$dayNumber',
                            style: TextStyle(
                              color: today ? Colors.white : context.textPrimary,
                              fontWeight: selected || today ? FontWeight.w700 : FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        if (amount != null && amount > 0) ...[
                          const SizedBox(height: 2),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              NumberFormat.compact(
                                locale: Localizations.localeOf(context).toLanguageTag(),
                              ).format(amount),
                              maxLines: 1,
                              style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _TransactionRow extends StatelessWidget {
  const _TransactionRow({required this.transaction, required this.onTap});

  final Transaction transaction;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final store = AppStore.instance;
    final category = store.categoryById(transaction.categoryId);
    final expense = transaction.type == TxType.expense;
    final color = expense ? context.negativeColor : context.positiveColor;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: context.surfaceColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: context.outlineColor.withValues(alpha: 0.6)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: CategoryIcon(
          icon: category?.icon ?? AppIcons.categories,
          color: category?.color ?? AppTheme.primary,
          size: 38,
        ),
        title: Text(
          category?.localizedName(context) ?? context.l10n.other,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: transaction.note.isEmpty
            ? null
            : Text(transaction.note, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: Text(
          '${expense ? '−' : '+'}${formatMoney(transaction.amount)}',
          style: TextStyle(color: color, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _EmptyDay extends StatelessWidget {
  const _EmptyDay({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      alignment: Alignment.center,
      decoration: context.cardDecoration(radius: 18),
      child: Text(message, style: TextStyle(color: context.textSecondary)),
    );
  }
}
