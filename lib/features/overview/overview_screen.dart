import 'package:flutter/material.dart';
import 'package:money_manager_app/core/widgets/app_icon.dart';
import 'package:flutter/services.dart';
import 'package:money_manager_app/core/extensions/l10n_extensions.dart';
import 'package:money_manager_app/core/extensions/model_l10n.dart';
import 'package:money_manager_app/core/theme/app_colors.dart';
import 'package:money_manager_app/core/theme/app_theme.dart';
import 'package:money_manager_app/core/utils/date_range.dart';
import 'package:money_manager_app/core/utils/currency.dart';
import 'package:money_manager_app/core/utils/formatters.dart';
import 'package:money_manager_app/core/widgets/date_range_dialog.dart';
import 'package:money_manager_app/core/widgets/app_card.dart';
import 'package:money_manager_app/core/widgets/category_icon.dart';
import 'package:money_manager_app/core/widgets/donut_chart.dart';
import 'package:money_manager_app/core/widgets/gradient_header.dart';
import 'package:money_manager_app/core/widgets/money_field.dart';
import 'package:money_manager_app/core/widgets/period_bar.dart';
import 'package:money_manager_app/core/widgets/settings_button.dart';
import 'package:money_manager_app/core/widgets/sensitive_balance.dart';
import 'package:money_manager_app/core/widgets/type_tabs.dart';
import 'package:money_manager_app/core/widgets/wallet_picker.dart';
import 'package:money_manager_app/core/widgets/wallet_selector.dart';
import 'package:money_manager_app/data/models/category.dart';
import 'package:money_manager_app/data/models/planned_event.dart';
import 'package:money_manager_app/data/services/app_store.dart';
import 'package:money_manager_app/features/transactions/category_transactions_screen.dart';
import 'package:money_manager_app/features/overview/overview_guide_dialog.dart';

class OverviewScreen extends StatefulWidget {
  const OverviewScreen({super.key, required this.guideController});

  final OverviewGuideController guideController;

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  final _store = AppStore.instance;
  TxType _type = TxType.expense;
  Period _period = Period.month;
  DateTime _anchor = DateTime.now();
  DateRange? _customRange;
  late final _guideController = widget.guideController;
  bool _guideSampleWalletSelected = true;
  bool _guideChartSelected = false;

  double get _guidePeriodFactor => switch (_period) {
    Period.day => 0.04,
    Period.week => 0.25,
    Period.month => 1,
    Period.year => 12,
    Period.custom => 1,
  };

  @override
  void initState() {
    super.initState();
    _guideController.addListener(_onGuideChanged);
  }

  @override
  void dispose() {
    _guideController.removeListener(_onGuideChanged);
    super.dispose();
  }

  void _onGuideChanged() {
    if (mounted) setState(() {});
  }

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
    _guideController.markInteraction(3);
  }

  Future<void> _confirmEventTransaction(PlannedEvent event) async {
    final l = context.l10n;
    final categories = _store.categoriesOf(event.type);
    final wallets = _store.wallets
        .where((wallet) => wallet.currencyCode == event.currencyCode)
        .toList();
    if (categories.isEmpty || wallets.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l.eventTransactionNeedsSetup)));
      return;
    }
    final preferredWalletId = event.walletId ?? _store.selectedWalletId;
    final initialWalletId =
        wallets.any((wallet) => wallet.id == preferredWalletId)
        ? preferredWalletId!
        : wallets.first.id;
    final input = await showAdaptiveDialog<_EventTransactionInput>(
      context: context,
      builder: (_) => _RecordEventTransactionDialog(
        event: event,
        categoryId: categories.first.id,
        walletId: initialWalletId,
      ),
    );
    if (!mounted || input == null) return;
    final projectedBalance =
        _store.walletBalance(input.walletId) -
        (event.type == TxType.expense ? input.amount : -input.amount);
    if (projectedBalance < 0) {
      final confirmed = await showAdaptiveDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          title: Text(l.negativeWalletBalanceTitle),
          content: Text(l.negativeWalletBalanceMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l.recordAnyway),
            ),
          ],
        ),
      );
      if (!mounted || confirmed != true) return;
    }
    final recorded = _store.recordPlannedEventTransaction(
      event: event,
      date: event.date,
      categoryId: input.categoryId,
      walletId: input.walletId,
      amount: input.amount,
    );
    if (!recorded && mounted) {
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
        final todayEvents = _guideController.active
            ? <PlannedEvent>[]
            : _store
                  .plannedEventsInRange(todayRange, includeAllWallets: true)
                  .toList();
        final items = _store.query(
          _type,
          range,
          walletId: _store.selectedWalletId,
        );

        final totals = <String, double>{};
        if (_guideController.active) {
          totals[
            _type == TxType.expense ? 'guide_expense' : 'guide_income'
          ] = (_type == TxType.expense ? 850000 : 4500000) *
              _guidePeriodFactor;
        } else {
          for (final t in items) {
            totals[t.categoryId] = (totals[t.categoryId] ?? 0) + t.amount;
          }
        }
        final entries = totals.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        final total = totals.values.fold<double>(0, (s, v) => s + v);

        final slices = <DonutSlice>[
          for (final e in entries)
            DonutSlice(
              e.value,
              _guideController.active
                  ? AppTheme.primary
                  : _store.categoryById(e.key)?.color ?? Colors.grey,
            ),
        ];

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: Scaffold(
            body: Column(
              children: [
                _Header(
                  balance: _guideController.active
                      ? (_guideSampleWalletSelected ? 4200000 : 6250000)
                      : _store.selectedBalance,
                  type: _type,
                  guideMode: _guideController.active,
                  sampleWalletSelected: _guideSampleWalletSelected,
                  onSampleWalletChanged: (selected) => setState(
                    () => _guideSampleWalletSelected = selected,
                  ),
                  onWalletInteraction: () =>
                      _guideController.markInteraction(0),
                  onBalanceVisibilityChanged: () =>
                      _guideController.markInteraction(1),
                  onTypeChanged: (t) {
                    setState(() {
                      _type = t;
                      _guideChartSelected = false;
                    });
                    _guideController.markInteraction(2);
                  },
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                    physics: _guideController.active
                        ? const NeverScrollableScrollPhysics()
                        : null,
                    children: [
                      if (todayEvents.isNotEmpty) ...[
                        _TodayEventsCard(
                          events: todayEvents,
                          onRecord: _confirmEventTransaction,
                          isRecorded: (event) => _store
                              .hasPlannedEventTransaction(event, event.date),
                        ),
                        const SizedBox(height: 14),
                      ],
                      AppCard(
                        padding: const EdgeInsets.fromLTRB(8, 12, 8, 20),
                        radius: 24,
                        child: Column(
                          children: [
                            PeriodBar(
                              key: OverviewGuideTargets.period,
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
                                _guideController.markInteraction(3);
                              },
                              onShift: (d) {
                                setState(() {
                                  _anchor = DateRange.shift(_period, _anchor, d);
                                });
                                _guideController.markInteraction(3);
                              },
                            ),
                            const SizedBox(height: 12),
                            DonutChart(
                              key: OverviewGuideTargets.chart,
                              slices: slices,
                              size: 240,
                              thickness: 40,
                              showLabels: true,
                              interactive: true,
                              onInteraction: () {
                                if (_guideController.active) {
                                  setState(() => _guideChartSelected = true);
                                }
                              },
                              center: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _guideController.active && _guideChartSelected
                                        ? _type == TxType.expense
                                              ? context.l10n.overviewGuideSampleExpenseCategory
                                              : context.l10n.overviewGuideSampleIncomeCategory
                                        : _type == TxType.expense
                                              ? context.l10n.spent
                                              : context.l10n.received,
                                    style: TextStyle(
                                      color: context.textTertiary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    formatMoney(
                                      _guideController.active && _guideChartSelected
                                          ? (_type == TxType.expense
                                                    ? 850000
                                                    : 4500000) *
                                                _guidePeriodFactor
                                          : total,
                                    ),
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
                          key: OverviewGuideTargets.transactions,
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
                          key: identical(e, entries.first)
                              ? OverviewGuideTargets.transactions
                              : null,
                          category: _store.categoryById(e.key),
                          displayName: _guideController.active
                              ? _type == TxType.expense
                                    ? context.l10n.overviewGuideSampleExpenseCategory
                                    : context.l10n.overviewGuideSampleIncomeCategory
                              : null,
                          displayIcon: _guideController.active
                              ? _type == TxType.expense
                                    ? AppIcons.restaurant
                                    : AppIcons.received
                              : null,
                          displayColor: _guideController.active
                              ? AppTheme.primary
                              : null,
                          amount: e.value,
                          percent: total == 0
                              ? 0
                              : e.value / total * 100,
                          onTap: () {
                            if (_guideController.active) {
                              _openGuideCategoryTransactions(e.key, range);
                              return;
                            }
                            Navigator.of(context).push(
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
                            );
                          },
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

  Future<void> _openGuideCategoryTransactions(
    String categoryId,
    DateRange range,
  ) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CategoryTransactionsScreen(
          categoryId: categoryId,
          type: _type,
          range: range,
          rangeLabel: localizedDateRangeLabel(
            context,
            _period,
            _anchor,
            _customRange,
          ),
          guideMode: true,
          guideCategoryName: _type == TxType.expense
              ? context.l10n.overviewGuideSampleExpenseCategory
              : context.l10n.overviewGuideSampleIncomeCategory,
          guideTransactionName: _type == TxType.expense
              ? context.l10n.overviewGuideSampleExpenseTransaction
              : context.l10n.overviewGuideSampleIncomeTransaction,
          guideIcon: _type == TxType.expense
              ? AppIcons.restaurant
              : AppIcons.received,
          guideColor: AppTheme.primary,
          guideAmount: (_type == TxType.expense ? 850000 : 4500000) *
              _guidePeriodFactor,
        ),
      ),
    );
    if (mounted) _guideController.markInteraction(4);
  }
}

class _EventTransactionInput {
  const _EventTransactionInput({
    required this.categoryId,
    required this.walletId,
    required this.amount,
  });

  final String categoryId;
  final String walletId;
  final double amount;
}

class _RecordEventTransactionDialog extends StatefulWidget {
  const _RecordEventTransactionDialog({
    required this.event,
    required this.categoryId,
    required this.walletId,
  });

  final PlannedEvent event;
  final String categoryId;
  final String walletId;

  @override
  State<_RecordEventTransactionDialog> createState() =>
      _RecordEventTransactionDialogState();
}

class _RecordEventTransactionDialogState
    extends State<_RecordEventTransactionDialog> {
  final _store = AppStore.instance;
  late final MoneyController _amountController;
  late String _categoryId = widget.categoryId;
  late String _walletId = widget.walletId;

  @override
  void initState() {
    super.initState();
    _amountController = MoneyController(
      currency: AppCurrency.byCode(widget.event.currencyCode),
    )..amount = widget.event.amount;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final event = widget.event;
    final categories = _store.categoriesOf(event.type);
    return AlertDialog(
      title: Text(l.confirmEventTransactionTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l.confirmEventTransactionMessage),
            const SizedBox(height: 8),
            Text(event.title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            MoneyField(
              controller: _amountController,
              title: l.actualAmount,
              decoration: InputDecoration(
                labelText: l.actualAmount,
                prefixIcon: const AppIcon(AppIcons.wallet),
              ),
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: event.type == TxType.expense
                    ? context.negativeColor
                    : context.positiveColor,
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _categoryId,
              decoration: InputDecoration(labelText: l.category),
              items: [
                for (final category in categories)
                  DropdownMenuItem(
                    value: category.id,
                    child: Text(category.localizedName(context)),
                  ),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _categoryId = value);
              },
            ),
            const SizedBox(height: 12),
            Text(l.wallet, style: TextStyle(color: context.textSecondary)),
            const SizedBox(height: 6),
            WalletPicker(
              selectedId: _walletId,
              currencyCode: event.currencyCode,
              onChanged: (value) {
                if (value != null) setState(() => _walletId = value);
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l.cancel),
        ),
        FilledButton(
          onPressed: _amountController.amount <= 0
              ? null
              : () => Navigator.of(context).pop(
                  _EventTransactionInput(
                    categoryId: _categoryId,
                    walletId: _walletId,
                    amount: _amountController.amount,
                  ),
                ),
          child: Text(l.recordEventTransaction),
        ),
      ],
    );
  }
}

class _TodayEventsCard extends StatelessWidget {
  const _TodayEventsCard({
    required this.events,
    required this.onRecord,
    required this.isRecorded,
  });

  final List<PlannedEvent> events;
  final ValueChanged<PlannedEvent> onRecord;
  final bool Function(PlannedEvent) isRecorded;

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
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          for (var index = 0; index < events.length; index++) ...[
            if (index > 0) const Divider(height: 16),
            _TodayEventReminder(
              event: events[index],
              onRecord: onRecord,
              isRecorded: isRecorded(events[index]),
            ),
          ],
        ],
      ),
    );
  }
}

class _TodayEventReminder extends StatelessWidget {
  const _TodayEventReminder({
    required this.event,
    required this.onRecord,
    required this.isRecorded,
  });

  final PlannedEvent event;
  final ValueChanged<PlannedEvent> onRecord;
  final bool isRecorded;

  @override
  Widget build(BuildContext context) {
    final hasAmount = event.amount > 0;
    final color = event.type == TxType.expense
        ? context.negativeColor
        : context.positiveColor;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 2),
          child: AppIcon(AppIcons.calendar, size: 20),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              if (event.note.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  event.note,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: context.textSecondary),
                ),
              ],
            ],
          ),
        ),
        if (hasAmount) ...[
          const SizedBox(width: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 150),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  event.type == TxType.expense
                      ? context.l10n.plannedExpense
                      : context.l10n.plannedIncome,
                  textAlign: TextAlign.end,
                  style: TextStyle(color: color, fontSize: 11),
                ),
                const SizedBox(height: 2),
                Text(
                  formatMoney(
                    event.amount,
                    AppCurrency.byCode(event.currencyCode),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: TextStyle(color: color, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                if (isRecorded)
                  Text(
                    context.l10n.eventTransactionAlreadyRecorded,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      color: context.textSecondary,
                      fontSize: 10,
                    ),
                  )
                else
                  TextButton.icon(
                    onPressed: () => onRecord(event),
                    icon: const AppIcon(AppIcons.check, size: 18),
                    label: Text(context.l10n.recordEventTransaction),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: const Size(0, 36),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.balance,
    required this.type,
    required this.onTypeChanged,
    required this.guideMode,
    required this.sampleWalletSelected,
    required this.onSampleWalletChanged,
    required this.onWalletInteraction,
    required this.onBalanceVisibilityChanged,
  });

  final double balance;
  final TxType type;
  final ValueChanged<TxType> onTypeChanged;
  final bool guideMode;
  final bool sampleWalletSelected;
  final ValueChanged<bool> onSampleWalletChanged;
  final VoidCallback onWalletInteraction;
  final VoidCallback onBalanceVisibilityChanged;

  @override
  Widget build(BuildContext context) {
    return GradientHeader(
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            SizedBox(
              height: 56,
              child: Row(
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: WalletSelector(
                        key: OverviewGuideTargets.wallet,
                        onPrimary: true,
                        demoWalletName: guideMode
                            ? context.l10n.overviewGuideSampleWallet
                            : null,
                        demoWalletSelected: sampleWalletSelected,
                        onDemoWalletChanged: onSampleWalletChanged,
                        onDemoInteraction: onWalletInteraction,
                      ),
                    ),
                  ),
                  SettingsButton(
                    key: OverviewGuideTargets.settings,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            Text(
              context.l10n.balanceUpper,
              key: OverviewGuideTargets.balanceLabel,
              style: const TextStyle(color: Colors.white70, letterSpacing: 1.5),
            ),
            const SizedBox(height: 4),
            SensitiveBalance(
              key: OverviewGuideTargets.balance,
              amount: balance,
              forceToggle: guideMode,
              onVisibilityChanged: guideMode
                  ? onBalanceVisibilityChanged
                  : null,
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
                key: OverviewGuideTargets.type,
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
    super.key,
    required this.category,
    required this.amount,
    required this.percent,
    required this.onTap,
    this.displayName,
    this.displayIcon,
    this.displayColor,
  });

  final Category? category;
  final double amount;
  final double percent;
  final VoidCallback onTap;
  final String? displayName;
  final AppIconData? displayIcon;
  final Color? displayColor;

  @override
  Widget build(BuildContext context) {
    final color = displayColor ?? category?.color ?? Colors.grey;
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
                  icon: displayIcon ?? category?.icon ?? AppIcons.help,
                  color: color,
                  size: 38,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    displayName ??
                        category?.localizedName(context) ??
                        context.l10n.other,
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
