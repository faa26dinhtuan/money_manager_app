import 'package:flutter/material.dart';
import 'package:money_manager_app/core/theme/app_theme.dart';
import 'package:money_manager_app/core/utils/app_snackbar.dart';
import 'package:money_manager_app/core/widgets/category_icon.dart';
import 'package:money_manager_app/core/widgets/money_field.dart';
import 'package:money_manager_app/data/models/wallet.dart';
import 'package:money_manager_app/data/services/app_store.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.next});

  final Widget next;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
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

  static const _suggestions = <(String, IconData)>[
    ('Tiền mặt', Icons.payments),
    ('Ngân hàng', Icons.account_balance),
    ('Ví điện tử', Icons.phone_android),
  ];

  final _store = AppStore.instance;
  final _nameCtrl = TextEditingController();
  final _balanceCtrl = MoneyController();

  IconData _icon = _icons.first;
  Color _color = _colors.first;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _balanceCtrl.dispose();
    super.dispose();
  }

  void _applySuggestion((String, IconData) s) {
    setState(() {
      _nameCtrl.text = s.$1;
      _icon = s.$2;
    });
  }

  void _finish(Wallet? wallet) {
    _store.completeOnboarding(wallet);
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, _, _) => widget.next,
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  void _submit() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showApp('Vui lòng nhập tên ví');
      return;
    }
    _finish(
      Wallet(
        id: _store.newId(),
        name: name,
        icon: _icon,
        color: _color,
        initialBalance: _balanceCtrl.amount,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => _finish(null),
                style: TextButton.styleFrom(foregroundColor: Colors.white70),
                child: const Text('Bỏ qua'),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                children: [
                  Icon(Icons.account_balance_wallet,
                      size: 56, color: Colors.white),
                  SizedBox(height: 12),
                  Text(
                    'Chào mừng bạn!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Hãy tạo ví đầu tiên để bắt đầu quản lý chi tiêu',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    const Text(
                      'Gợi ý nhanh',
                      style: TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        for (final s in _suggestions)
                          ActionChip(
                            avatar: Icon(s.$2, size: 18),
                            label: Text(s.$1),
                            onPressed: () => _applySuggestion(s),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        CategoryIcon(icon: _icon, color: _color, size: 44),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _nameCtrl,
                            decoration: const InputDecoration(
                              hintText: 'Tên ví',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    MoneyField(
                      controller: _balanceCtrl,
                      title: 'Số dư ban đầu',
                      decoration: const InputDecoration(
                        labelText: 'Số dư ban đầu',
                        hintText: '0',
                        suffixText: '₫',
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Biểu tượng',
                      style: TextStyle(color: Colors.black54),
                    ),
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
                              color: ic == _icon
                                  ? _color
                                  : Colors.blueGrey.shade200,
                              size: 52,
                              selected: ic == _icon,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Màu sắc',
                      style: TextStyle(color: Colors.black54),
                    ),
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
                              decoration: BoxDecoration(
                                color: c,
                                shape: BoxShape.circle,
                              ),
                              child: c == _color
                                  ? const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 20,
                                    )
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
                        child: const Text(
                          'Tạo ví & bắt đầu',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
