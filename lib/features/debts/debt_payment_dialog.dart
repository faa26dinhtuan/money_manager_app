import 'package:flutter/material.dart';
import 'package:money_manager_app/core/widgets/app_icon.dart';
import 'package:money_manager_app/core/theme/app_colors.dart';
import 'package:money_manager_app/core/theme/app_theme.dart';
import 'package:money_manager_app/core/utils/currency.dart';
import 'package:money_manager_app/core/utils/formatters.dart';
import 'package:money_manager_app/core/widgets/money_field.dart';
import 'package:money_manager_app/core/widgets/wallet_picker.dart';
import 'package:money_manager_app/data/models/debt.dart';
import 'package:money_manager_app/data/services/app_store.dart';

class DebtPaymentDialog extends StatefulWidget {
  const DebtPaymentDialog({super.key, required this.debt});

  final Debt debt;

  @override
  State<DebtPaymentDialog> createState() => _DebtPaymentDialogState();
}

class _DebtPaymentDialogState extends State<DebtPaymentDialog> {
  final _amountCtrl = MoneyController();
  final _noteCtrl = TextEditingController();
  late String? _walletId = widget.debt.walletId;
  DateTime _date = DateTime.now();
  String? _error;

  bool get _isLend => widget.debt.type == DebtType.lend;

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
    final amount = _amountCtrl.amount;
    if (amount <= 0) {
      setState(() => _error = 'Vui lòng nhập số tiền');
      return;
    }
    if (amount > widget.debt.remaining) {
      setState(() => _error = 'Vượt quá số tiền còn lại');
      return;
    }
    final now = DateTime.now();
    Navigator.of(context).pop(
      DebtPayment(
        id: AppStore.instance.newId(),
        amount: amount,
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final debt = widget.debt;
    return AlertDialog(
      title: Text(debt.type.paymentLabel),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MoneyField(
              controller: _amountCtrl,
              title: 'Số tiền ${debt.type.paymentLabel.toLowerCase()}',
              onChanged: (_) {
                if (_error != null) setState(() => _error = null);
              },
              decoration: InputDecoration(
                labelText: 'Số tiền',
                suffixText: currencySymbol,
                errorText: _error,
              ),
            ),
            const SizedBox(height: 8),
            ActionChip(
              label: Text(
                '${_isLend ? 'Thu hết' : 'Trả hết'}: ${formatMoney(debt.remaining)}',
              ),
              onPressed: () => setState(() {
                _amountCtrl.amount = debt.remaining;
                _error = null;
              }),
            ),
            const SizedBox(height: 16),
            Text(
              _isLend ? 'Cộng vào ví' : 'Trừ từ ví',
              style: TextStyle(color: context.textSecondary),
            ),
            const SizedBox(height: 8),
            WalletPicker(
              selectedId: _walletId,
              allowNone: true,
              onChanged: (id) => setState(() => _walletId = id),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _noteCtrl,
              decoration: const InputDecoration(labelText: 'Ghi chú'),
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
          child: const Text('Hủy'),
        ),
        TextButton(onPressed: _submit, child: const Text('Lưu')),
      ],
    );
  }
}
