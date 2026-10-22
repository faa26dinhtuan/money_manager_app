import 'package:flutter/material.dart';
import 'package:money_manager_app/core/widgets/app_icon.dart';
import 'package:money_manager_app/core/extensions/l10n_extensions.dart';
import 'package:money_manager_app/core/extensions/model_l10n.dart';
import 'package:money_manager_app/core/theme/app_colors.dart';
import 'package:money_manager_app/core/theme/app_theme.dart';
import 'package:money_manager_app/core/utils/currency.dart';
import 'package:money_manager_app/core/utils/formatters.dart';
import 'package:money_manager_app/core/widgets/money_field.dart';
import 'package:money_manager_app/data/models/goal.dart';
import 'package:money_manager_app/data/services/app_store.dart';

class GoalEntryDialog extends StatefulWidget {
  const GoalEntryDialog({super.key, required this.goal, required this.deposit});

  final Goal goal;
  final bool deposit;

  @override
  State<GoalEntryDialog> createState() => _GoalEntryDialogState();
}

class _GoalEntryDialogState extends State<GoalEntryDialog> {
  final _store = AppStore.instance;
  final _amountCtrl = MoneyController();
  final _noteCtrl = TextEditingController();
  late String _walletId = '';
  DateTime _date = DateTime.now();
  String? _error;

  @override
  void initState() {
    super.initState();
    _amountCtrl.useCurrency(AppCurrency.byCode(widget.goal.currencyCode));
    final wallets = _store.wallets
        .where((w) => w.currencyCode == widget.goal.currencyCode)
        .toList();
    _walletId = wallets.isEmpty ? '' : wallets.first.id;
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _submit() {
    final l = context.l10n;
    final amount = _amountCtrl.amount;
    if (amount <= 0) {
      setState(() => _error = l.pleaseEnterAmount);
      return;
    }
    if (!widget.deposit && amount > widget.goal.saved) {
      setState(() => _error = l.exceedsSavedAmount);
      return;
    }
    final now = DateTime.now();
    final entry = GoalEntry(
      id: _store.newId(),
      amount: widget.deposit ? amount : -amount,
      date: DateTime(
        _date.year,
        _date.month,
        _date.day,
        now.hour,
        now.minute,
        now.second,
      ),
      note: _noteCtrl.text.trim(),
      walletId: _walletId,
    );
    Navigator.of(context).pop(entry);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final remaining = widget.goal.remaining;
    final walletBalance = _walletId.isEmpty ? 0.0 : _store.walletBalance(_walletId);
    return AlertDialog(
      title: Text(widget.deposit ? l.deposit : l.withdraw),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MoneyField(
              controller: _amountCtrl,
              title: widget.deposit ? l.depositAmount : l.withdrawAmount,
              onChanged: (_) {
                if (_error != null) setState(() => _error = null);
              },
              decoration: InputDecoration(
                labelText: l.amount,
                suffixText: currencySymbol,
                errorText: _error,
              ),
            ),
            if (widget.deposit && remaining > 0) ...[
              const SizedBox(height: 8),
              ActionChip(
                label: Text(l.reachGoalAmount(formatMoney(remaining))),
                onPressed: () => setState(() {
                  _amountCtrl.amount = remaining;
                  _error = null;
                }),
              ),
            ],
            const SizedBox(height: 16),
            Text(
              widget.deposit ? l.debitFromWallet : l.creditToWallet,
              style: TextStyle(color: context.textSecondary),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final w in _store.wallets.where(
                  (w) => w.currencyCode == widget.goal.currencyCode,
                ))
                  ChoiceChip(
                    avatar: AppIcon(
                      w.icon,
                      size: 18,
                      color: _walletId == w.id ? Colors.white : w.color,
                    ),
                    label: Text(w.localizedName(context)),
                    selected: _walletId == w.id,
                    selectedColor: w.color,
                    showCheckmark: false,
                    labelStyle: TextStyle(
                      color: _walletId == w.id ? Colors.white : context.textPrimary,
                    ),
                    onSelected: (_) => setState(() => _walletId = w.id),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              l.walletBalanceLabel(formatMoney(
                walletBalance,
                AppCurrency.byCode(widget.goal.currencyCode),
              )),
              style: TextStyle(
                fontSize: 12,
                color: walletBalance < 0 ? Colors.red.shade400 : context.textTertiary,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _noteCtrl,
              decoration: InputDecoration(labelText: l.note),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _pickDate,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    AppIcon(AppIcons.calendar, size: 20, color: context.textSecondary),
                    const SizedBox(width: 8),
                    Text(
                      formatDate(_date),
                      style: const TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l.cancel),
        ),
        TextButton(onPressed: _submit, child: Text(l.save)),
      ],
    );
  }
}
