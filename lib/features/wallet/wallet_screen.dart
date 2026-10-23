import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money_manager_app/core/widgets/app_icon.dart';
import 'package:money_manager_app/core/extensions/l10n_extensions.dart';
import 'package:money_manager_app/core/theme/app_colors.dart';
import 'package:money_manager_app/core/theme/app_theme.dart';
import 'package:money_manager_app/core/widgets/app_card.dart';
import 'package:money_manager_app/core/widgets/category_icon.dart';
import 'package:money_manager_app/core/widgets/gradient_header.dart';
import 'package:money_manager_app/core/widgets/settings_button.dart';
import 'package:money_manager_app/core/widgets/sensitive_balance.dart';
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
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: Scaffold(
            body: Column(
              children: [
                GradientHeader(
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 12, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 48,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    l.wallet,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SettingsButton(color: Colors.white),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            l.totalBalance,
                            style: const TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 4),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: SensitiveBalance(
                              amount: store.balance,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 34,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              l.walletCount(store.wallets.length),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 110),
                    children: [
                      _SectionTile(
                        icon: AppIcons.wallet,
                        color: AppTheme.primary,
                        title: l.manageWallets,
                        subtitle: l.manageWalletsDesc,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const WalletListScreen(),
                          ),
                        ),
                      ),
                      _SectionTile(
                        icon: AppIcons.budget,
                        color: AppTheme.categoryPalette[2],
                        title: l.budgetByCategory,
                        subtitle: l.budgetDesc,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const BudgetScreen(),
                          ),
                        ),
                      ),
                      _SectionTile(
                        icon: AppIcons.goal,
                        color: AppTheme.categoryPalette[4],
                        title: l.goals,
                        subtitle: l.goalsDesc,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const GoalsScreen(),
                          ),
                        ),
                      ),
                      _SectionTile(
                        icon: AppIcons.debt,
                        color: AppTheme.categoryPalette[3],
                        title: l.debts,
                        subtitle: l.debtsDesc,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const DebtsScreen(),
                          ),
                        ),
                      ),
                      _SectionTile(
                        icon: AppIcons.repeat,
                        color: AppTheme.categoryPalette[5],
                        title: l.recurring,
                        subtitle: l.recurringDesc,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const RecurringScreen(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      radius: 18,
      onTap: onTap,
      child: Row(
        children: [
          CategoryIcon(icon: icon, color: color, size: 46),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(color: context.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
          AppIcon(AppIcons.chevronRight, color: context.textTertiary),
        ],
      ),
    );
  }
}
