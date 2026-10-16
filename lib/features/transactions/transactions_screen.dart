import 'package:flutter/material.dart';
import 'package:money_manager_app/core/theme/app_theme.dart';
import 'package:money_manager_app/core/utils/date_range.dart';
import 'package:money_manager_app/core/utils/formatters.dart';
import 'package:money_manager_app/core/widgets/category_icon.dart';
import 'package:money_manager_app/core/widgets/period_bar.dart';
import 'package:money_manager_app/core/widgets/type_tabs.dart';
import 'package:money_manager_app/data/models/category.dart';
import 'package:money_manager_app/data/models/transaction.dart';
import 'package:money_manager_app/data/services/app_store.dart';
import 'package:money_manager_app/features/transactions/add_transaction_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final _store = AppStore.instance;
  TxType _type = TxType.expense;
  Period _period = Period.week;
  DateTime _anchor = DateTime.now();

  void _delete(Transaction t) {
    _store.removeTransaction(t.id);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text('Đã xóa giao dịch'),
          duration: const Duration(seconds: 3),
          persist: false,
          dismissDirection: DismissDirection.horizontal,
          action: SnackBarAction(
            label: 'Hoàn tác',
            onPressed: () => _store.addTransaction(t),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _store,
      builder: (context, _) {
        final items = _store.query(_type, DateRange.of(_period, _anchor));
        final total = items.fold<double>(0, (s, t) => s + t.amount);

        final groups = <DateTime, List<Transaction>>{};
        for (final t in items) {
          final key = DateTime(t.date.year, t.date.month, t.date.day);
          groups.putIfAbsent(key, () => []).add(t);
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Giao dịch'),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TypeTabs(
                  type: _type,
                  onChanged: (t) => setState(() => _type = t),
                ),
              ),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                color: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 12, 16, 16),
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
                      const Divider(),
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Tổng cộng',
                                style: TextStyle(color: Colors.black54)),
                            Text(
                              formatMoney(total),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (groups.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: Text(
                            'Chưa có giao dịch',
                            style: TextStyle(color: Colors.black54),
                          ),
                        ),
                      for (final entry in groups.entries) ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 16, 0, 6),
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
                          Dismissible(
                            key: ValueKey(t.id),
                            direction: DismissDirection.horizontal,
                            background: Container(
                              color: Colors.red.shade400,
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.only(left: 20),
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            secondaryBackground: Container(
                              color: Colors.red.shade400,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            onDismissed: (_) => _delete(t),
                            child: InkWell(
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => AddTransactionScreen(transaction: t),
                                ),
                              ),
                              child: _TransactionTile(
                                transaction: t,
                                category: _store.categoryById(t.categoryId),
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

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.transaction, required this.category});

  final Transaction transaction;
  final Category? category;

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TxType.income;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: Row(
        children: [
          CategoryIcon(
            icon: category?.icon ?? Icons.help_outline,
            color: category?.color ?? Colors.grey,
            size: 34,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(category?.name ?? 'Khác'),
                if (transaction.note.isNotEmpty)
                  Text(
                    transaction.note,
                    style: const TextStyle(color: Colors.black45, fontSize: 12),
                  ),
              ],
            ),
          ),
          Text(
            '${isIncome ? '+' : '-'}${formatMoney(transaction.amount)}',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isIncome ? AppTheme.primary : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
