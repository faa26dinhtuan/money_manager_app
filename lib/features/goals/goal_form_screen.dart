import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:money_manager_app/core/widgets/ios_picker.dart';
import 'package:money_manager_app/core/widgets/app_icon.dart';
import 'package:money_manager_app/core/extensions/l10n_extensions.dart';
import 'package:money_manager_app/core/theme/app_colors.dart';
import 'package:money_manager_app/core/theme/app_theme.dart';
import 'package:money_manager_app/core/utils/app_snackbar.dart';
import 'package:money_manager_app/core/utils/currency.dart';
import 'package:money_manager_app/core/utils/formatters.dart';
import 'package:money_manager_app/core/widgets/category_icon.dart';
import 'package:money_manager_app/core/widgets/money_field.dart';
import 'package:money_manager_app/data/models/goal.dart';
import 'package:money_manager_app/data/services/app_store.dart';

class GoalFormScreen extends StatefulWidget {
  const GoalFormScreen({super.key, this.goal});

  final Goal? goal;

  @override
  State<GoalFormScreen> createState() => _GoalFormScreenState();
}

class _GoalFormScreenState extends State<GoalFormScreen> {
  static const _icons = <AppIconData>[
    AppIcons.savings,
    AppIcons.car,
    AppIcons.home,
    AppIcons.flight,
    AppIcons.laptop,
    AppIcons.phone,
    AppIcons.school,
    AppIcons.favorite,
    AppIcons.shoppingCart,
    AppIcons.gift,
  ];

  static const _colors = AppTheme.categoryPalette;

  final _store = AppStore.instance;
  final _nameCtrl = TextEditingController();
  final _targetCtrl = MoneyController();
  final _initialCtrl = MoneyController();

  late AppIconData _icon = widget.goal?.icon ?? _icons.first;
  late Color _color = widget.goal?.color ?? _colors.first;
  late DateTime? _deadline = widget.goal?.deadline;

  late final List<AppIconData> _iconChoices = [
    if (!_icons.contains(_icon)) _icon,
    ..._icons,
  ];
  late final List<Color> _colorChoices = [
    if (!_colors.contains(_color)) _color,
    ..._colors,
  ];

  bool get _isEditing => widget.goal != null;

  @override
  void initState() {
    super.initState();
    final g = widget.goal;
    final currency = AppCurrency.byCode(g?.currencyCode ?? _store.currency.code);
    _targetCtrl.useCurrency(currency);
    _initialCtrl.useCurrency(currency);
    if (g != null) {
      _nameCtrl.text = g.name;
      _targetCtrl.amount = g.target;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _targetCtrl.dispose();
    _initialCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final picked = await showAppDatePicker(
      context: context,
      initialDate: _deadline ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _deadline = picked);
  }

  void _submit() {
    final l = context.l10n;
    final name = _nameCtrl.text.trim();
    final target = _targetCtrl.amount;
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showApp(l.pleaseEnterGoalName);
      return;
    }
    if (target <= 0) {
      ScaffoldMessenger.of(context).showApp(l.pleaseEnterTarget);
      return;
    }
    if (_isEditing) {
      final current = _store.goalById(widget.goal!.id) ?? widget.goal!;
      _store.updateGoal(
        current.copyWith(
          name: name,
          icon: _icon,
          color: _color,
          target: target,
          currencyCode: current.currencyCode,
          deadline: _deadline,
          clearDeadline: _deadline == null,
        ),
      );
    } else {
      final id = _store.newId();
      final initial = _initialCtrl.amount;
      _store.addGoal(
        Goal(
          id: id,
          name: name,
          icon: _icon,
          color: _color,
          target: target,
          currencyCode: _store.currency.code,
          deadline: _deadline,
          entries: initial > 0
              ? [
                  GoalEntry(
                    id: '${id}_init',
                    amount: initial,
                    date: DateTime.now(),
                    note: l.initialDeposit,
                  ),
                ]
              : const [],
        ),
      );
    }
    Navigator.of(context).pop();
  }

  Future<void> _confirmDelete() async {
    final l = context.l10n;
    final goal = _store.goalById(widget.goal!.id) ?? widget.goal!;
    final confirmed = await showAdaptiveDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(l.deleteGoalTitle),
        content: Text(l.deleteGoalMessage(goal.name)),
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
      _store.removeGoal(goal.id);
      Navigator.of(context)
        ..pop()
        ..pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? l.editGoal : l.addGoal)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              CategoryIcon(icon: _icon, color: _color, size: 44),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _nameCtrl,
                  decoration: InputDecoration(hintText: l.goalName),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          MoneyField(
            controller: _targetCtrl,
            title: l.targetAmount,
            decoration: InputDecoration(
              labelText: l.targetAmount,
              hintText: '0',
              suffixText: AppCurrency.byCode(
                widget.goal?.currencyCode ?? _store.currency.code,
              ).symbol,
            ),
          ),
          if (!_isEditing) ...[
            const SizedBox(height: 16),
            MoneyField(
              controller: _initialCtrl,
              title: l.initialAmount,
              decoration: InputDecoration(
                labelText: l.initialAmountOptional,
                hintText: '0',
              suffixText: AppCurrency.byCode(
                widget.goal?.currencyCode ?? _store.currency.code,
              ).symbol,
              ),
            ),
          ],
          const SizedBox(height: 20),
          Text(l.deadline, style: TextStyle(color: context.textSecondary)),
          InkWell(
            onTap: _pickDeadline,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _deadline == null
                          ? l.noDeadline
                          : formatDate(_deadline!),
                      style: TextStyle(
                        color: _deadline == null
                            ? context.textTertiary
                            : AppTheme.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (_deadline != null)
                    IconButton(
                      icon: const AppIcon(AppIcons.close),
                      onPressed: () => setState(() => _deadline = null),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(l.icon, style: TextStyle(color: context.textSecondary)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              for (final ic in _iconChoices)
                GestureDetector(
                  onTap: () => setState(() => _icon = ic),
                  child: CategoryIcon(
                    icon: ic,
                    color: ic == _icon ? _color : Colors.blueGrey.shade200,
                    size: 52,
                    selected: ic == _icon,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Text(l.color, style: TextStyle(color: context.textSecondary)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 14,
            children: [
              for (final c in _colorChoices)
                GestureDetector(
                  onTap: () => setState(() => _color = c),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(color: c, shape: BoxShape.circle),
                    child: c == _color
                        ? const AppIcon(AppIcons.check, color: Colors.white, size: 20)
                        : null,
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
                child: Text(l.deleteGoal, style: const TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
