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
import 'package:money_manager_app/data/models/category.dart';
import 'package:money_manager_app/data/models/planned_event.dart';
import 'package:money_manager_app/data/models/recurring_transaction.dart';
import 'package:money_manager_app/data/services/app_store.dart';
import 'package:money_manager_app/data/services/event_reminder_service.dart';

class PlannedEventFormResult {
  const PlannedEventFormResult({
    required this.event,
    required this.linkToRecurring,
    required this.autoRecord,
    this.categoryId,
    this.walletId,
  });

  final PlannedEvent event;
  final bool linkToRecurring;
  final bool autoRecord;
  final String? categoryId;
  final String? walletId;
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
  late bool _linkToRecurring;
  late bool _autoRecord;
  String? _categoryId;
  String? _walletId;
  String? _amountError;
  String? _nameError;
  String? _setupError;
  String? _reminderError;
  late bool _reminderEnabled;
  late TimeOfDay _reminderTime;

  @override
  void initState() {
    super.initState();
    final event = widget.event;
    final currency = AppCurrency.byCode(event?.currencyCode ?? _store.currency.code);
    _amountController = MoneyController(currency: currency);
    _date = event?.seriesStartDate ?? event?.date ?? widget.initialDate;
    _type = event?.type ?? TxType.expense;
    _frequency = event?.frequency ?? Frequency.monthly;
    _repeat = event?.frequency != null;
    final recurring = event?.recurringId == null
        ? null
        : _store.recurringById(event!.recurringId!);
    _linkToRecurring = recurring != null;
    _autoRecord = recurring?.active ?? false;
    final categories = _store.categoriesOf(_type);
    _categoryId = recurring?.categoryId ?? (categories.isEmpty ? null : categories.first.id);
    _walletId = recurring?.walletId ?? event?.walletId ?? _store.selectedWalletId;
    final reminderMinutes = event?.reminderMinutes;
    _reminderEnabled = reminderMinutes != null;
    _reminderTime = reminderMinutes == null
        ? const TimeOfDay(hour: 9, minute: 0)
        : TimeOfDay(hour: reminderMinutes ~/ 60, minute: reminderMinutes % 60);
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

  Future<void> _pickReminderTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );
    if (picked != null) setState(() => _reminderTime = picked);
  }

  void _save() {
    final l = context.l10n;
    final currency = AppCurrency.byCode(
      widget.event?.currencyCode ?? _store.currency.code,
    );
    final title = _nameController.text.trim();
    if (title.isEmpty) {
      setState(() => _nameError = l.pleaseEnterEventName);
      return;
    }
    if (_nameError != null) setState(() => _nameError = null);
    if (_repeat && _linkToRecurring && _amountController.amount <= 0) {
      setState(() => _amountError = l.pleaseEnterAmount);
      return;
    }
    if (_repeat && _linkToRecurring && (_categoryId == null || _walletId == null)) {
      setState(() => _setupError = l.eventTransactionNeedsSetup);
      return;
    }
    if (_setupError != null) setState(() => _setupError = null);
    final oldStart = widget.event?.seriesStartDate ?? widget.event?.date;
    final scheduleChanged = oldStart == null ||
        widget.event?.frequency != (_repeat ? _frequency : null) ||
        !isSameDay(oldStart, _date);
    final plannedEvent = PlannedEvent(
      id: widget.event?.id ?? _store.newId(),
      title: title,
      type: _type,
      amount: _amountController.amount,
      date: DateTime(_date.year, _date.month, _date.day, 12),
      currencyCode: currency.code,
      note: _noteController.text.trim(),
      walletId: _repeat && _linkToRecurring
          ? _walletId
          : widget.event?.walletId ?? _store.selectedWalletId,
      recurringId: widget.event?.recurringId,
      frequency: _repeat ? _frequency : null,
      reminderMinutes: _reminderEnabled
          ? _reminderTime.hour * 60 + _reminderTime.minute
          : null,
      skippedDates: scheduleChanged ? const [] : widget.event?.skippedDates ?? const [],
    );
    Navigator.of(context).pop(
      PlannedEventFormResult(
        event: plannedEvent,
        linkToRecurring: _repeat && _linkToRecurring,
        autoRecord: _repeat && _linkToRecurring && _autoRecord,
        categoryId: _repeat && _linkToRecurring ? _categoryId : null,
        walletId: _repeat && _linkToRecurring ? _walletId : null,
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
                onChanged: (value) {
                  if (_nameError != null && value.trim().isNotEmpty) {
                    setState(() => _nameError = null);
                  }
                },
                decoration: InputDecoration(
                  labelText: l.plannedEventName,
                  errorText: _nameError,
                  prefixIcon: const AppIcon(AppIcons.notes),
                ),
              ),
              const SizedBox(height: 12),
              TypeTabs(
                type: _type,
                onChanged: (type) => setState(() {
                  _type = type;
                  final categories = _store.categoriesOf(type);
                  if (!categories.any((category) => category.id == _categoryId)) {
                    _categoryId = categories.isEmpty ? null : categories.first.id;
                  }
                }),
              ),
              const SizedBox(height: 12),
              MoneyField(
                controller: _amountController,
                title: l.amount,
                decoration: InputDecoration(
                  labelText: l.amount,
                  helperText: _repeat && _linkToRecurring
                      ? null
                      : l.eventAmountOptional,
                  errorText: _amountError,
                  prefixIcon: const AppIcon(AppIcons.wallet),
                ),
                onChanged: (amount) {
                  if (_amountError != null && amount > 0) {
                    setState(() => _amountError = null);
                  }
                },
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
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _linkToRecurring,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text(l.linkEventToRecurring),
                  onChanged: (value) => setState(() {
                    _linkToRecurring = value ?? false;
                  }),
                ),
                if (_linkToRecurring) ...[
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
                    onChanged: (value) => setState(() {
                      _categoryId = value;
                      _setupError = null;
                    }),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _walletId,
                    decoration: InputDecoration(labelText: l.wallet),
                    items: [
                      for (final wallet in _store.wallets.where(
                        (item) => item.currencyCode == currency.code,
                      ))
                        DropdownMenuItem(
                          value: wallet.id,
                          child: Text(wallet.localizedName(context)),
                        ),
                    ],
                    onChanged: (value) => setState(() {
                      _walletId = value;
                      _setupError = null;
                    }),
                  ),
                  if (_setupError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        _setupError!,
                        style: TextStyle(color: context.negativeColor),
                      ),
                    ),                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _autoRecord,
                    controlAffinity: ListTileControlAffinity.leading,
                    title: Text(l.autoRecordLinkedRecurring),
                    onChanged: (value) => setState(() {
                      _autoRecord = value ?? false;
                    }),
                  ),
                ],
              ],
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _reminderEnabled,
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(l.eventReminderToggle),
                onChanged: (value) async {
                  final enabled = value ?? false;
                  if (enabled) {
                    final granted =
                        await EventReminderService.instance.requestPermission();
                    if (!mounted) return;
                    if (!granted) {
                      setState(() => _reminderError = l.eventReminderPermissionDenied);
                      return;
                    }
                  }
                  setState(() {
                    _reminderEnabled = enabled;
                    _reminderError = null;
                  });
                },
              ),
              if (_reminderError != null)
                Padding(
                  padding: const EdgeInsets.only(left: 44, bottom: 8),
                  child: Text(
                    _reminderError!,
                    style: TextStyle(color: context.negativeColor),
                  ),
                ),              if (_reminderEnabled) ...[
                ListTile(
                  contentPadding: const EdgeInsets.only(left: 44),
                  onTap: _pickReminderTime,
                  title: Text(l.reminderTime),
                  trailing: Text(
                    MaterialLocalizations.of(context).formatTimeOfDay(
                      _reminderTime,
                    ),
                  ),
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
