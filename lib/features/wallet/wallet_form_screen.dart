import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money_manager_app/core/theme/app_theme.dart';
import 'package:money_manager_app/core/widgets/category_icon.dart';
import 'package:money_manager_app/data/models/wallet.dart';
import 'package:money_manager_app/data/services/app_store.dart';

class WalletFormScreen extends StatefulWidget {
  const WalletFormScreen({super.key, this.wallet});

  final Wallet? wallet;

  @override
  State<WalletFormScreen> createState() => _WalletFormScreenState();
}

class _WalletFormScreenState extends State<WalletFormScreen> {
  static const _icons = <IconData>[
    Icons.account_balance_wallet,
    Icons.payments,
    Icons.account_balance,
    Icons.credit_card,
    Icons.savings,
    Icons.attach_money,
    Icons.phone_android,
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
  final _balanceCtrl = TextEditingController();

  late IconData _icon = widget.wallet?.icon ?? _icons.first;
  late Color _color = widget.wallet?.color ?? _colors.first;

  late final List<IconData> _iconChoices = [
    if (!_icons.contains(_icon)) _icon,
    ..._icons,
  ];
  late final List<Color> _colorChoices = [
    if (!_colors.contains(_color)) _color,
    ..._colors,
  ];

  bool get _isEditing => widget.wallet != null;

  @override
  void initState() {
    super.initState();
    final wallet = widget.wallet;
    if (wallet != null) {
      _nameCtrl.text = wallet.name;
      _balanceCtrl.text = wallet.initialBalance.round().toString();
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _balanceCtrl.dispose();
    super.dispose();
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 3),
          persist: false,
          dismissDirection: DismissDirection.horizontal,
        ),
      );
  }

  void _submit() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      _toast('Vui lòng nhập tên ví');
      return;
    }
    final wallet = Wallet(
      id: widget.wallet?.id ?? _store.newId(),
      name: name,
      icon: _icon,
      color: _color,
      initialBalance: double.tryParse(_balanceCtrl.text) ?? 0,
    );
    if (_isEditing) {
      _store.updateWallet(wallet);
    } else {
      _store.addWallet(wallet);
    }
    Navigator.of(context).pop();
  }

  Future<void> _confirmDelete() async {
    final wallet = widget.wallet!;
    if (_store.wallets.length <= 1) {
      _toast('Cần giữ lại ít nhất một ví');
      return;
    }
    final count = _store.transactionCountOfWallet(wallet.id);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa ví?'),
        content: Text(
          count == 0
              ? 'Ví "${wallet.name}" sẽ bị xóa.'
              : 'Ví "${wallet.name}" và $count giao dịch trong ví này sẽ bị xóa.',
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
      _store.removeWallet(wallet.id);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Sửa ví' : 'Thêm ví')),
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
                  decoration: const InputDecoration(hintText: 'Tên ví'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _balanceCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'Số dư ban đầu',
              hintText: '0',
              suffixText: '₫',
            ),
          ),
          const SizedBox(height: 24),
          const Text('Biểu tượng', style: TextStyle(color: Colors.black54)),
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
          const Text('Màu sắc', style: TextStyle(color: Colors.black54)),
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
                child: const Text('Xóa ví', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
