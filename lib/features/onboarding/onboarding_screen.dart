import 'package:flutter/material.dart';
import 'package:money_manager_app/core/widgets/app_icon.dart';
import 'package:money_manager_app/core/extensions/l10n_extensions.dart';
import 'package:money_manager_app/core/extensions/model_l10n.dart';
import 'package:money_manager_app/core/theme/app_colors.dart';
import 'package:money_manager_app/core/theme/app_theme.dart';
import 'package:money_manager_app/core/utils/app_snackbar.dart';
import 'package:money_manager_app/core/utils/currency.dart';
import 'package:money_manager_app/core/widgets/category_icon.dart';
import 'package:money_manager_app/core/widgets/money_field.dart';
import 'package:money_manager_app/core/widgets/welcome_backdrop.dart';
import 'package:money_manager_app/core/widgets/app_lottie.dart';
import 'package:money_manager_app/data/models/wallet.dart';
import 'package:money_manager_app/data/services/app_store.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.next});

  final Widget next;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
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

  static const _colors = AppTheme.categoryPalette;

  final _store = AppStore.instance;
  final _nameCtrl = TextEditingController();
  final _balanceCtrl = MoneyController();

  late AppCurrency _currency = _store.currency;
  AppIconData _icon = _icons.first;
  Color _color = _colors.first;

  @override
  void initState() {
    super.initState();
    _balanceCtrl.useCurrency(_currency);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _balanceCtrl.dispose();
    super.dispose();
  }

  void _applySuggestion((String, AppIconData) s) {
    setState(() {
      _nameCtrl.text = s.$1;
      _icon = s.$2;
    });
  }

  void _finish(Wallet wallet) {
    _store.setCurrency(_currency);
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
    final l = context.l10n;
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showApp(l.pleaseEnterWalletName);
      return;
    }
    _finish(
      Wallet(
        id: _store.newId(),
        name: name,
        icon: _icon,
        color: _color,
        initialBalance: _balanceCtrl.amount,
        currencyCode: _currency.code,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final suggestions = <(String, AppIconData)>[
      (l.cashWallet, AppIcons.payments),
      (l.bankWallet, AppIcons.bank),
      (l.eWallet, AppIcons.phone),
    ];

    return Scaffold(
      backgroundColor: AppTheme.primaryDeep,
      body: WelcomeBackdrop(
        child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                children: [
                  const AppLottie(asset: AppAnimations.wallet, size: 88),
                  const SizedBox(height: 20),
                  Text(
                    l.welcome,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l.welcomeSubtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: context.backgroundColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    DropdownButtonFormField<AppCurrency>(
                      initialValue: _currency,
                      decoration: InputDecoration(labelText: l.currencyDefault),
                      items: [
                        for (final currency in AppCurrency.all)
                          DropdownMenuItem(
                            value: currency,
                            child: Text(
                              '${currency.localizedName(context)} (${currency.code})',
                            ),
                          ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          _currency = value;
                          _balanceCtrl.useCurrency(value);
                        });
                      },
                    ),
                    const SizedBox(height: 24),                    Text(
                      l.quickSuggestions,
                      style: TextStyle(color: context.textSecondary),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        for (final s in suggestions)
                          ActionChip(
                            avatar: AppIcon(s.$2, size: 18),
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
                            decoration: InputDecoration(
                              hintText: l.walletName,
                            ),
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
                        suffixText: _currency.symbol,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l.icon,
                      style: TextStyle(color: context.textSecondary),
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
                    Text(
                      l.color,
                      style: TextStyle(color: context.textSecondary),
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
                                  ? const AppIcon(
                                      AppIcons.check,
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
                          foregroundColor: AppTheme.primaryDeep,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26),
                          ),
                        ),
                        onPressed: _submit,
                        child: Text(
                          l.createWalletAndStart,
                          style: const TextStyle(fontSize: 16),
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
      ),
    );
  }
}

