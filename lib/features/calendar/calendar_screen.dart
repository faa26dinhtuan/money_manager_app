import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:money_manager_app/core/extensions/l10n_extensions.dart';
import 'package:money_manager_app/core/extensions/model_l10n.dart';
import 'package:money_manager_app/core/theme/app_colors.dart';
import 'package:money_manager_app/core/theme/app_theme.dart';
import 'package:money_manager_app/core/utils/date_range.dart';
import 'package:money_manager_app/core/utils/currency.dart';
import 'package:money_manager_app/core/utils/formatters.dart';
import 'package:money_manager_app/core/widgets/app_icon.dart';
import 'package:money_manager_app/core/widgets/category_icon.dart';
import 'package:money_manager_app/core/widgets/confirm_delete_dialog.dart';
import 'package:money_manager_app/core/widgets/settings_button.dart';
import 'package:money_manager_app/core/widgets/wallet_selector.dart';
import 'package:money_manager_app/data/models/category.dart';
import 'package:money_manager_app/data/models/planned_event.dart';
import 'package:money_manager_app/data/models/transaction.dart';
import 'package:money_manager_app/data/services/app_store.dart';
import 'package:money_manager_app/features/transactions/add_transaction_screen.dart';
import 'package:money_manager_app/features/calendar/planned_event_form_sheet.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final _store = AppStore.instance;
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime _selectedDay = DateTime.now();
  final Set<TxType> _visibleTypes = {TxType.expense, TxType.income};

  void _toggleType(TxType type) {
    setState(() {
      if (_visibleTypes.contains(type)) {
        if (_visibleTypes.length > 1) _visibleTypes.remove(type);
      } else {
        _visibleTypes.add(type);
      }
    });
  }

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

  Future<void> _editPlannedEvent({
    PlannedEvent? event,
    DateTime? date,
    bool allowDateChange = true,
  }) async {
    final result = await showModalBottomSheet<PlannedEventFormResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: context.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => PlannedEventFormSheet(
        initialDate: date ?? _selectedDay,
        allowDateChange: allowDateChange,
        event: event,
      ),
    );
    if (result == null) return;
    if (event == null) {
      _store.addPlannedEvent(result.event);
    } else {
      _store.updatePlannedEvent(result.event);
    }
    setState(() {
      _selectedDay = DateTime(
        result.event.date.year,
        result.event.date.month,
        result.event.date.day,
      );
      _month = DateTime(result.event.date.year, result.event.date.month);
    });
  }

  Future<void> _deletePlannedEvent(PlannedEvent event) async {
    final l = context.l10n;
    if (event.frequency != null) {
      final deleteSeries = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(l.deletePlannedEventTitle),
          content: Text(l.deleteRecurringEventWarning),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(null),
              child: Text(l.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l.deleteThisOccurrence),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(foregroundColor: context.negativeColor),
              child: Text(l.deleteEventSeries),
            ),
          ],
        ),
      );
      if (deleteSeries == null) return;
      if (deleteSeries) {
        _store.removePlannedEvent(event.id);
      } else {
        _store.skipPlannedEventOccurrence(event.id, event.date);
      }
      return;
    }
    final confirmed = await confirmDelete(
      context,
      title: l.deletePlannedEventTitle,
      message: l.deletePlannedEventMessage,
    );
    if (confirmed) _store.removePlannedEvent(event.id);
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
        final plannedEvents = _store.plannedEventsInRange(monthRange);
        final selectedEvents = plannedEvents
            .where((event) => isSameDay(event.date, _selectedDay))
            .toList();
        final selectedTransactions = [...expenses, ...incomes]
          ..removeWhere((t) => !isSameDay(t.date, _selectedDay))
          ..sort((a, b) => b.date.compareTo(a.date));
        final dailyExpenses = <DateTime, double>{};
        final dailyIncomes = <DateTime, double>{};
        final plannedDays = <DateTime>{};
        for (final event in plannedEvents) {
          plannedDays.add(DateTime(event.date.year, event.date.month, event.date.day));
        }
        for (final t in expenses) {
          final day = DateTime(t.date.year, t.date.month, t.date.day);
          dailyExpenses.update(day, (sum) => sum + t.amount, ifAbsent: () => t.amount);
        }
        for (final t in incomes) {
          final day = DateTime(t.date.year, t.date.month, t.date.day);
          dailyIncomes.update(day, (sum) => sum + t.amount, ifAbsent: () => t.amount);
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
              _CalendarFilters(
                visibleTypes: _visibleTypes,
                onToggle: _toggleType,
                onCreate: () => _editPlannedEvent(date: _selectedDay),
              ),
              const SizedBox(height: 8),
              _CalendarGrid(
                month: _month,
                selectedDay: _selectedDay,
                expenses: dailyExpenses,
                incomes: dailyIncomes,
                plannedDays: plannedDays,
                visibleTypes: _visibleTypes,
                onSelect: (day) {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedDay = day);
                },
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      DateFormat.yMMMMd(Localizations.localeOf(context).toLanguageTag())
                          .format(_selectedDay),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton.filledTonal(
                    tooltip: l.addPlannedEvent,
                    onPressed: () => _editPlannedEvent(
                      date: _selectedDay,
                      allowDateChange: false,
                    ),
                    icon: const AppIcon(AppIcons.add, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(l.transactions, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              if (selectedTransactions.isEmpty)
                _EmptyDay(message: l.noTransactionsOnDate)
              else
                for (final transaction in selectedTransactions)
                  _TransactionRow(
                    transaction: transaction,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AddTransactionScreen(transaction: transaction),
                      ),
                    ),
                  ),
              const SizedBox(height: 14),
              Text(l.dayEvents, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              if (selectedEvents.isEmpty)
                _EmptyDay(message: l.noEventsOnDate)
              else
                for (final event in selectedEvents)
                  _PlannedEventRow(
                    event: event,
                    onEdit: () => _editPlannedEvent(event: event),
                    onDelete: () => _deletePlannedEvent(event),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: context.cardDecoration(radius: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: context.textSecondary, fontSize: 12)),
          const SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              formatMoney(amount),
              style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 15),
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
    required this.expenses,
    required this.incomes,
    required this.plannedDays,
    required this.visibleTypes,
    required this.onSelect,
  });

  final DateTime month;
  final DateTime selectedDay;
  final Map<DateTime, double> expenses;
  final Map<DateTime, double> incomes;
  final Set<DateTime> plannedDays;
  final Set<TxType> visibleTypes;
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
            mainAxisExtent: 80,
          ),
          itemBuilder: (context, index) {
            final dayNumber = index - firstOffset + 1;
            if (dayNumber < 1 || dayNumber > daysInMonth) {
              return const SizedBox.shrink();
            }
            final day = DateTime(month.year, month.month, dayNumber);
            final expense = expenses[day];
            final income = incomes[day];
            final hasPlannedEvent = plannedDays.contains(day);
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
                        if (visibleTypes.contains(TxType.income) && income != null)
                          _DayAmount(amount: income, color: context.positiveColor),
                        if (visibleTypes.contains(TxType.expense) && expense != null)
                          _DayAmount(amount: expense, color: context.negativeColor),
                        if (hasPlannedEvent)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Container(
                              width: 5,
                              height: 5,
                              decoration: const BoxDecoration(
                                color: AppTheme.accent,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
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

class _DayAmount extends StatelessWidget {
  const _DayAmount({required this.amount, required this.color});

  final double amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final currency = AppCurrency.current;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final compactNumber = NumberFormat.compact(locale: locale).format(amount);
    final compactMoney = withCurrencySymbol(compactNumber, currency: currency);
    return Padding(
      padding: const EdgeInsets.only(top: 1),
      child: SizedBox(
        width: double.infinity,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            compactMoney,
            maxLines: 1,
            style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

class _PlannedEventRow extends StatelessWidget {
  const _PlannedEventRow({
    required this.event,
    required this.onEdit,
    required this.onDelete,
  });

  final PlannedEvent event;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isExpense = event.type == TxType.expense;
    final color = isExpense ? context.negativeColor : context.positiveColor;
    final eventDay = DateTime(event.date.year, event.date.month, event.date.day);
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final isPast = eventDay.isBefore(todayDate);
    final isToday = eventDay.isAtSameMomentAs(todayDate);
    final status = isPast
        ? context.l10n.pastEvent
        : isToday
        ? context.l10n.todayEvent
        : context.l10n.plannedEvent;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: context.surfaceColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppTheme.accent.withValues(alpha: 0.55)),
      ),
      child: ListTile(
        onTap: onEdit,
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppTheme.accent.withValues(alpha: 0.16),
            shape: BoxShape.circle,
          ),
          child: const AppIcon(AppIcons.calendar, color: AppTheme.primary, size: 20),
        ),
        title: Text(event.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(status),
            if (event.note.isNotEmpty || event.frequency != null)
              Text(
                [
                  if (event.note.isNotEmpty) event.note,
                  if (event.frequency != null) event.frequency!.localizedLabel(context),
                ].join(' · '),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${isExpense ? '−' : '+'}${formatMoney(event.amount, AppCurrency.byCode(event.currencyCode))}',
              style: TextStyle(color: color, fontWeight: FontWeight.w700),
            ),
            PopupMenuButton<String>(
              onSelected: (value) => value == 'edit' ? onEdit() : onDelete(),
              itemBuilder: (context) => [
                PopupMenuItem(value: 'edit', child: Text(context.l10n.edit)),
                PopupMenuItem(value: 'delete', child: Text(context.l10n.delete)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CalendarFilters extends StatelessWidget {
  const _CalendarFilters({
    required this.visibleTypes,
    required this.onToggle,
    required this.onCreate,
  });

  final Set<TxType> visibleTypes;
  final ValueChanged<TxType> onToggle;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton.icon(
          onPressed: onCreate,
          style: TextButton.styleFrom(
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
          icon: const AppIcon(AppIcons.add, size: 18),
          label: Text(l.addPlannedEvent, maxLines: 1),
        ),
        const Spacer(),
        FilterChip(
          label: Text(l.incomeSummary),
          selected: visibleTypes.contains(TxType.income),
          onSelected: (_) => onToggle(TxType.income),
          visualDensity: VisualDensity.compact,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          labelStyle: TextStyle(color: context.positiveColor, fontSize: 11),
        ),
        const SizedBox(width: 6),
        FilterChip(
          label: Text(l.expenseSummary),
          selected: visibleTypes.contains(TxType.expense),
          onSelected: (_) => onToggle(TxType.expense),
          visualDensity: VisualDensity.compact,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          labelStyle: TextStyle(color: context.negativeColor, fontSize: 11),
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
