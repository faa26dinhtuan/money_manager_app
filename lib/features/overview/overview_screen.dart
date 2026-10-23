import 'package:flutter/material.dart';
import 'package:money_manager_app/core/widgets/app_icon.dart';
import 'package:flutter/services.dart';
import 'package:money_manager_app/core/extensions/l10n_extensions.dart';
import 'package:money_manager_app/core/extensions/model_l10n.dart';
import 'package:money_manager_app/core/theme/app_colors.dart';
import 'package:money_manager_app/core/utils/date_range.dart';
import 'package:money_manager_app/core/utils/currency.dart';
import 'package:money_manager_app/core/utils/formatters.dart';
import 'package:money_manager_app/core/widgets/date_range_dialog.dart';
import 'package:money_manager_app/core/widgets/app_card.dart';
import 'package:money_manager_app/core/widgets/category_icon.dart';
import 'package:money_manager_app/core/widgets/donut_chart.dart';
import 'package:money_manager_app/core/widgets/gradient_header.dart';
import 'package:money_manager_app/core/widgets/period_bar.dart';
import 'package:money_manager_app/core/widgets/settings_button.dart';
import 'package:money_manager_app/core/widgets/type_tabs.dart';
import 'package:money_manager_app/core/widgets/wallet_picker.dart';
import 'package:money_manager_app/core/widgets/wallet_selector.dart';
import 'package:money_manager_app/data/models/category.dart';
import 'package:money_manager_app/data/models/planned_event.dart';
import 'package:money_manager_app/data/services/app_store.dart';
import 'package:money_manager_app/features/transactions/category_transactions_screen.dart';

class OverviewScreen extends StatefulWidget {
  const OverviewScreen({super.key});

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  final _store = AppStore.instance;
  TxType _type = TxType.expense;
  Period _period = Period.month;
  DateTime _anchor = DateTime.now();
  DateRange? _customRange;

  Future<void> _pickRange() async {
    final current = _customRange;
    final picked = await showAppDateRangePicker(
      context,
      initial: current == null
          ? null
          : DateTimeRange(
              start: current.start,
              end: current.end.subtract(const Duration(days: 1)),
            ),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _customRange = DateRange(
        DateTime(picked.start.year, picked.start.month, picked.start.day),
        DateTime(picked.end.year, picked.end.month, picked.end.day + 1),
      );
      _period = Period.custom;
    });
  }

  Future<void> _confirmEventTransaction(PlannedEvent event) async {
    final l = context.l10n;
    final categories = _store.categoriesOf(event.type);
    final wallets = _store.wallets
        .where((wallet) => wallet.currencyCode == event.currencyCode)
        .toList();
    if (categories.isEmpty || wallets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.eventTransactionNeedsSetup)),
      );
      return;
    }
    var categoryId = categories.first.id;
    final preferredWalletId = event.walletId ?? _store.selectedWalletId;
    var walletId = wallets.any((wallet) => wallet.id == preferredWalletId)
        ? preferredWalletId!
        : wallets.first.id;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Text(l.confirmEventTransactionTitle),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l.confirmEventTransactionMessage),
                const SizedBox(height: 8),
                Text(
                  event.title,
                  style: Theme.of(dialogContext).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  formatMoney(
                    event.amount,
                    AppCurrency.byCode(event.currencyCode),
                  ),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: event.type == TxType.expense
                        ? context.negativeColor
                        : context.positiveColor,
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: categoryId,
                  decoration: InputDecoration(labelText: l.category),
                  items: [
                    for (final category in categories)
                      DropdownMenuItem(
                        value: category.id,
                        child: Text(category.localizedName(dialogContext)),
                      ),
                  ],
                  onChanged: (value) {
                    if (value != null) setDialogState(() => categoryId = value);
                  },
                ),
                const SizedBox(height: 12),
                Text(l.wallet, style: TextStyle(color: context.textSecondary)),
                const SizedBox(height: 6),
                WalletPicker(
                  selectedId: walletId,
                  currencyCode: event.currencyCode,
                  onChanged: (value) {
                    if (value != null) setDialogState(() => walletId = value);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l.recordEventTransaction),
            ),
          ],
        ),
      ),
    );
    if (confirmed != true || !mounted) return;
    final recorded = _store.recordPlannedEventTransaction(
      event: event,
      date: event.date,
      categoryId: categoryId,
      walletId: walletId,
    );
    if (!recorded) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.eventTransactionAlreadyRecorded)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _store,
      builder: (context, _) {
        final range = DateRange.of(_period, _anchor, _customRange);
        final todayRange = DateRange.of(Period.day, DateTime.now());
        final todayEvents = _store
            .plannedEventsInRange(todayRange)
            .where((event) => !_store.hasPlannedEventTransaction(event, event.date))
            .toList();
        final items = _store.query(
          _type,
          range,
          walletId: _store.selectedWalletId,
        );

        final totals = <String, double>{};
        for (final t in items) {
          totals[t.categoryId] = (totals[t.categoryId] ?? 0) + t.amount;
        }
        final entries = totals.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        final total = totals.values.fold<double>(0, (s, v) => s + v);

        final slices = <DonutSlice>[
          for (final e in entries)
            DonutSlice(
              e.value,
              _store.categoryById(e.key)?.color ?? Colors.grey,
            ),
        ];

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: Scaffold(
          body: Column(
            children: [
              _Header(
                balance: _store.selectedBalance,
                type: _type,
                onTypeChanged: (t) => setState(() => _type = t),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                  children: [
                    if (todayEvents.isNotEmpty) ...[
                      _TodayEventsCard(
                        events: todayEvents,
                        onRecord: _confirmEventTransaction,
                      ),
                      const SizedBox(height: 14),
                    ],
                    AppCard(
                      padding: const EdgeInsets.fromLTRB(8, 12, 8, 20),
                      radius: 24,
                      child: Column(
                          children: [
                            PeriodBar(
                              period: _period,
                              anchor: _anchor,
                              periods: Period.values,
                              customRange: _customRange,
                              onLabelTap: _pickRange,
                              onPeriodChanged: (p) {
                                if (p == Period.custom) {
                                  _pickRange();
                                  return;
                                }
                                setState(() {
                                  _period = p;
                                  _anchor = DateTime.now();
                                });
                              },
                              onShift: (d) => setState(() {
                                _anchor = DateRange.shift(_period, _anchor, d);
                              }),
                            ),
                            const SizedBox(height: 12),
                            DonutChart(
                              slices: slices,
                              size: 240,
                              thickness: 40,
                              showLabels: true,
                              interactive: true,
                              center: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _type == TxType.expense
                                        ? context.l10n.spent
                                        : context.l10n.received,
                                    style: TextStyle(
                                      color: context.textTertiary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    formatMoney(total),
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                    ),
                    const SizedBox(height: 14),
                    if (entries.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Text(
                            context.l10n.noTransactionsInRange,
                            style: TextStyle(color: context.textSecondary),
                          ),
                        ),
                      ),
                    for (final e in entries)
                      _CategoryRow(
                        category: _store.categoryById(e.key),
                        amount: e.value,
                        percent: total == 0 ? 0 : e.value / total * 100,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => CategoryTransactionsScreen(
                              categoryId: e.key,
                              type: _type,
                              range: range,
                              rangeLabel: localizedDateRangeLabel(
                                context,
                                _period,
                                _anchor,
                                _customRange,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          ),
        );
      },
    );
  }
}

class _TodayEventsCard extends StatelessWidget {
  const _TodayEventsCard({required this.events, required this.onRecord});

  final List<PlannedEvent> events;
  final ValueChanged<PlannedEvent> onRecord;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      radius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.todayEvents,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          for (var index = 0; index < events.length; index++) ...[
            if (index > 0) const Divider(height: 16),
            _TodayEventReminder(event: events[index], onRecord: onRecord),
          ],
        ],
      ),
    );
  }
}

class _TodayEventReminder extends StatelessWidget {
  const _TodayEventReminder({required this.event, required this.onRecord});

  final PlannedEvent event;
  final ValueChanged<PlannedEvent> onRecord;

  @override
  Widget build(BuildContext context) {
    final color = event.type == TxType.expense
        ? context.negativeColor
        : context.positiveColor;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const AppIcon(AppIcons.calendar, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.type == TxType.expense
                        ? context.l10n.plannedExpense
                        : context.l10n.plannedIncome,
                    style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    event.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              formatMoney(event.amount, AppCurrency.byCode(event.currencyCode)),
              style: TextStyle(color: color, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        if (event.note.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(event.note, style: TextStyle(color: context.textSecondary)),
        ],
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () => onRecord(event),
            icon: const AppIcon(AppIcons.check, size: 18),
            label: Text(context.l10n.recordEventTransaction),
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.balance,
    required this.type,
    required this.onTypeChanged,
  });

  final double balance;
  final TxType type;
  final ValueChanged<TxType> onTypeChanged;

  @override
  Widget build(BuildContext context) {
    return GradientHeader(
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const SizedBox(
              height: 48,
              child: Row(
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: WalletSelector(onPrimary: true),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 4),
                    child: SettingsButton(color: Colors.white),
                  ),
                ],
              ),
            ),
            Text(
              context.l10n.balanceUpper,
              style: const TextStyle(color: Colors.white70, letterSpacing: 1.5),
            ),
            const SizedBox(height: 4),
            Text(
              formatMoney(balance),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TypeTabs(
                type: type,
                onChanged: onTypeChanged,
                onPrimary: true,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.category,
    required this.amount,
    required this.percent,
    required this.onTap,
  });

  final Category? category;
  final double amount;
  final double percent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = category?.color ?? Colors.grey;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: context.cardDecoration(radius: 16),
        child: Column(
          children: [
            Row(
              children: [
                CategoryIcon(
                  icon: category?.icon ?? AppIcons.help,
                  color: color,
                  size: 38,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    category?.localizedName(context) ?? context.l10n.other,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                Text(
                  formatPercent(percent),
                  style: TextStyle(color: context.textTertiary),
                ),
                const SizedBox(width: 16),
                Text(
                  formatMoney(amount),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Container(
                width: double.infinity,
                height: 5,
                alignment: Alignment.centerLeft,
                color: color.withValues(alpha: 0.14),
                child: FractionallySizedBox(
                  widthFactor: (percent / 100).clamp(0.0, 1.0),
                  child: Container(color: color),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
