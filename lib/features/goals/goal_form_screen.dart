import 'package:flutter/material.dart';
import 'package:money_manager_app/core/theme/app_colors.dart';
import 'package:money_manager_app/core/theme/app_theme.dart';
import 'package:money_manager_app/core/utils/app_snackbar.dart';
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
  static const _icons = <IconData>[
    Icons.flag,
    Icons.flight,
    Icons.beach_access,
    Icons.home,
    Icons.directions_car,
    Icons.two_wheeler,
    Icons.laptop_mac,
    Icons.phone_android,
    Icons.camera_alt,
    Icons.school,
    Icons.savings,
    Icons.diamond,
    Icons.celebration,
    Icons.favorite,
    Icons.health_and_safety,
    Icons.card_giftcard,
  ];

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
  final _targetCtrl = MoneyController();
  final _initialCtrl = MoneyController();

  late IconData _icon = widget.goal?.icon ?? _icons.first;
  late Color _color = widget.goal?.color ?? _colors[1];
  late DateTime? _deadline = widget.goal?.deadline;

  late final List<IconData> _iconChoices = [
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
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _deadline = picked);
  }

  void _submit() {
    final name = _nameCtrl.text.trim();
    final target = _targetCtrl.amount;
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showApp('Vui lòng nhập tên mục tiêu');
      return;
    }
    if (target <= 0) {
      ScaffoldMessenger.of(context).showApp('Vui lòng nhập số tiền mục tiêu');
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
          deadline: _deadline,
          entries: initial > 0
              ? [
                  GoalEntry(
                    id: '${id}_init',
                    amount: initial,
                    date: DateTime.now(),
                    note: 'Số tiền ban đầu',
                  ),
                ]
              : const [],
        ),
      );
    }
    Navigator.of(context).pop();
  }

  Future<void> _confirmDelete() async {
    final goal = _store.goalById(widget.goal!.id) ?? widget.goal!;
    final count = goal.entries.length;
    final linked = goal.entries.where((e) => e.walletId != null).length;
    final message = StringBuffer(
      count == 0
          ? 'Mục tiêu "${goal.name}" sẽ bị xóa.'
          : 'Mục tiêu "${goal.name}" cùng $count lần nạp/rút sẽ bị xóa.',
    );
    if (linked > 0) {
      message.write(' Các khoản nạp/rút qua ví sẽ được hoàn về ví tương ứng.');
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa mục tiêu?'),
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
      _store.removeGoal(goal.id);
      Navigator.of(context)
        ..pop()
        ..pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Sửa mục tiêu' : 'Thêm mục tiêu')),
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
                  decoration: const InputDecoration(hintText: 'Tên mục tiêu'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          MoneyField(
            controller: _targetCtrl,
            title: 'Số tiền mục tiêu',
            decoration: const InputDecoration(
              labelText: 'Số tiền mục tiêu',
              hintText: '0',
              suffixText: '₫',
            ),
          ),
          if (!_isEditing) ...[
            const SizedBox(height: 16),
            MoneyField(
              controller: _initialCtrl,
              title: 'Số tiền đã có',
              decoration: const InputDecoration(
                labelText: 'Số tiền đã có (không bắt buộc)',
                hintText: '0',
                suffixText: '₫',
              ),
            ),
          ],
          const SizedBox(height: 20),
          Text('Thời hạn', style: TextStyle(color: context.textSecondary)),
          InkWell(
            onTap: _pickDeadline,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _deadline == null
                          ? 'Chưa đặt thời hạn'
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
                      icon: const Icon(Icons.close),
                      onPressed: () => setState(() => _deadline = null),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Biểu tượng', style: TextStyle(color: context.textSecondary)),
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
          Text('Màu sắc', style: TextStyle(color: context.textSecondary)),
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
                        ? const Icon(Icons.check, color: Colors.white, size: 20)
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
                child: const Text('Xóa mục tiêu',
                    style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
