import 'package:flutter/material.dart';
import 'package:money_manager_app/core/widgets/app_icon.dart';
import 'package:money_manager_app/core/extensions/l10n_extensions.dart';
import 'package:money_manager_app/core/extensions/model_l10n.dart';
import 'package:money_manager_app/core/theme/app_colors.dart';
import 'package:money_manager_app/core/theme/app_theme.dart';
import 'package:money_manager_app/core/utils/app_snackbar.dart';
import 'package:money_manager_app/core/utils/currency.dart';
import 'package:money_manager_app/core/utils/debt_status.dart';
import 'package:money_manager_app/core/utils/formatters.dart';
import 'package:money_manager_app/core/widgets/category_icon.dart';
import 'package:money_manager_app/core/widgets/money_field.dart';
import 'package:money_manager_app/core/widgets/wallet_picker.dart';
import 'package:money_manager_app/data/models/debt.dart';
import 'package:money_manager_app/data/services/app_store.dart';

class DebtFormScreen extends StatefulWidget {
  const DebtFormScreen({super.key, this.debt, this.initialType = DebtType.lend});

  final Debt? debt;
  final DebtType initialType;

  @override
  State<DebtFormScreen> createState() => _DebtFormScreenState();
}

class _DebtFormScreenState extends State<DebtFormScreen> {
  final _store = AppStore.instance;
  final _personCtrl = TextEditingController();
  final _amountCtrl = MoneyController();
  final _noteCtrl = TextEditingController();

  late DebtType _type = widget.debt?.type ?? widget.initialType;
  late DateTime _date = widget.debt?.date ?? DateTime.now();
  late DateTime? _dueDate = widget.debt?.dueDate;
  late String? _walletId = widget.debt?.walletId;

  bool get _isEditing => widget.debt != null;

  @override
  void initState() {
    super.initState();
    final d = widget.debt;
    if (d != null) {
      _personCtrl.text = d.person;
      _amountCtrl.amount = d.amount;
      _noteCtrl.text = d.note;
    }
  }

  @override
  void dispose() {
    _personCtrl.dispose();
    _amountCtrl.dispose();
    _noteCtrl.dispose();
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

  Future<void> _pickDueDate() async {
    final initial = _dueDate ?? _date.add(const Duration(days: 30));
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context).showApp(message);
  }

  void _submit() {
    final l = context.l10n;
    final person = _personCtrl.text.trim();
    final amount = _amountCtrl.amount;
    if (person.isEmpty) {
      _toast(l.pleaseEnterPerson);
      return;
    }
    if (amount <= 0) {
      _toast(l.pleaseEnterAmount);
      return;
    }
    final date = DateTime(_date.year, _date.month, _date.day);
    final note = _noteCtrl.text.trim();
    if (_isEditing) {
      final current = _store.debtById(widget.debt!.id) ?? widget.debt!;
      if (amount < current.paid) {
        _toast(l.amountCannotBeLessThanPaid);
        return;
      }
      _store.updateDebt(
        current.copyWith(
          person: person,
          amount: amount,
          date: date,
          dueDate: _dueDate,
          clearDueDate: _dueDate == null,
          note: note,
          walletId: _walletId,
          clearWallet: _walletId == null,
        ),
      );
    } else {
      _store.addDebt(
        Debt(
          id: _store.newId(),
          type: _type,
          person: person,
          amount: amount,
          date: date,
          dueDate: _dueDate,
          note: note,
          walletId: _walletId,
        ),
      );
    }
    Navigator.of(context).pop();
  }

  Future<void> _confirmDelete() async {
    final l = context.l10n;
    final debt = _store.debtById(widget.debt!.id) ?? widget.debt!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.deleteDebtTitle),
        content: Text(l.deleteDebtMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red.shade400),
            child: Text(l.delete),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      _store.removeDebt(debt.id);
      Navigator.of(context)
        ..pop()
        ..pop();
    }
  }

  Widget _dateRow(String label, DateTime? value, VoidCallback onTap,
      {VoidCallback? onClear, String empty = ''}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: context.textSecondary)),
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value == null ? empty : formatDate(value),
                    style: TextStyle(
                      color: value == null ? context.textTertiary : AppTheme.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (value != null && onClear != null)
                  IconButton(
                    icon: const AppIcon(AppIcons.close),
                    onPressed: onClear,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final isLend = _type == DebtType.lend;
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l.editDebt : l.addDebt),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SegmentedButton<DebtType>(
            segments: [
              for (final t in DebtType.values)
                ButtonSegment(value: t, label: Text(t.localizedLabel(context))),
            ],
            selected: {_type},
            onSelectionChanged:
                _isEditing ? null : (s) => setState(() => _type = s.first),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              CategoryIcon(icon: _type.icon, color: _type.color, size: 44),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _personCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    hintText: isLend ? l.borrower : l.lender,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          MoneyField(
            controller: _amountCtrl,
            title: l.amount,
            decoration: InputDecoration(
              labelText: l.amount,
              hintText: '0',
              suffixText: currencySymbol,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            isLend ? l.walletSourceLend : l.walletSourceBorrow,
            style: TextStyle(color: context.textSecondary),
          ),
          const SizedBox(height: 8),
          WalletPicker(
            selectedId: _walletId,
            allowNone: true,
            onChanged: (id) => setState(() => _walletId = id),
          ),
          const SizedBox(height: 20),
          _dateRow(
            isLend ? l.debtDateLend : l.debtDateBorrow,
            _date,
            _pickDate,
          ),
          const SizedBox(height: 8),
          _dateRow(
            l.dueDate,
            _dueDate,
            _pickDueDate,
            onClear: () => setState(() => _dueDate = null),
            empty: l.noDueDate,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _noteCtrl,
            decoration: InputDecoration(labelText: l.note),
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 52,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.accent,
                foregroundColor: AppTheme.primaryDeep,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                ),
              ),
              onPressed: _submit,
              child: Text(
                _isEditing ? l.save : l.add,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          if (_isEditing) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 52,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red.shade500,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                ),
                onPressed: _confirmDelete,
                child: Text(l.deleteDebt, style: const TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
