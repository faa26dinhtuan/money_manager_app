import 'package:flutter/material.dart';
import 'package:money_manager_app/core/widgets/app_icon.dart';
import 'package:money_manager_app/core/extensions/l10n_extensions.dart';
import 'package:money_manager_app/core/theme/app_colors.dart';
import 'package:money_manager_app/core/theme/app_theme.dart';
import 'package:money_manager_app/core/utils/formatters.dart';
import 'package:money_manager_app/core/widgets/category_icon.dart';
import 'package:money_manager_app/core/widgets/settings_button.dart';
import 'package:money_manager_app/data/services/app_store.dart';
import 'package:money_manager_app/features/budget/budget_screen.dart';
import 'package:money_manager_app/features/debts/debts_screen.dart';
import 'package:money_manager_app/features/goals/goals_screen.dart';
import 'package:money_manager_app/features/recurring/recurring_screen.dart';
import 'package:money_manager_app/features/wallet/wallet_list_screen.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppStore.instance;
    final l = context.l10n;
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(l.wallet),
            actions: const [SettingsButton()],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.totalBalance,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 6),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        formatMoney(store.balance),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l.walletCount(store.wallets.length),
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SectionTile(
                icon: AppIcons.wallet,
                color: AppTheme.primary,
                title: l.manageWallets,
                subtitle: l.manageWalletsDesc,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const WalletListScreen()),
                ),
              ),
              _SectionTile(
                icon: AppIcons.budget,
                color: const Color(0xFFF5B82E),
                title: l.budgetByCategory,
                subtitle: l.budgetDesc,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const BudgetScreen()),
                ),
              ),
              _SectionTile(
                icon: AppIcons.goal,
                color: const Color(0xFF9B5DE5),
                title: l.goals,
                subtitle: l.goalsDesc,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const GoalsScreen()),
                ),
              ),
              _SectionTile(
                icon: AppIcons.debt,
                color: const Color(0xFFE8506E),
                title: l.debts,
                subtitle: l.debtsDesc,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const DebtsScreen()),
                ),
              ),
              _SectionTile(
                icon: AppIcons.repeat,
                color: const Color(0xFF3CC6B0),
                title: l.recurring,
                subtitle: l.recurringDesc,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const RecurringScreen()),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionTile extends StatelessWidget {
  const _SectionTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final AppIconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: context.surfaceColor,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: CategoryIcon(icon: icon, color: color, size: 44),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const AppIcon(AppIcons.chevronRight),
        onTap: onTap,
      ),
    );
  }
}
