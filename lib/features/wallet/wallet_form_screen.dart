import 'package:flutter/material.dart';
import 'package:money_manager_app/core/widgets/app_icon.dart';
import 'package:money_manager_app/core/extensions/l10n_extensions.dart';
import 'package:money_manager_app/core/theme/app_colors.dart';
import 'package:money_manager_app/core/theme/app_theme.dart';
import 'package:money_manager_app/core/utils/app_snackbar.dart';
import 'package:money_manager_app/core/utils/currency.dart';
import 'package:money_manager_app/core/widgets/category_icon.dart';
import 'package:money_manager_app/core/widgets/money_field.dart';
import 'package:money_manager_app/data/models/wallet.dart';
import 'package:money_manager_app/data/services/app_store.dart';

class WalletFormScreen extends StatefulWidget {
  const WalletFormScreen({super.key, this.wallet});

  final Wallet? wallet;

  @override
  State<WalletFormScreen> createState() => _WalletFormScreenState();
}

class _WalletFormScreenState extends State<WalletFormScreen> {
  static const _icons = <AppIconData>[
    AppIcons.wallet,
    AppIcons.payments,
    AppIcons.bank,
    AppIcons.creditCard,
    AppIcons.savings,
    AppIcons.dollar,
    AppIcons.phone,
    AppIcons.gift,
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
  final _balanceCtrl = MoneyController();

  late AppIconData _icon = widget.wallet?.icon ?? _icons.first;
  late Color _color = widget.wallet?.color ?? _colors.first;

  late final List<AppIconData> _iconChoices = [
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
      _balanceCtrl.amount = wallet.initialBalance;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _balanceCtrl.dispose();
    super.dispose();
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context).showApp(message);
  }

  void _submit() {
    final l = context.l10n;
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      _toast(l.pleaseEnterWalletName);
      return;
    }
    final wallet = Wallet(
      id: widget.wallet?.id ?? _store.newId(),
      name: name,
      icon: _icon,
      color: _color,
      initialBalance: _balanceCtrl.amount,
    );
    if (_isEditing) {
      _store.updateWallet(wallet);
    } else {
      _store.addWallet(wallet);
    }
    Navigator.of(context).pop();
  }

  Future<void> _confirmDelete() async {
    final l = context.l10n;
    final wallet = widget.wallet!;
    if (_store.wallets.length <= 1) {
      _toast(l.keepAtLeastOneWallet);
      return;
    }
    final count = _store.transactionCountOfWallet(wallet.id);
    final linkedCount = _store.goalEntryCountOfWallet(wallet.id) +
        _store.debtEntryCountOfWallet(wallet.id);
    final message = StringBuffer(
      count == 0
          ? l.deleteWalletMessageSimple(wallet.name)
          : l.deleteWalletMessageWithTx(wallet.name, count),
    );
    if (linkedCount > 0) {
      message.write(l.deleteWalletLinkedNotice(linkedCount));
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.deleteWalletTitle),
        content: Text(message.toString()),
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
      _store.removeWallet(wallet.id);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? l.editWallet : l.addWallet)),
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
                  decoration: InputDecoration(hintText: l.walletName),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          MoneyField(
            controller: _balanceCtrl,
            title: l.initialBalance,
            decoration: InputDecoration(
              labelText: l.initialBalance,
              hintText: '0',
              suffixText: currencySymbol,
            ),
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
                child: Text(l.deleteWallet, style: const TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
