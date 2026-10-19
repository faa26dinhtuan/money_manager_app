import 'package:flutter/material.dart';
import 'package:money_manager_app/core/theme/app_theme.dart';
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
  late String _walletId = _store.wallets.first.id;
  DateTime _date = DateTime.now();
  String? _error;

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
    if (!widget.deposit && amount > widget.goal.saved) {
      setState(() => _error = 'Vượt quá số tiền đã tiết kiệm');
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
    final remaining = widget.goal.remaining;
    final walletBalance = _store.walletBalance(_walletId);
    return AlertDialog(
      title: Text(widget.deposit ? 'Nạp tiền' : 'Rút tiền'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MoneyField(
              controller: _amountCtrl,
              title: widget.deposit ? 'Số tiền nạp' : 'Số tiền rút',
              onChanged: (_) {
                if (_error != null) setState(() => _error = null);
              },
              decoration: InputDecoration(
                labelText: 'Số tiền',
                suffixText: '₫',
                errorText: _error,
              ),
            ),
            if (widget.deposit && remaining > 0) ...[
              const SizedBox(height: 8),
              ActionChip(
                label: Text('Đủ mục tiêu: ${formatMoney(remaining)}'),
                onPressed: () => setState(() {
                  _amountCtrl.amount = remaining;
                  _error = null;
                }),
              ),
            ],
            const SizedBox(height: 16),
            Text(
              widget.deposit ? 'Trừ từ ví' : 'Cộng vào ví',
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final w in _store.wallets)
                  ChoiceChip(
                    avatar: Icon(
                      w.icon,
                      size: 18,
                      color: _walletId == w.id ? Colors.white : w.color,
                    ),
                    label: Text(w.name),
                    selected: _walletId == w.id,
                    selectedColor: w.color,
                    showCheckmark: false,
                    labelStyle: TextStyle(
                      color: _walletId == w.id ? Colors.white : Colors.black87,
                    ),
                    onSelected: (_) => setState(() => _walletId = w.id),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Số dư ví: ${formatMoney(walletBalance)}',
              style: TextStyle(
                fontSize: 12,
                color: walletBalance < 0 ? Colors.red.shade400 : Colors.black45,
              ),
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
                    const Icon(Icons.event, size: 20, color: Colors.black54),
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
