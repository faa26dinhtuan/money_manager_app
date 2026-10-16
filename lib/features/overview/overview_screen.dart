import 'package:flutter/material.dart';
import 'package:money_manager_app/core/theme/app_theme.dart';
import 'package:money_manager_app/core/utils/date_range.dart';
import 'package:money_manager_app/core/utils/formatters.dart';
import 'package:money_manager_app/core/widgets/category_icon.dart';
import 'package:money_manager_app/core/widgets/donut_chart.dart';
import 'package:money_manager_app/core/widgets/period_bar.dart';
import 'package:money_manager_app/core/widgets/type_tabs.dart';
import 'package:money_manager_app/data/models/category.dart';
import 'package:money_manager_app/data/services/app_store.dart';
import 'package:money_manager_app/features/transactions/add_transaction_screen.dart';
import 'package:money_manager_app/features/transactions/category_transactions_screen.dart';

class OverviewScreen extends StatefulWidget {
  const OverviewScreen({super.key});

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  final _store = AppStore.instance;
  TxType _type = TxType.expense;
  Period _period = Period.month;
  DateTime _anchor = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _store,
      builder: (context, _) {
        final items = _store.query(_type, DateRange.of(_period, _anchor));

        final totals = <String, double>{};
        for (final t in items) {
          totals[t.categoryId] = (totals[t.categoryId] ?? 0) + t.amount;
        }
        final entries = totals.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        final total = totals.values.fold<double>(0, (s, v) => s + v);

        final slices = <DonutSlice>[
          for (final e in entries)
            DonutSlice(
              e.value,
              _store.categoryById(e.key)?.color ?? Colors.grey,
            ),
        ];

        return Scaffold(
          body: Column(
            children: [
              _Header(
                balance: _store.balance,
                type: _type,
                onTypeChanged: (t) => setState(() => _type = t),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                  children: [
                    Card(
                      color: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8, 12, 8, 20),
                        child: Column(
                          children: [
                            PeriodBar(
                              period: _period,
                              anchor: _anchor,
                              onPeriodChanged: (p) => setState(() {
                                _period = p;
                                _anchor = DateTime.now();
                              }),
                              onShift: (d) => setState(() {
                                _anchor = DateRange.shift(_period, _anchor, d);
                              }),
                            ),
                            const SizedBox(height: 12),
                            DonutChart(
                              slices: slices,
                              center: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _type == TxType.expense
                                        ? 'Đã chi'
                                        : 'Đã thu',
                                    style: const TextStyle(
                                      color: Colors.black45,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    formatMoney(total),
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (entries.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Text(
                            'Chưa có giao dịch trong khoảng này',
                            style: TextStyle(color: Colors.black54),
                          ),
                        ),
                      ),
                    for (final e in entries)
                      _CategoryRow(
                        category: _store.categoryById(e.key),
                        amount: e.value,
                        percent: total == 0 ? 0 : e.value / total * 100,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => CategoryTransactionsScreen(
                              categoryId: e.key,
                              type: _type,
                              range: DateRange.of(_period, _anchor),
                              rangeLabel: DateRange.label(_period, _anchor),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => AddTransactionScreen(initialType: _type),
              ),
            ),
            child: const Icon(Icons.add, size: 30),
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.balance,
    required this.type,
    required this.onTypeChanged,
  });

  final double balance;
  final TxType type;
  final ValueChanged<TxType> onTypeChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const SizedBox(height: 12),
            const Text(
              'SỐ DƯ',
              style: TextStyle(color: Colors.white70, letterSpacing: 1.5),
            ),
            const SizedBox(height: 4),
            Text(
              formatMoney(balance),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TypeTabs(type: type, onChanged: onTypeChanged),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.category,
    required this.amount,
    required this.percent,
    required this.onTap,
  });

  final Category? category;
  final double amount;
  final double percent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            CategoryIcon(
              icon: category?.icon ?? Icons.help_outline,
              color: category?.color ?? Colors.grey,
              size: 36,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                category?.name ?? 'Khác',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            Text(
              formatPercent(percent),
              style: const TextStyle(color: Colors.black45),
            ),
            const SizedBox(width: 16),
            Text(
              formatMoney(amount),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
