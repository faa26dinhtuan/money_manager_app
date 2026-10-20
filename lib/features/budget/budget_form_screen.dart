import 'package:flutter/material.dart';
import 'package:money_manager_app/core/theme/app_colors.dart';
import 'package:money_manager_app/core/theme/app_theme.dart';
import 'package:money_manager_app/core/utils/app_snackbar.dart';
import 'package:money_manager_app/core/widgets/category_icon.dart';
import 'package:money_manager_app/core/widgets/money_field.dart';
import 'package:money_manager_app/data/models/budget.dart';
import 'package:money_manager_app/data/models/category.dart';
import 'package:money_manager_app/data/services/app_store.dart';

class BudgetFormScreen extends StatefulWidget {
  const BudgetFormScreen({super.key, this.budget});

  final Budget? budget;

  @override
  State<BudgetFormScreen> createState() => _BudgetFormScreenState();
}

class _BudgetFormScreenState extends State<BudgetFormScreen> {
  final _store = AppStore.instance;
  final _limitCtrl = MoneyController();
  String? _categoryId;

  bool get _isEditing => widget.budget != null;

  @override
  void initState() {
    super.initState();
    final b = widget.budget;
    if (b != null) {
      _categoryId = b.categoryId;
      _limitCtrl.amount = b.limit;
    }
  }

  @override
  void dispose() {
    _limitCtrl.dispose();
    super.dispose();
  }

  List<Category> get _choices {
    if (_isEditing) {
      final c = _store.categoryById(widget.budget!.categoryId);
      return c == null ? [] : [c];
    }
    final used = _store.budgets.map((b) => b.categoryId).toSet();
    return _store
        .categoriesOf(TxType.expense)
        .where((c) => !used.contains(c.id))
        .toList();
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context).showApp(message);
  }

  void _submit() {
    final limit = _limitCtrl.amount;
    if (_categoryId == null) {
      _toast('Vui lòng chọn danh mục');
      return;
    }
    if (limit <= 0) {
      _toast('Vui lòng nhập hạn mức');
      return;
    }
    final budget = Budget(
      id: widget.budget?.id ?? _store.newId(),
      categoryId: _categoryId!,
      limit: limit,
    );
    if (_isEditing) {
      _store.updateBudget(budget);
    } else {
      _store.addBudget(budget);
    }
    Navigator.of(context).pop();
  }

  Future<void> _confirmDelete() async {
    final name = _store.categoryById(widget.budget!.categoryId)?.name ?? 'Khác';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa ngân sách?'),
        content: Text('Ngân sách của danh mục "$name" sẽ bị xóa.'),
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
      _store.removeBudget(widget.budget!.id);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final choices = _choices;
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Sửa ngân sách' : 'Thêm ngân sách'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Hạn mức mỗi tháng',
              style: TextStyle(color: context.textSecondary)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: MoneyField(
                  controller: _limitCtrl,
                  title: 'Hạn mức mỗi tháng',
                  style:
                      const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(hintText: '0'),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 8, bottom: 12),
                child: Text(
                  '₫',
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('Danh mục', style: TextStyle(color: context.textSecondary)),
          const SizedBox(height: 12),
          if (choices.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Tất cả danh mục chi tiêu đã có ngân sách',
                style: TextStyle(color: context.textSecondary),
              ),
            )
          else
            Wrap(
              spacing: 14,
              runSpacing: 14,
              children: [
                for (final c in choices)
                  GestureDetector(
                    onTap: _isEditing
                        ? null
                        : () => setState(() => _categoryId = c.id),
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
                              color: _categoryId == c.id
                                  ? c.color
                                  : context.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
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
                child: const Text('Xóa ngân sách',
                    style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
