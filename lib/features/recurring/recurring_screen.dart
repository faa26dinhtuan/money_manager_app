import 'package:flutter/material.dart';
import 'package:money_manager_app/core/theme/app_theme.dart';
import 'package:money_manager_app/core/utils/app_snackbar.dart';
import 'package:money_manager_app/core/utils/formatters.dart';
import 'package:money_manager_app/core/widgets/category_icon.dart';
import 'package:money_manager_app/data/models/category.dart';
import 'package:money_manager_app/data/models/recurring_transaction.dart';
import 'package:money_manager_app/data/services/app_store.dart';
import 'package:money_manager_app/features/recurring/recurring_form_screen.dart';

class RecurringScreen extends StatefulWidget {
  const RecurringScreen({super.key});

  @override
  State<RecurringScreen> createState() => _RecurringScreenState();
}

class _RecurringScreenState extends State<RecurringScreen> {
  final _store = AppStore.instance;

  int _rank(RecurringTransaction r) {
    if (r.isFinished) return 2;
    return r.active ? 0 : 1;
  }

  int _compare(RecurringTransaction a, RecurringTransaction b) {
    final byRank = _rank(a).compareTo(_rank(b));
    if (byRank != 0) return byRank;
    return a.nextDate.compareTo(b.nextDate);
  }

  void _openForm([RecurringTransaction? r]) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => RecurringFormScreen(recurring: r)),
    );
  }

  void _toggle(RecurringTransaction r) {
    final created = _store.toggleRecurring(r.id);
    if (created > 0) {
      ScaffoldMessenger.of(
        context,
      ).showApp('Đã tự động thêm $created giao dịch định kỳ');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _store,
      builder: (context, _) {
        final items = [..._store.recurrings]..sort(_compare);
        var expense = 0.0;
        var income = 0.0;
        for (final r in items) {
          if (!r.active || r.isFinished) continue;
          if (r.type == TxType.expense) {
            expense += r.monthlyAmount;
          } else {
            income += r.monthlyAmount;
          }
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Giao dịch định kỳ')),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            children: [
              _Summary(expense: expense, income: income),
              const SizedBox(height: 16),
              if (items.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    children: [
                      Icon(Icons.autorenew, size: 56, color: Colors.black26),
                      SizedBox(height: 12),
                      Text(
                        'Chưa có giao dịch định kỳ nào',
                        style: TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              for (final r in items)
                _RecurringTile(
                  item: r,
                  onTap: () => _openForm(r),
                  onToggle: () => _toggle(r),
                ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            shape: const StadiumBorder(),
            icon: const Icon(Icons.add),
            label: const Text('Thêm định kỳ'),
            onPressed: () => _openForm(),
          ),
        );
      },
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.expense, required this.income});

  final double expense;
  final double income;

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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          _item('Chi định kỳ / tháng', expense),
          const SizedBox(width: 16),
          _item('Thu định kỳ / tháng', income),
        ],
      ),
    );
  }
}

class _RecurringTile extends StatelessWidget {
  const _RecurringTile({
    required this.item,
    required this.onTap,
    required this.onToggle,
  });

  final RecurringTransaction item;
  final VoidCallback onTap;
  final VoidCallback onToggle;

  String _status() {
    if (item.isFinished) return 'Đã kết thúc';
    if (!item.active) return 'Tạm dừng';
    return 'Lần tới: ${formatDate(item.nextDate)}';
  }

  @override
  Widget build(BuildContext context) {
    final store = AppStore.instance;
    final category = store.categoryById(item.categoryId);
    final wallet = store.walletById(item.walletId);
    final isExpense = item.type == TxType.expense;
    final dimmed = !item.active || item.isFinished;
    final title = item.note.isEmpty ? (category?.name ?? 'Khác') : item.note;

    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Opacity(
          opacity: dimmed ? 0.55 : 1,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
            child: Row(
              children: [
                CategoryIcon(
                  icon: category?.icon ?? Icons.help_outline,
                  color: category?.color ?? Colors.grey,
                  size: 44,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${item.frequency.label} • ${wallet?.name ?? 'Ví'}',
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        _status(),
                        style: const TextStyle(
                          color: Colors.black45,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${isExpense ? '-' : '+'}${formatMoney(item.amount)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isExpense
                            ? Colors.red.shade400
                            : AppTheme.primary,
                      ),
                    ),
                    Switch(
                      value: item.active && !item.isFinished,
                      onChanged: item.isFinished ? null : (_) => onToggle(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
