import 'package:flutter/material.dart';
import 'package:money_manager_app/core/theme/app_theme.dart';
import 'package:money_manager_app/core/widgets/category_icon.dart';
import 'package:money_manager_app/data/models/category.dart';
import 'package:money_manager_app/data/services/app_store.dart';

/// Màn hình tạo danh mục mới: tên, loại, icon, màu.
class CreateCategoryScreen extends StatefulWidget {
  const CreateCategoryScreen({super.key, this.initialType = TxType.expense});

  final TxType initialType;

  @override
  State<CreateCategoryScreen> createState() => _CreateCategoryScreenState();
}

class _CreateCategoryScreenState extends State<CreateCategoryScreen> {
  static const _icons = <IconData>[
    Icons.shopping_basket, Icons.shopping_cart, Icons.restaurant, Icons.home,
    Icons.account_balance, Icons.favorite, Icons.help_outline, Icons.directions_bus,
    Icons.family_restroom, Icons.card_giftcard, Icons.flight, Icons.pets,
    Icons.bolt, Icons.directions_car, Icons.brush, Icons.fitness_center,
    Icons.school, Icons.movie, Icons.coffee, Icons.phone_android,
  ];

  static const _colors = <Color>[
    Color(0xFFE53935), Color(0xFF6BB94A), Color(0xFF4C9BE8), Color(0xFFF5B82E),
    Color(0xFFE8506E), Color(0xFF8E9A93), Color(0xFF3CC6B0), Color(0xFF9B5DE5),
  ];

  final _store = AppStore.instance;
  final _nameCtrl = TextEditingController();
  late TxType _type = widget.initialType;
  IconData _icon = _icons.first;
  Color _color = _colors[1];

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Vui lòng nhập tên danh mục')));
      return;
    }
    _store.addCategory(
      Category(id: _store.newId(), name: name, icon: _icon, color: _color, type: _type),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tạo danh mục mới')),
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
                  decoration: const InputDecoration(hintText: 'Tên danh mục'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SegmentedButton<TxType>(
            segments: const [
              ButtonSegment(value: TxType.expense, label: Text('Chi tiêu')),
              ButtonSegment(value: TxType.income, label: Text('Thu nhập')),
            ],
            selected: {_type},
            onSelectionChanged: (s) => setState(() => _type = s.first),
          ),
          const SizedBox(height: 24),
          const Text('Biểu tượng', style: TextStyle(color: Colors.black54)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: [
              for (final ic in _icons)
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
          const Text('Màu sắc', style: TextStyle(color: Colors.black54)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 14,
            children: [
              for (final c in _colors)
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
              ),
              onPressed: _submit,
              child: const Text('Thêm', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}
