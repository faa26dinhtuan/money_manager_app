import 'package:flutter/material.dart';
import 'package:money_manager_app/core/widgets/app_icon.dart';
import 'package:money_manager_app/core/extensions/l10n_extensions.dart';
import 'package:money_manager_app/core/extensions/model_l10n.dart';
import 'package:money_manager_app/core/theme/app_colors.dart';
import 'package:money_manager_app/core/theme/app_theme.dart';
import 'package:money_manager_app/core/utils/currency.dart';
import 'package:money_manager_app/core/widgets/category_icon.dart';
import 'package:money_manager_app/core/widgets/sensitive_balance.dart';
import 'package:money_manager_app/core/widgets/bulk_selection.dart';
import 'package:money_manager_app/data/models/wallet.dart';
import 'package:money_manager_app/data/services/app_store.dart';
import 'package:money_manager_app/features/wallet/wallet_form_screen.dart';

class WalletListScreen extends StatefulWidget {
  const WalletListScreen({super.key});

  @override
  State<WalletListScreen> createState() => _WalletListScreenState();
}

class _WalletListScreenState extends State<WalletListScreen> {
  final Set<String> _selected = {};
  bool _selecting = false;

  Future<void> _deleteSelected(BuildContext context) async {
    if (!await confirmBulkDelete(context, _selected.length) || !mounted) return;
    for (final id in _selected.toList()) {
      AppStore.instance.removeWallet(id);
    }
    setState(() { _selected.clear(); _selecting = false; });
  }

  @override
  Widget build(BuildContext context) {
    final store = AppStore.instance;
    final l = context.l10n;
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(l.myWallets),
            actions: [
              IconButton(
                tooltip: _selecting ? l.cancel : l.selectItemsToDelete,
                icon: Icon(_selecting ? Icons.close : Icons.checklist),
                onPressed: () => setState(() {
                  _selecting = !_selecting;
                  _selected.clear();
                }),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            children: [
              if (_selecting)
                BulkSelectionControls(
                  count: store.wallets.length,
                  selectedCount: _selected.length,
                  onSelectAll: () => setState(() {
                    if (_selected.length == store.wallets.length) {
                      _selected.clear();
                    } else {
                      _selected.addAll(store.wallets.map((w) => w.id));
                    }
                  }),
                  onDelete: () => _deleteSelected(context),
                ),
              for (final w in store.wallets)
                BulkSelectableItem(
                  selecting: _selecting,
                  selected: _selected.contains(w.id),
                  onChanged: (_) => setState(() {
                    _selected.contains(w.id) ? _selected.remove(w.id) : _selected.add(w.id);
                  }),
                  child: _WalletTile(
                    wallet: w,
                    balance: store.walletBalance(w.id),
                    transactionCount: store.transactionCountOfWallet(w.id),
                  ),
                ),
            ],
          ),
          floatingActionButton: _selecting ? null : FloatingActionButton.extended(
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
              SensitiveBalance(
                amount: balance,
                currency: AppCurrency.byCode(wallet.currencyCode),
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
