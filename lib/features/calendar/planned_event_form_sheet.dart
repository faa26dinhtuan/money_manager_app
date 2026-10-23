import 'package:flutter/material.dart';
import 'package:money_manager_app/core/extensions/l10n_extensions.dart';
import 'package:money_manager_app/core/extensions/model_l10n.dart';
import 'package:money_manager_app/core/theme/app_colors.dart';
import 'package:money_manager_app/core/theme/app_theme.dart';
import 'package:money_manager_app/core/utils/currency.dart';
import 'package:money_manager_app/core/utils/formatters.dart';
import 'package:money_manager_app/core/widgets/app_icon.dart';
import 'package:money_manager_app/core/widgets/money_field.dart';
import 'package:money_manager_app/core/widgets/type_tabs.dart';
import 'package:money_manager_app/core/widgets/wallet_picker.dart';
import 'package:money_manager_app/data/models/category.dart';
import 'package:money_manager_app/data/models/planned_event.dart';
import 'package:money_manager_app/data/models/recurring_transaction.dart';
import 'package:money_manager_app/data/services/app_store.dart';

class PlannedEventFormResult {
  const PlannedEventFormResult({
    required this.event,
    required this.previousRecurringId,
    this.recurring,
  });

  final PlannedEvent event;
  final String? previousRecurringId;
  final RecurringTransaction? recurring;
}

class PlannedEventFormSheet extends StatefulWidget {
  const PlannedEventFormSheet({
    super.key,
    required this.initialDate,
    required this.allowDateChange,
    this.event,
  });

  final DateTime initialDate;
  final bool allowDateChange;
  final PlannedEvent? event;

  @override
  State<PlannedEventFormSheet> createState() => _PlannedEventFormSheetState();
}

class _PlannedEventFormSheetState extends State<PlannedEventFormSheet> {
  final _store = AppStore.instance;
  final _nameController = TextEditingController();
  final _noteController = TextEditingController();
  late final MoneyController _amountController;
  late DateTime _date;
  late TxType _type;
  late Frequency _frequency;
  late bool _repeat;
  String? _categoryId;
  String? _walletId;

  @override
  void initState() {
    super.initState();
    final event = widget.event;
    final currency = AppCurrency.byCode(event?.currencyCode ?? _store.currency.code);
    final recurring = event?.recurringId == null
        ? null
        : _store.recurringById(event!.recurringId!);
    _amountController = MoneyController(currency: currency);
    _date = event?.seriesStartDate ?? event?.date ?? widget.initialDate;
    _type = event?.type ?? TxType.expense;
    _frequency = event?.frequency ?? Frequency.monthly;
    _repeat = event?.recurringId != null;
    _categoryId = recurring?.categoryId ?? _store.categoriesOf(_type).firstOrNull?.id;
    _walletId = recurring?.walletId ?? event?.walletId ??
        _store.wallets.where((wallet) => wallet.currencyCode == currency.code).firstOrNull?.id;
    _nameController.text = event?.title ?? '';
    _noteController.text = event?.note ?? '';
    if (event != null) _amountController.amount = event.amount;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _noteController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  DateTime _nextOccurrence(DateTime start, Frequency frequency) {
    final schedule = RecurringTransaction(
      id: '',
      type: _type,
      categoryId: _categoryId ?? '',
      walletId: _walletId ?? '',
      amount: 0,
      frequency: frequency,
      startDate: start,
      nextDate: start,
    );
    var next = start;
    final today = RecurringTransaction.dateOnly(DateTime.now());
    var guard = 0;
    while (next.isBefore(today) && guard < 100000) {
      next = schedule.advance(next);
      guard++;
    }
    return next;
  }

  void _save() {
    final l = context.l10n;
    final currency = AppCurrency.byCode(
      widget.event?.currencyCode ?? _store.currency.code,
    );
    final title = _nameController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.pleaseEnterEventName)),
      );
      return;
    }
    if (_amountController.amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.pleaseEnterAmount)),
      );
      return;
    }
    if (_repeat && _categoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.pleaseSelectCategory)),
      );
      return;
    }
    if (_repeat && _walletId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.pleaseSelectWallet)),
      );
      return;
    }
    final previousRecurring = widget.event?.recurringId == null
        ? null
        : _store.recurringById(widget.event!.recurringId!);
    final scheduleChanged = previousRecurring == null ||
        previousRecurring.frequency != _frequency ||
        !isSameDay(previousRecurring.startDate, _date);
    final startDate = RecurringTransaction.dateOnly(_date);
    final recurring = _repeat
        ? RecurringTransaction(
            id: previousRecurring?.id ?? _store.newId(),
            type: _type,
            categoryId: _categoryId!,
            walletId: _walletId!,
            amount: _amountController.amount,
            frequency: _frequency,
            startDate: startDate,
            nextDate: previousRecurring == null
                ? startDate
                : scheduleChanged
                ? _nextOccurrence(startDate, _frequency)
                : previousRecurring.nextDate,
            note: title,
            active: previousRecurring?.active ?? true,
            skippedDates: scheduleChanged
                ? const []
                : previousRecurring?.skippedDates ?? const [],
          )
        : null;
    final plannedEvent = PlannedEvent(
      id: widget.event?.id ?? _store.newId(),
      title: title,
      type: _type,
      amount: _amountController.amount,
      date: DateTime(_date.year, _date.month, _date.day, 12),
      currencyCode: currency.code,
      note: _noteController.text.trim(),
      walletId: _repeat ? _walletId : widget.event?.walletId ?? _store.selectedWalletId,
      recurringId: recurring?.id,
      frequency: recurring?.frequency,
    );
    Navigator.of(context).pop(
      PlannedEventFormResult(
        event: plannedEvent,
        previousRecurringId: widget.event?.recurringId,
        recurring: recurring,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final event = widget.event;
    final currency = AppCurrency.byCode(event?.currencyCode ?? _store.currency.code);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          16,
          20,
          MediaQuery.viewInsetsOf(context).bottom + 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.outlineColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                event == null ? l.addPlannedEvent : l.editPlannedEvent,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: l.plannedEventName,
                  prefixIcon: const AppIcon(AppIcons.notes),
                ),
              ),
              const SizedBox(height: 12),
              TypeTabs(
                type: _type,
                onChanged: (type) => setState(() {
                  _type = type;
                  _categoryId = _store.categoriesOf(type).firstOrNull?.id;
                }),
              ),
              const SizedBox(height: 12),
              MoneyField(
                controller: _amountController,
                title: l.amount,
                decoration: InputDecoration(
                  labelText: l.amount,
                  prefixIcon: const AppIcon(AppIcons.wallet),
                ),
              ),
              const SizedBox(height: 10),
              if (widget.allowDateChange) Material(
                color: context.surfaceColor,
                borderRadius: BorderRadius.circular(14),
                child: ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  onTap: _pickDate,
                  leading: const AppIcon(AppIcons.calendar, color: AppTheme.primary),
                  title: Text(l.date),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(formatDate(_date)),
                      const SizedBox(width: 4),
                      const AppIcon(AppIcons.chevronRight, size: 18),
                    ],
                  ),
                ),
              ),
              if (widget.allowDateChange) const SizedBox(height: 12),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _repeat,
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(l.repeatEvent),
                onChanged: (value) => setState(() => _repeat = value ?? false),
              ),
              if (_repeat) ...[
                DropdownButtonFormField<Frequency>(
                  value: _frequency,
                  decoration: InputDecoration(labelText: l.repeatFrequency),
                  items: [
                    for (final frequency in Frequency.values)
                      DropdownMenuItem(
                        value: frequency,
                        child: Text(frequency.localizedLabel(context)),
                      ),
                  ],
                  onChanged: (frequency) {
                    if (frequency != null) setState(() => _frequency = frequency);
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _categoryId,
                  decoration: InputDecoration(labelText: l.category),
                  items: [
                    for (final category in _store.categoriesOf(_type))
                      DropdownMenuItem(
                        value: category.id,
                        child: Text(category.localizedName(context)),
                      ),
                  ],
                  onChanged: (id) => setState(() => _categoryId = id),
                ),
                const SizedBox(height: 12),
                Text(l.wallet, style: TextStyle(color: context.textSecondary)),
                const SizedBox(height: 6),
                WalletPicker(
                  selectedId: _walletId,
                  currencyCode: currency.code,
                  onChanged: (id) => setState(() => _walletId = id),
                ),
              ],
              const SizedBox(height: 12),
              TextField(
                controller: _noteController,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: l.note,
                  prefixIcon: const AppIcon(AppIcons.notes),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 50,
                child: FilledButton(
                  onPressed: _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.accent,
                    foregroundColor: AppTheme.primaryDeep,
                  ),
                  child: Text(l.save),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
