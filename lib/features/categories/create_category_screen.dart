import 'package:flutter/material.dart';
import 'package:money_manager_app/core/widgets/app_icon.dart';
import 'package:money_manager_app/core/extensions/l10n_extensions.dart';
import 'package:money_manager_app/core/theme/app_colors.dart';
import 'package:money_manager_app/core/theme/app_theme.dart';
import 'package:money_manager_app/core/utils/app_snackbar.dart';
import 'package:money_manager_app/core/utils/category_icons.dart';
import 'package:money_manager_app/core/widgets/category_icon.dart';
import 'package:money_manager_app/data/models/category.dart';
import 'package:money_manager_app/data/services/app_store.dart';

class CreateCategoryScreen extends StatefulWidget {
  const CreateCategoryScreen({
    super.key,
    this.initialType = TxType.expense,
    this.category,
  });

  final TxType initialType;
  final Category? category;

  @override
  State<CreateCategoryScreen> createState() => _CreateCategoryScreenState();
}

class _CreateCategoryScreenState extends State<CreateCategoryScreen> {
  static const _icons = availableCategoryIcons;
  static const _colors = <Color>[
    Color(0xFF2A8C66),
    Color(0xFF4C9BE8),
    Color(0xFFF5B82E),
    Color(0xFFE8506E),
    Color(0xFF9B5DE5),
    Color(0xFF3CC6B0),
    Color(0xFFEF6C57),
    Color(0xFF8E9A93),
  ];

  final _store = AppStore.instance;
  final _nameCtrl = TextEditingController();

  late TxType _type = widget.category?.type ?? widget.initialType;
  late AppIconData _icon = widget.category?.icon ?? _icons.first;
  late Color _color = widget.category?.color ?? _colors[1];

  late final List<AppIconData> _iconChoices = [
    if (!_icons.contains(_icon)) _icon,
    ..._icons,
  ];
  late final List<Color> _colorChoices = [
    if (!_colors.contains(_color)) _color,
    ..._colors,
  ];

  bool get _isEditing => widget.category != null;

  @override
  void initState() {
    super.initState();
    _nameCtrl.text = widget.category?.name ?? '';
  }

  Future<void> _confirmDelete() async {
    final l = context.l10n;
    final category = widget.category!;
    final count = _store.transactionCountOf(category.id);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.deleteCategoryTitle),
        content: Text(
          count == 0
              ? l.deleteCategorySimple(category.name)
              : l.deleteCategoryWithTx(category.name, count),
        ),
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
      _store.removeCategory(category.id);
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final l = context.l10n;
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showApp(l.pleaseEnterCategoryName);
      return;
    }
    final category = Category(
      id: widget.category?.id ?? _store.newId(),
      name: name,
      icon: _icon,
      color: _color,
      type: _type,
    );
    if (_isEditing) {
      _store.updateCategory(category);
    } else {
      _store.addCategory(category);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l.editCategory : l.createCategory),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const AppIcon(AppIcons.delete),
              onPressed: _confirmDelete,
            ),
        ],
      ),
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
                  decoration: InputDecoration(hintText: l.categoryName),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SegmentedButton<TxType>(
            segments: [
              ButtonSegment(value: TxType.expense, label: Text(l.expense)),
              ButtonSegment(value: TxType.income, label: Text(l.income)),
            ],
            selected: {_type},
            onSelectionChanged:
                _isEditing ? null : (s) => setState(() => _type = s.first),
          ),
          const SizedBox(height: 24),
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
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
              ),
              onPressed: _submit,
              child: Text(_isEditing ? l.save : l.add, style: const TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}
