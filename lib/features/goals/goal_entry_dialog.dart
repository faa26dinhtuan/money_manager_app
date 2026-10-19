import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money_manager_app/core/utils/formatters.dart';
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
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
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
    final amount = double.tryParse(_amountCtrl.text) ?? 0;
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
      id: AppStore.instance.newId(),
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
    );
    Navigator.of(context).pop(entry);
  }

  @override
  Widget build(BuildContext context) {
    final remaining = widget.goal.remaining;
    return AlertDialog(
      title: Text(widget.deposit ? 'Nạp tiền' : 'Rút tiền'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _amountCtrl,
              autofocus: true,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
                  _amountCtrl.text = remaining.round().toString();
                  _error = null;
                }),
              ),
            ],
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
                      style: const TextStyle(fontWeight: FontWeight.w600),
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
