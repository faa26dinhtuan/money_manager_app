import 'package:flutter/material.dart';
import 'package:money_manager_app/core/theme/app_colors.dart';
import 'package:money_manager_app/core/theme/app_theme.dart';
import 'package:money_manager_app/core/utils/formatters.dart';
import 'package:money_manager_app/core/widgets/category_icon.dart';
import 'package:money_manager_app/data/services/app_store.dart';

class WalletSelector extends StatelessWidget {
  const WalletSelector({super.key, this.onPrimary = false});

  final bool onPrimary;

  void _open(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      backgroundColor: context.surfaceColor,
      builder: (_) => const _WalletSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = AppStore.instance;
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final wallet = store.selectedWallet;
        final pillColor = onPrimary
            ? Colors.white.withValues(alpha: 0.18)
            : AppTheme.primary.withValues(alpha: 0.12);
        final iconColor = onPrimary ? Colors.white : AppTheme.primary;
        final textColor = onPrimary ? Colors.white : context.textPrimary;
        return Padding(
          padding: const EdgeInsets.only(left: 12),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 140),
            child: Material(
              color: pillColor,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => _open(context),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 6, 4, 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        wallet?.icon ?? Icons.account_balance_wallet,
                        size: 18,
                        color: iconColor,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          wallet?.name ?? 'Tất cả ví',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_drop_down,
                        size: 20,
                        color: iconColor,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _WalletSheet extends StatelessWidget {
  const _WalletSheet();

  @override
  Widget build(BuildContext context) {
    final store = AppStore.instance;
    final selectedId = store.selectedWalletId;

    void choose(String? id) {
      store.selectWallet(id);
      Navigator.of(context).pop();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
          child: Text(
            'Chọn ví',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Flexible(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.only(bottom: 16),
            children: [
              _WalletOption(
                icon: Icons.account_balance_wallet,
                color: AppTheme.primary,
                name: 'Tất cả ví',
                balance: store.balance,
                selected: selectedId == null,
                onTap: () => choose(null),
              ),
              for (final w in store.wallets)
                _WalletOption(
                  icon: w.icon,
                  color: w.color,
                  name: w.name,
                  balance: store.walletBalance(w.id),
                  selected: selectedId == w.id,
                  onTap: () => choose(w.id),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WalletOption extends StatelessWidget {
  const _WalletOption({
    required this.icon,
    required this.color,
    required this.name,
    required this.balance,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String name;
  final double balance;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CategoryIcon(icon: icon, color: color, size: 40),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(
        formatMoney(balance),
        style: TextStyle(color: context.textSecondary),
      ),
      trailing: selected
          ? const Icon(Icons.check_circle, color: AppTheme.primary)
          : null,
    );
  }
}
