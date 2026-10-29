import 'package:flutter/material.dart';
import 'package:money_manager_app/core/widgets/app_icon.dart';
import 'package:money_manager_app/core/extensions/l10n_extensions.dart';
import 'package:money_manager_app/core/extensions/model_l10n.dart';
import 'package:money_manager_app/core/theme/app_colors.dart';
import 'package:money_manager_app/core/theme/app_theme.dart';
import 'package:money_manager_app/core/utils/date_range.dart';
import 'package:money_manager_app/core/utils/formatters.dart';
import 'package:money_manager_app/core/widgets/category_icon.dart';
import 'package:money_manager_app/data/models/category.dart';
import 'package:money_manager_app/data/models/transaction.dart';
import 'package:money_manager_app/data/services/app_store.dart';
import 'package:money_manager_app/features/transactions/add_transaction_screen.dart';

class CategoryTransactionsScreen extends StatelessWidget {
  const CategoryTransactionsScreen({
    super.key,
    required this.categoryId,
    required this.type,
    required this.range,
    required this.rangeLabel,
    this.guideMode = false,
  });

  final String categoryId;
  final TxType type;
  final DateRange range;
  final String rangeLabel;
  final bool guideMode;

  @override
  Widget build(BuildContext context) {
    final store = AppStore.instance;
    final l = context.l10n;
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final category = store.categoryById(categoryId);
        final items = store
            .query(type, range, walletId: store.selectedWalletId)
            .where((t) => t.categoryId == categoryId)
            .toList();
        final displayedItems = items;
        final total = displayedItems.fold<double>(
          0,
          (sum, t) => sum + t.amount,
        );

        final groups = <DateTime, List<Transaction>>{};
        for (final t in displayedItems) {
          final key = DateTime(t.date.year, t.date.month, t.date.day);
          groups.putIfAbsent(key, () => []).add(t);
        }

        final categoryTitle = category?.localizedName(context) ?? l.other;

        return Scaffold(
          appBar: AppBar(title: Text(categoryTitle)),
          body: ListView(
            padding: const EdgeInsets.all(16),
            physics: guideMode ? const NeverScrollableScrollPhysics() : null,
            children: [
              if (guideMode) ...[
                Text(
                  l.overviewGuideTransactionsDescription,
                  style: TextStyle(color: context.textSecondary),
                ),
                const SizedBox(height: 12),
              ],
              Card(
                color: context.surfaceColor,
                elevation: 1.25,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CategoryIcon(
                        icon: category?.icon ?? AppIcons.help,
                        color: category?.color ?? Colors.grey,
                        size: 48,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              rangeLabel,
                              style: TextStyle(color: context.textSecondary),
                            ),
                            const SizedBox(height: 4),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                formatMoney(total),
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        l.transactionCount(displayedItems.length),
                        style: TextStyle(color: context.textTertiary),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                color: context.surfaceColor,
                elevation: 1.25,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
                  child: Column(
                    children: [
                      if (groups.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: Text(
                            l.noTransactions,
                            style: TextStyle(color: context.textSecondary),
                          ),
                        ),
                      for (final entry in groups.entries) ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 12, 0, 6),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              formatDate(entry.key),
                              style: const TextStyle(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                        for (final t in entry.value)
                          InkWell(
                            onTap: guideMode
                                ? null
                                : () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          AddTransactionScreen(transaction: t),
                                    ),
                                  ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 8,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      t.note.isEmpty ? categoryTitle : t.note,
                                    ),
                                  ),
                                  Text(
                                    '${type == TxType.income ? '+' : '-'}${formatMoney(t.amount)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: type == TxType.income
                                          ? AppTheme.primary
                                          : context.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
