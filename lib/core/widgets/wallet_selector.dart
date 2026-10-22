import 'package:flutter/material.dart';
import 'package:money_manager_app/core/widgets/app_icon.dart';
import 'package:money_manager_app/core/extensions/l10n_extensions.dart';
import 'package:money_manager_app/core/extensions/model_l10n.dart';
import 'package:money_manager_app/core/theme/app_colors.dart';
import 'package:money_manager_app/core/theme/app_theme.dart';
import 'package:money_manager_app/core/utils/formatters.dart';
import 'package:money_manager_app/core/utils/currency.dart';
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
                      AppIcon(
                        wallet?.icon ?? AppIcons.wallet,
                        size: 18,
                        color: iconColor,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          wallet?.localizedName(context) ?? context.l10n.allWallets,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      AppIcon(
                        AppIcons.chevronDown,
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
    final l = context.l10n;

    void choose(String? id) {
      store.selectWallet(id);
      Navigator.of(context).pop();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
          child: Text(
            l.selectWallet,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Flexible(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.only(bottom: 16),
            children: [
              _WalletOption(
                icon: AppIcons.wallet,
                color: AppTheme.primary,
                name: '${l.allWallets} · ${store.currency.code}',
                balance: store.balance,
                currencyCode: store.currency.code,
                selected: selectedId == null,
                onTap: () => choose(null),
              ),
              for (final w in store.wallets.where(
                (w) => w.currencyCode == store.currency.code,
              ))
                _WalletOption(
                  icon: w.icon,
                  color: w.color,
                  name: w.localizedName(context),
                  balance: store.walletBalance(w.id),
                  currencyCode: w.currencyCode,
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
    required this.currencyCode,
    required this.selected,
    required this.onTap,
  });

  final AppIconData icon;
  final Color color;
  final String name;
  final double balance;
  final String currencyCode;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CategoryIcon(icon: icon, color: color, size: 40),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(
        formatMoney(balance, AppCurrency.byCode(currencyCode)),
        style: TextStyle(color: context.textSecondary),
      ),
      trailing: selected
          ? const AppIcon(AppIcons.checkCircle, color: AppTheme.primary)
          : null,
    );
  }
}
