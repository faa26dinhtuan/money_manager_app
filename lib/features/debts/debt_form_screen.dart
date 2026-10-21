import 'package:flutter/material.dart';
import 'package:money_manager_app/core/widgets/app_icon.dart';
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
  const DebtFormScreen({
    super.key,
    this.initialType = DebtType.lend,
    this.debt,
  });

  final DebtType initialType;
  final Debt? debt;

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
  late String? _walletId =
      widget.debt != null ? widget.debt!.walletId : _store.wallets.first.id;

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
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? _date.add(const Duration(days: 30)),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context).showApp(message);
  }

  void _submit() {
    final person = _personCtrl.text.trim();
    final amount = _amountCtrl.amount;
    if (person.isEmpty) {
      _toast('Vui lòng nhập tên người vay/cho vay');
      return;
    }
    if (amount <= 0) {
      _toast('Vui lòng nhập số tiền');
      return;
    }
    final date = DateTime(_date.year, _date.month, _date.day);
    final note = _noteCtrl.text.trim();
    if (_isEditing) {
      final current = _store.debtById(widget.debt!.id) ?? widget.debt!;
      if (amount < current.paid) {
        _toast('Số tiền không được nhỏ hơn số đã thanh toán');
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
    final debt = _store.debtById(widget.debt!.id) ?? widget.debt!;
    final count = debt.payments.length;
    final linked = debt.walletId != null ||
        debt.payments.any((p) => p.walletId != null);
    final message = StringBuffer(
      count == 0
          ? 'Khoản "${debt.person}" sẽ bị xóa.'
          : 'Khoản "${debt.person}" cùng $count lần thanh toán sẽ bị xóa.',
    );
    if (linked) {
      message.write(' Các giao dịch qua ví sẽ được hoàn về ví tương ứng.');
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa khoản nợ?'),
        content: Text(message.toString()),
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
    final isLend = _type == DebtType.lend;
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Sửa khoản nợ' : 'Thêm khoản nợ'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SegmentedButton<DebtType>(
            segments: [
              for (final t in DebtType.values)
                ButtonSegment(value: t, label: Text(t.label)),
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
                    hintText: isLend ? 'Người vay' : 'Người cho vay',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          MoneyField(
            controller: _amountCtrl,
            title: 'Số tiền',
            decoration: InputDecoration(
              labelText: 'Số tiền',
              hintText: '0',
              suffixText: currencySymbol,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            isLend ? 'Lấy tiền từ ví' : 'Nhận tiền vào ví',
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
            isLend ? 'Ngày cho vay' : 'Ngày vay',
            _date,
            _pickDate,
          ),
          const SizedBox(height: 8),
          _dateRow(
            'Hạn trả',
            _dueDate,
            _pickDueDate,
            onClear: () => setState(() => _dueDate = null),
            empty: 'Chưa đặt hạn',
          ),
          const SizedBox(height: 8),
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
              child: Text(
                _isEditing ? 'Lưu' : 'Thêm',
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
                child: const Text('Xóa khoản nợ',
                    style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
