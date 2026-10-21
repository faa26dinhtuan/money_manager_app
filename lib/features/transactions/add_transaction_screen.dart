import 'package:flutter/material.dart';
import 'package:money_manager_app/core/theme/app_colors.dart';
import 'package:money_manager_app/core/theme/app_theme.dart';
import 'package:money_manager_app/core/utils/app_snackbar.dart';
import 'package:money_manager_app/core/utils/budget_status.dart';
import 'package:money_manager_app/core/utils/currency.dart';
import 'package:money_manager_app/core/utils/date_range.dart';
import 'package:money_manager_app/core/utils/formatters.dart';
import 'package:money_manager_app/core/widgets/category_icon.dart';
import 'package:money_manager_app/core/widgets/money_field.dart';
import 'package:money_manager_app/core/widgets/type_tabs.dart';
import 'package:money_manager_app/data/models/category.dart';
import 'package:money_manager_app/data/models/transaction.dart';
import 'package:money_manager_app/data/services/app_store.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({
    super.key,
    this.initialType = TxType.expense,
    this.transaction,
  });

  final TxType initialType;
  final Transaction? transaction;

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _store = AppStore.instance;
  final _amountCtrl = MoneyController();
  final _noteCtrl = TextEditingController();

  late TxType _type = widget.transaction?.type ?? widget.initialType;
  String? _categoryId;
  String? _walletId;
  DateTime _date = DateTime.now();

  bool get _isEditing => widget.transaction != null;

  @override
  void initState() {
    super.initState();
    final t = widget.transaction;
    _walletId =
        t?.walletId ?? _store.selectedWalletId ?? _store.wallets.first.id;
    if (t != null) {
      _amountCtrl.amount = t.amount;
      _noteCtrl.text = t.note;
      _categoryId = t.categoryId;
      _date = t.date;
    }
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
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
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
    final transaction = Transaction(
      id: widget.transaction?.id ?? _store.newId(),
      type: _type,
      categoryId: _categoryId!,
      walletId: _walletId!,
      amount: amount,
      date: _date,
      note: _noteCtrl.text.trim(),
    );
    final messenger = ScaffoldMessenger.of(context);
    if (_isEditing) {
      _store.updateTransaction(transaction);
    } else {
      _store.addTransaction(transaction);
    }
    final warning = _budgetWarning(transaction);
    Navigator.of(context).pop();
    if (warning != null) messenger.showApp(warning);
  }

  String? _budgetWarning(Transaction t) {
    if (t.type != TxType.expense) return null;
    final budget = _store.budgetOfCategory(t.categoryId);
    if (budget == null) return null;
    final spent = _store.spentOfCategory(
      t.categoryId,
      DateRange.of(Period.month, t.date),
    );
    final name = _store.categoryById(t.categoryId)?.name ?? 'Khác';
    final level = BudgetLevel.of(spent, budget.limit);
    if (level == BudgetLevel.over) {
      return 'Đã vượt ngân sách "$name" ${formatMoney(spent - budget.limit)}';
    }
    if (level == BudgetLevel.warning) {
      final percent = formatPercent(spent / budget.limit * 100);
      final remaining = formatMoney(budget.limit - spent);
      return 'Ngân sách "$name" đã dùng $percent, còn lại $remaining';
    }
    return null;
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa giao dịch?'),
        content: const Text('Giao dịch này sẽ bị xóa và không thể khôi phục.'),
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
      _store.removeTransaction(widget.transaction!.id);
      Navigator.of(context).pop();
    }
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showApp(msg);
  }

  @override
  Widget build(BuildContext context) {
    final categories = _store.categoriesOf(_type);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Sửa giao dịch' : 'Thêm giao dịch'),
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
                    color: _walletId == w.id ? Colors.white : context.textPrimary,
                  ),
                  onSelected: (_) => setState(() => _walletId = w.id),
                ),
            ],
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
                          color: _categoryId == c.id ? c.color : Colors.blueGrey.shade200,
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
          Text('Ngày', style: TextStyle(color: context.textSecondary)),
          InkWell(
            onTap: _pickDate,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                formatDate(_date),
                style: const TextStyle(
                  color: AppTheme.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
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
                child: const Text(
                  'Xóa giao dịch',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
