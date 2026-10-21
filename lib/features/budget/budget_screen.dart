import 'package:flutter/material.dart';
import 'package:money_manager_app/core/widgets/app_icon.dart';
import 'package:money_manager_app/core/extensions/l10n_extensions.dart';
import 'package:money_manager_app/core/extensions/model_l10n.dart';
import 'package:money_manager_app/core/theme/app_colors.dart';
import 'package:money_manager_app/core/theme/app_theme.dart';
import 'package:money_manager_app/core/utils/budget_status.dart';
import 'package:money_manager_app/core/utils/date_range.dart';
import 'package:money_manager_app/core/utils/formatters.dart';
import 'package:money_manager_app/core/widgets/budget_progress_bar.dart';
import 'package:money_manager_app/core/widgets/category_icon.dart';
import 'package:money_manager_app/data/models/budget.dart';
import 'package:money_manager_app/data/models/category.dart';
import 'package:money_manager_app/data/services/app_store.dart';
import 'package:money_manager_app/features/budget/budget_form_screen.dart';
import 'package:money_manager_app/features/transactions/category_transactions_screen.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetRow {
  const _BudgetRow(this.budget, this.category, this.spent);

  final Budget budget;
  final Category? category;
  final double spent;

  double get ratio => budget.limit <= 0 ? 0 : spent / budget.limit;
}

class _BudgetScreenState extends State<BudgetScreen> {
  final _store = AppStore.instance;
  DateTime _anchor = DateTime(DateTime.now().year, DateTime.now().month);

  bool get _isCurrentMonth {
    final now = DateTime.now();
    return _anchor.year == now.year && _anchor.month == now.month;
  }

  void _openForm([Budget? budget]) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => BudgetFormScreen(budget: budget)),
    );
  }

  void _openTransactions(String categoryId, DateRange range) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CategoryTransactionsScreen(
          categoryId: categoryId,
          type: TxType.expense,
          range: range,
          rangeLabel: localizedDateRangeLabel(context, Period.month, _anchor),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return ListenableBuilder(
      listenable: _store,
      builder: (context, _) {
        final range = DateRange.of(Period.month, _anchor);
        final rows = [
          for (final b in _store.budgets)
            _BudgetRow(
              b,
              _store.categoryById(b.categoryId),
              _store.spentOfCategory(b.categoryId, range),
            ),
        ]..sort((a, b) => b.ratio.compareTo(a.ratio));

        final totalLimit = rows.fold<double>(0, (s, r) => s + r.budget.limit);
        final totalSpent = rows.fold<double>(0, (s, r) => s + r.spent);
        final outside = _store.expenseTotal(range) - totalSpent;

        double? perDay;
        if (_isCurrentMonth && totalLimit > totalSpent) {
          final now = DateTime.now();
          final lastDay = DateTime(_anchor.year, _anchor.month + 1, 0).day;
          perDay = (totalLimit - totalSpent) / (lastDay - now.day + 1);
        }

        return Scaffold(
          appBar: AppBar(title: Text(l.budget)),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            children: [
              Card(
                color: context.surfaceColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const AppIcon(AppIcons.chevronLeft),
                      onPressed: () => setState(() {
                        _anchor = DateRange.shift(Period.month, _anchor, -1);
                      }),
                    ),
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: _isCurrentMonth
                            ? null
                            : () => setState(() {
                                  final now = DateTime.now();
                                  _anchor = DateTime(now.year, now.month);
                                }),
                        child: Center(
                          child: Text(
                            localizedDateRangeLabel(context, Period.month, _anchor),
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: _isCurrentMonth
                                  ? context.textPrimary
                                  : AppTheme.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const AppIcon(AppIcons.chevronRight),
                      onPressed: () => setState(() {
                        _anchor = DateRange.shift(Period.month, _anchor, 1);
                      }),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              if (rows.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 48),
                  child: Column(
                    children: [
                      AppIcon(AppIcons.budget,
                          size: 56, color: context.textDisabled),
                      const SizedBox(height: 12),
                      Text(
                        l.noBudgetsYet,
                        style: TextStyle(color: context.textSecondary),
                      ),
                    ],
                  ),
                )
              else ...[
                _Summary(
                  limit: totalLimit,
                  spent: totalSpent,
                  outside: outside,
                  perDay: perDay,
                ),
                const SizedBox(height: 16),
                for (final r in rows)
                  _BudgetTile(
                    row: r,
                    onTap: () => _openForm(r.budget),
                    onViewTransactions: () =>
                        _openTransactions(r.budget.categoryId, range),
                  ),
              ],
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            shape: const StadiumBorder(),
            icon: const AppIcon(AppIcons.add),
            label: Text(l.addBudget),
            onPressed: _openForm,
          ),
        );
      },
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({
    required this.limit,
    required this.spent,
    required this.outside,
    required this.perDay,
  });

  final double limit;
  final double spent;
  final double outside;
  final double? perDay;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final over = spent > limit;
    final remaining = limit - spent;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: over ? Colors.red.shade400 : AppTheme.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            over ? l.exceeded : l.remaining,
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              formatMoney(over ? -remaining : remaining),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 14),
          BudgetProgressBar(
            value: limit <= 0 ? 0 : spent / limit,
            color: Colors.white,
            backgroundColor: Colors.white24,
            height: 10,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  l.spentOfLimit(formatMoney(spent)),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              Expanded(
                child: Text(
                  l.limitAmount(formatMoney(limit)),
                  textAlign: TextAlign.right,
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),
          if (perDay != null) ...[
            const SizedBox(height: 10),
            Text(
              l.canSpendPerDay(formatMoney(perDay!)),
              style: const TextStyle(color: Colors.white70),
            ),
          ],
          if (outside > 0) ...[
            const SizedBox(height: 6),
            Text(
              l.outsideBudget(formatMoney(outside)),
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ],
      ),
    );
  }
}

class _BudgetTile extends StatelessWidget {
  const _BudgetTile({
    required this.row,
    required this.onTap,
    required this.onViewTransactions,
  });

  final _BudgetRow row;
  final VoidCallback onTap;
  final VoidCallback onViewTransactions;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final limit = row.budget.limit;
    final level = BudgetLevel.of(row.spent, limit);
    final color = level.color;
    final category = row.category;
    final statusText = level == BudgetLevel.over
        ? l.statusOver(formatMoney(row.spent - limit))
        : l.statusRemaining(formatMoney(limit - row.spent));

    return Card(
      color: context.surfaceColor,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 4, 14),
          child: Row(
            children: [
              CategoryIcon(
                icon: category?.icon ?? AppIcons.help,
                color: category?.color ?? Colors.grey,
                size: 40,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            category?.localizedName(context) ?? l.other,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Text(
                          formatPercent(row.ratio * 100),
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    BudgetProgressBar(value: row.ratio, color: color),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${formatMoney(row.spent)} / ${formatMoney(limit)}',
                            style: TextStyle(
                              color: context.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Text(
                          statusText,
                          style: TextStyle(
                            color: color,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const AppIcon(AppIcons.transactions),
                color: context.textTertiary,
                tooltip: l.viewTransactions,
                onPressed: onViewTransactions,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
