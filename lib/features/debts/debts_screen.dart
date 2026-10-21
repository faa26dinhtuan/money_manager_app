import 'package:flutter/material.dart';
import 'package:money_manager_app/core/widgets/app_icon.dart';
import 'package:money_manager_app/core/extensions/l10n_extensions.dart';
import 'package:money_manager_app/core/extensions/model_l10n.dart';
import 'package:money_manager_app/core/theme/app_colors.dart';
import 'package:money_manager_app/core/theme/app_theme.dart';
import 'package:money_manager_app/core/widgets/gradient_card.dart';
import 'package:money_manager_app/core/utils/debt_status.dart';
import 'package:money_manager_app/core/utils/formatters.dart';
import 'package:money_manager_app/core/widgets/budget_progress_bar.dart';
import 'package:money_manager_app/core/widgets/category_icon.dart';
import 'package:money_manager_app/data/models/debt.dart';
import 'package:money_manager_app/data/services/app_store.dart';
import 'package:money_manager_app/features/debts/debt_detail_screen.dart';
import 'package:money_manager_app/features/debts/debt_form_screen.dart';

class DebtsScreen extends StatefulWidget {
  const DebtsScreen({super.key});

  @override
  State<DebtsScreen> createState() => _DebtsScreenState();
}

class _DebtsScreenState extends State<DebtsScreen> {
  final _store = AppStore.instance;
  DebtType _type = DebtType.lend;
  bool _showSettled = false;

  int _byDue(Debt a, Debt b) {
    final da = a.dueDate;
    final db = b.dueDate;
    if (da == null && db == null) return b.date.compareTo(a.date);
    if (da == null) return 1;
    if (db == null) return -1;
    return da.compareTo(db);
  }

  void _openDetail(Debt debt) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => DebtDetailScreen(debtId: debt.id)),
    );
  }

  void _openForm() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => DebtFormScreen(initialType: _type)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return ListenableBuilder(
      listenable: _store,
      builder: (context, _) {
        final now = DateTime.now();
        final all = _store.debts;
        var receivable = 0.0;
        var payable = 0.0;
        var overdue = 0;
        for (final d in all) {
          if (d.isSettled) continue;
          if (d.type == DebtType.lend) {
            receivable += d.remaining;
          } else {
            payable += d.remaining;
          }
          if (debtStateOf(d, now) == DebtState.overdue) overdue++;
        }

        final ofType = all.where((d) => d.type == _type).toList();
        final open = ofType.where((d) => !d.isSettled).toList()..sort(_byDue);
        final settled = ofType.where((d) => d.isSettled).toList()
          ..sort((a, b) => b.date.compareTo(a.date));
        final items = _showSettled ? settled : open;
        final openLend = all
            .where((d) => d.type == DebtType.lend && !d.isSettled)
            .length;
        final openBorrow = all
            .where((d) => d.type == DebtType.borrow && !d.isSettled)
            .length;

        return Scaffold(
          appBar: AppBar(title: Text(l.debts)),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            children: [
              _Summary(
                receivable: receivable,
                payable: payable,
                overdue: overdue,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<DebtType>(
                  segments: [
                    ButtonSegment(
                      value: DebtType.lend,
                      label: Text(l.lendCount(openLend)),
                    ),
                    ButtonSegment(
                      value: DebtType.borrow,
                      label: Text(l.borrowCount(openBorrow)),
                    ),
                  ],
                  selected: {_type},
                  onSelectionChanged: (s) => setState(() => _type = s.first),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: Text(l.openDebtsCount(open.length)),
                    selected: !_showSettled,
                    onSelected: (_) => setState(() => _showSettled = false),
                  ),
                  ChoiceChip(
                    label: Text(l.settledDebtsCount(settled.length)),
                    selected: _showSettled,
                    onSelected: (_) => setState(() => _showSettled = true),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (items.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    children: [
                      AppIcon(AppIcons.debt,
                          size: 56, color: context.textDisabled),
                      const SizedBox(height: 12),
                      Text(
                        _showSettled
                            ? l.noSettledDebts
                            : _type == DebtType.lend
                                ? l.noLendDebts
                                : l.noBorrowDebts,
                        style: TextStyle(color: context.textSecondary),
                      ),
                    ],
                  ),
                ),
              for (final d in items)
                _DebtTile(debt: d, onTap: () => _openDetail(d)),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            shape: const StadiumBorder(),
            icon: const AppIcon(AppIcons.add),
            label: Text(l.addDebt),
            onPressed: _openForm,
          ),
        );
      },
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({
    required this.receivable,
    required this.payable,
    required this.overdue,
  });

  final double receivable;
  final double payable;
  final int overdue;

  Widget _item(String label, double value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              formatMoney(value),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return GradientCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _item(l.receivable, receivable),
              const SizedBox(width: 16),
              _item(l.payable, payable),
            ],
          ),
          if (overdue > 0) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const AppIcon(AppIcons.warning,
                    color: Colors.white, size: 18),
                const SizedBox(width: 6),
                Text(
                  l.overdueCount(overdue),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _DebtTile extends StatelessWidget {
  const _DebtTile({required this.debt, required this.onTap});

  final Debt debt;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final state = debtStateOf(debt, now);
    final barColor = state == DebtState.ongoing ? debt.type.color : state.color;

    return Card(
      color: context.surfaceColor,
      elevation: 1.25,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CategoryIcon(
                icon: debt.type.icon,
                color: debt.type.color,
                size: 44,
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
                            debt.person,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Text(
                          formatMoney(debt.remaining),
                          style: TextStyle(
                            color: barColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    BudgetProgressBar(value: debt.progress, color: barColor),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${debt.type.localizedPaidLabel(context)} ${formatMoney(debt.paid)} / ${formatMoney(debt.amount)}',
                            style: TextStyle(
                              color: context.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Text(
                          debtDueText(debt, now, context.l10n),
                          style: TextStyle(
                            color: state.color,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
