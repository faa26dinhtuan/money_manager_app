import 'package:flutter/material.dart';
import 'package:money_manager_app/core/widgets/app_icon.dart';
import 'package:money_manager_app/core/extensions/l10n_extensions.dart';
import 'package:money_manager_app/core/extensions/model_l10n.dart';
import 'package:money_manager_app/core/theme/app_colors.dart';
import 'package:money_manager_app/core/theme/app_theme.dart';
import 'package:money_manager_app/core/utils/formatters.dart';
import 'package:money_manager_app/core/utils/currency.dart';
import 'package:money_manager_app/core/widgets/category_icon.dart';
import 'package:money_manager_app/data/models/wallet.dart';
import 'package:money_manager_app/data/services/app_store.dart';
import 'package:money_manager_app/features/wallet/wallet_form_screen.dart';

class WalletListScreen extends StatelessWidget {
  const WalletListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppStore.instance;
    final l = context.l10n;
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: Text(l.myWallets)),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            children: [
              for (final w in store.wallets)
                _WalletTile(
                  wallet: w,
                  balance: store.walletBalance(w.id),
                  transactionCount: store.transactionCountOfWallet(w.id),
                ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            shape: const StadiumBorder(),
            icon: const AppIcon(AppIcons.add),
            label: Text(l.addWallet),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const WalletFormScreen()),
            ),
          ),
        );
      },
    );
  }
}

class _WalletTile extends StatelessWidget {
  const _WalletTile({
    required this.wallet,
    required this.balance,
    required this.transactionCount,
  });

  final Wallet wallet;
  final double balance;
  final int transactionCount;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: context.surfaceColor,
      elevation: 1.25,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => WalletFormScreen(wallet: wallet),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CategoryIcon(icon: wallet.icon, color: wallet.color, size: 44),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${wallet.localizedName(context)} · ${wallet.currencyCode}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.l10n.transactionCount(transactionCount),
                      style: TextStyle(
                        color: context.textTertiary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                formatMoney(balance, AppCurrency.byCode(wallet.currencyCode)),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: balance < 0 ? Colors.red.shade400 : AppTheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
