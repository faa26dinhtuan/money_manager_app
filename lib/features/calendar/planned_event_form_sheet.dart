import 'package:flutter/material.dart';
import 'package:money_manager_app/core/extensions/l10n_extensions.dart';
import 'package:money_manager_app/core/theme/app_colors.dart';
import 'package:money_manager_app/core/theme/app_theme.dart';
import 'package:money_manager_app/core/utils/currency.dart';
import 'package:money_manager_app/core/utils/formatters.dart';
import 'package:money_manager_app/core/widgets/app_icon.dart';
import 'package:money_manager_app/core/widgets/money_field.dart';
import 'package:money_manager_app/core/widgets/type_tabs.dart';
import 'package:money_manager_app/data/models/category.dart';
import 'package:money_manager_app/data/models/planned_event.dart';
import 'package:money_manager_app/data/services/app_store.dart';

class PlannedEventFormSheet extends StatefulWidget {
  const PlannedEventFormSheet({super.key, required this.initialDate, this.event});

  final DateTime initialDate;
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

  @override
  void initState() {
    super.initState();
    final event = widget.event;
    final currency = AppCurrency.byCode(event?.currencyCode ?? _store.currency.code);
    _amountController = MoneyController(currency: currency);
    _date = event?.date ?? widget.initialDate;
    _type = event?.type ?? TxType.expense;
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

  void _save() {
    final l = context.l10n;
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
    final previous = widget.event;
    final event = PlannedEvent(
      id: previous?.id ?? _store.newId(),
      title: title,
      type: _type,
      amount: _amountController.amount,
      date: DateTime(_date.year, _date.month, _date.day, 12),
      currencyCode: previous?.currencyCode ?? _store.currency.code,
      note: _noteController.text.trim(),
      walletId: previous?.walletId ?? _store.selectedWalletId,
    );
    Navigator.of(context).pop(event);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final event = widget.event;
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
              TypeTabs(type: _type, onChanged: (type) => setState(() => _type = type)),
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
              Material(
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
