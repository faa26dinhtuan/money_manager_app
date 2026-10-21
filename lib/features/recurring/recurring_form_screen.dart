import 'package:flutter/material.dart';
import 'package:money_manager_app/core/theme/app_colors.dart';
import 'package:money_manager_app/core/theme/app_theme.dart';
import 'package:money_manager_app/core/utils/app_snackbar.dart';
import 'package:money_manager_app/core/utils/currency.dart';
import 'package:money_manager_app/core/utils/formatters.dart';
import 'package:money_manager_app/core/widgets/category_icon.dart';
import 'package:money_manager_app/core/widgets/money_field.dart';
import 'package:money_manager_app/core/widgets/type_tabs.dart';
import 'package:money_manager_app/core/widgets/wallet_picker.dart';
import 'package:money_manager_app/data/models/category.dart';
import 'package:money_manager_app/data/models/recurring_transaction.dart';
import 'package:money_manager_app/data/services/app_store.dart';

class RecurringFormScreen extends StatefulWidget {
  const RecurringFormScreen({super.key, this.recurring});

  final RecurringTransaction? recurring;

  @override
  State<RecurringFormScreen> createState() => _RecurringFormScreenState();
}

class _RecurringFormScreenState extends State<RecurringFormScreen> {
  final _store = AppStore.instance;
  final _amountCtrl = MoneyController();
  final _noteCtrl = TextEditingController();

  late TxType _type = widget.recurring?.type ?? TxType.expense;
  late Frequency _frequency = widget.recurring?.frequency ?? Frequency.monthly;
  late DateTime _start =
      widget.recurring?.startDate ?? RecurringTransaction.dateOnly(DateTime.now());
  late DateTime? _end = widget.recurring?.endDate;
  late String? _walletId = widget.recurring?.walletId ?? _store.wallets.first.id;
  late String? _categoryId = widget.recurring?.categoryId;

  bool get _isEditing => widget.recurring != null;

  @override
  void initState() {
    super.initState();
    final r = widget.recurring;
    if (r != null) {
      _amountCtrl.amount = r.amount;
      _noteCtrl.text = r.note;
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickStart() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _start,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _start = picked);
  }

  Future<void> _pickEnd() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _end ?? _start.add(const Duration(days: 365)),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _end = picked);
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context).showApp(message);
  }

  void _submit() {
    final amount = _amountCtrl.amount;
    if (amount <= 0) {
      _toast('Vui lòng nhập số tiền');
      return;
    }
    if (_categoryId == null) {
      _toast('Vui lòng chọn danh mục');
      return;
    }
    final end = _end;
    if (end != null && end.isBefore(_start)) {
      _toast('Ngày kết thúc phải sau ngày bắt đầu');
      return;
    }
    final existing = widget.recurring;
    final start = RecurringTransaction.dateOnly(_start);
    final startChanged = existing == null || !isSameDay(existing.startDate, start);
    final item = RecurringTransaction(
      id: existing?.id ?? _store.newId(),
      type: _type,
      categoryId: _categoryId!,
      walletId: _walletId!,
      amount: amount,
      frequency: _frequency,
      startDate: start,
      nextDate: startChanged ? start : existing.nextDate,
      endDate: end == null ? null : RecurringTransaction.dateOnly(end),
      note: _noteCtrl.text.trim(),
      active: existing?.active ?? true,
    );
    final messenger = ScaffoldMessenger.of(context);
    final created = _isEditing
        ? _store.updateRecurring(item)
        : _store.addRecurring(item);
    Navigator.of(context).pop();
    if (created > 0) {
      messenger.showApp('Đã tự động thêm $created giao dịch định kỳ');
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa giao dịch định kỳ?'),
        content: const Text(
          'Các giao dịch đã được tạo trước đó vẫn được giữ lại.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red.shade400),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      _store.removeRecurring(widget.recurring!.id);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = _store.categoriesOf(_type);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Sửa giao dịch định kỳ' : 'Thêm giao dịch định kỳ'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TypeTabs(
              type: _type,
              onChanged: (t) => setState(() {
                _type = t;
                _categoryId = null;
              }),
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: MoneyField(
                  controller: _amountCtrl,
                  title: 'Số tiền',
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(hintText: '0'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 12),
                child: Text(
                  AppCurrency.current.code,
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Ví', style: TextStyle(color: context.textSecondary)),
          const SizedBox(height: 8),
          WalletPicker(
            selectedId: _walletId,
            onChanged: (id) => setState(() => _walletId = id),
          ),
          const SizedBox(height: 20),
          Text('Danh mục', style: TextStyle(color: context.textSecondary)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              for (final c in categories)
                GestureDetector(
                  onTap: () => setState(() => _categoryId = c.id),
                  child: SizedBox(
                    width: 72,
                    child: Column(
                      children: [
                        CategoryIcon(
                          icon: c.icon,
                          color: _categoryId == c.id
                              ? c.color
                              : Colors.blueGrey.shade200,
                          size: 52,
                          selected: _categoryId == c.id,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          c.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: _categoryId == c.id ? c.color : context.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Text('Chu kỳ lặp', style: TextStyle(color: context.textSecondary)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final f in Frequency.values)
                ChoiceChip(
                  label: Text(f.label),
                  selected: _frequency == f,
                  onSelected: (_) => setState(() => _frequency = f),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Text('Bắt đầu từ ngày', style: TextStyle(color: context.textSecondary)),
          InkWell(
            onTap: _pickStart,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                formatDate(_start),
                style: const TextStyle(
                  color: AppTheme.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text('Kết thúc (không bắt buộc)', style: TextStyle(color: context.textSecondary)),
          Row(
            children: [
              InkWell(
                onTap: _pickEnd,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    _end == null ? 'Không giới hạn' : formatDate(_end!),
                    style: const TextStyle(
                      color: AppTheme.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              if (_end != null)
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => setState(() => _end = null),
                ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _noteCtrl,
            decoration: const InputDecoration(labelText: 'Ghi chú'),
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 52,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.accent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                ),
              ),
              onPressed: _submit,
              child: Text(_isEditing ? 'Lưu' : 'Thêm', style: const TextStyle(fontSize: 16)),
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
                child: const Text('Xóa giao dịch định kỳ', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
