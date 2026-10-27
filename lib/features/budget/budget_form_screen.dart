import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:money_manager_app/core/extensions/l10n_extensions.dart';
import 'package:money_manager_app/core/extensions/model_l10n.dart';
import 'package:money_manager_app/core/theme/app_colors.dart';
import 'package:money_manager_app/core/theme/app_theme.dart';
import 'package:money_manager_app/core/utils/app_snackbar.dart';
import 'package:money_manager_app/core/utils/currency.dart';
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
    final l = context.l10n;
    final limit = _limitCtrl.amount;
    if (_categoryId == null) {
      _toast(l.pleaseSelectCategory);
      return;
    }
    if (limit <= 0) {
      _toast(l.pleaseEnterLimit);
      return;
    }
    final budget = Budget(
      id: widget.budget?.id ?? _store.newId(),
      categoryId: _categoryId!,
      limit: limit,
      currencyCode: widget.budget?.currencyCode ?? _store.currency.code,
    );
    if (_isEditing) {
      _store.updateBudget(budget);
    } else {
      _store.addBudget(budget);
    }
    Navigator.of(context).pop();
  }

  Future<void> _confirmDelete() async {
    final l = context.l10n;
    final name = _store.categoryById(widget.budget!.categoryId)?.localizedName(context) ?? l.other;
    final confirmed = await showAdaptiveDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(l.deleteBudgetTitle),
        content: Text(l.deleteBudgetMessage(name)),
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
      _store.removeBudget(widget.budget!.id);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final choices = _choices;
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l.editBudget : l.addBudget),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(l.monthlyLimit,
              style: TextStyle(color: context.textSecondary)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: MoneyField(
                  controller: _limitCtrl,
                  title: l.monthlyLimit,
                  style:
                      const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(hintText: '0'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 12),
                child: Text(
                  currencySymbol,
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(l.category, style: TextStyle(color: context.textSecondary)),
          const SizedBox(height: 12),
          if (choices.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                l.allCategoriesHaveBudgets,
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
                            c.localizedName(context),
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
                child: Text(l.deleteBudget,
                    style: const TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
