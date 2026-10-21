import 'package:flutter/material.dart';
import 'package:money_manager_app/core/theme/app_colors.dart';
import 'package:money_manager_app/core/theme/app_theme.dart';
import 'package:money_manager_app/core/utils/app_snackbar.dart';
import 'package:money_manager_app/core/utils/formatters.dart';
import 'package:money_manager_app/core/utils/goal_status.dart';
import 'package:money_manager_app/core/widgets/category_icon.dart';
import 'package:money_manager_app/core/widgets/donut_chart.dart';
import 'package:money_manager_app/data/models/goal.dart';
import 'package:money_manager_app/data/services/app_store.dart';
import 'package:money_manager_app/features/goals/goal_entry_dialog.dart';
import 'package:money_manager_app/features/goals/goal_form_screen.dart';

class GoalDetailScreen extends StatefulWidget {
  const GoalDetailScreen({super.key, required this.goalId});

  final String goalId;

  @override
  State<GoalDetailScreen> createState() => _GoalDetailScreenState();
}

class _GoalDetailScreenState extends State<GoalDetailScreen> {
  final _store = AppStore.instance;
  Goal? _last;

  Future<void> _openEntry(Goal goal, bool deposit) async {
    final entry = await showDialog<GoalEntry>(
      context: context,
      builder: (_) => GoalEntryDialog(goal: goal, deposit: deposit),
    );
    if (entry == null || !mounted) return;
    final wasDone = goal.isCompleted;
    _store.addGoalEntry(goal.id, entry);
    final updated = _store.goalById(goal.id);
    if (!wasDone && updated != null && updated.isCompleted) {
      ScaffoldMessenger.of(context)
          .showApp('Chúc mừng! Bạn đã đạt mục tiêu "${goal.name}"');
    }
  }

  void _removeEntry(Goal goal, GoalEntry entry) {
    _store.removeGoalEntry(goal.id, entry.id);
    ScaffoldMessenger.of(context).showApp(
      'Đã xóa khoản ${entry.isDeposit ? 'nạp' : 'rút'}',
      action: SnackBarAction(
        label: 'Hoàn tác',
        onPressed: () => _store.addGoalEntry(goal.id, entry),
      ),
    );
  }

  void _edit(Goal goal) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => GoalFormScreen(goal: goal)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _store,
      builder: (context, _) {
        final goal = _store.goalById(widget.goalId) ?? _last;
        if (goal == null) return const Scaffold();
        _last = goal;

        final now = DateTime.now();
        final state = goalStateOf(goal, now);
        final percent = (goal.progress * 100).clamp(0.0, 100.0).floor();
        final shownSaved = goal.saved > goal.target ? goal.target : goal.saved;
        final slices = <DonutSlice>[
          if (shownSaved > 0) DonutSlice(shownSaved, goal.color),
          if (goal.remaining > 0) DonutSlice(goal.remaining, context.outlineColor),
        ];
        final perDay = goal.requiredPerDay(now);
        final days = goal.daysLeft(now);
        final entries = [...goal.entries]
          ..sort((a, b) => b.date.compareTo(a.date));

        return Scaffold(
          appBar: AppBar(
            title: Text(goal.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Sửa mục tiêu',
                onPressed: () => _edit(goal),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                color: context.surfaceColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                  child: Column(
                    children: [
                      DonutChart(
                        slices: slices,
                        size: 200,
                        thickness: 22,
                        center: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CategoryIcon(
                              icon: goal.icon,
                              color: goal.color,
                              size: 36,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '$percent%',
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _Stat(
                            label: 'Đã có',
                            value: goal.saved,
                            color: AppTheme.primary,
                          ),
                          _Stat(
                            label: 'Mục tiêu',
                            value: goal.target,
                            color: context.textPrimary,
                          ),
                          _Stat(
                            label: 'Còn thiếu',
                            value: goal.remaining,
                            color: goal.remaining > 0
                                ? Colors.red.shade400
                                : AppTheme.primary,
                          ),
                        ],
                      ),
                      const Divider(height: 28),
                      Row(
                        children: [
                          Icon(
                            state == GoalState.completed
                                ? Icons.check_circle
                                : Icons.event,
                            size: 20,
                            color: state.color,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              goal.deadline == null
                                  ? goalDeadlineText(goal, now)
                                  : state == GoalState.completed
                                      ? 'Đã hoàn thành · hạn ${formatDate(goal.deadline!)}'
                                      : 'Hạn ${formatDate(goal.deadline!)} · ${goalDeadlineText(goal, now)}',
                              style: TextStyle(
                                color: state.color,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (perDay != null && days != null) ...[
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            days >= 30
                                ? 'Cần tiết kiệm khoảng ${formatMoney(perDay * 30)}/tháng'
                                : 'Cần tiết kiệm khoảng ${formatMoney(perDay)}/ngày',
                            style: TextStyle(color: context.textSecondary),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppTheme.accent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        icon: const Icon(Icons.add),
                        label: const Text('Nạp tiền'),
                        onPressed: () => _openEntry(goal, true),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        icon: const Icon(Icons.remove),
                        label: const Text('Rút tiền'),
                        onPressed:
                            goal.saved > 0 ? () => _openEntry(goal, false) : null,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Card(
                color: context.surfaceColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 4, bottom: 8),
                        child: Text(
                          'Lịch sử',
                          style: TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (entries.isEmpty)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: Text(
                              'Chưa có khoản nạp nào',
                              style: TextStyle(color: context.textSecondary),
                            ),
                          ),
                        ),
                      for (final e in entries)
                        Dismissible(
                          key: ValueKey(e.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            color: Colors.red.shade400,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          onDismissed: (_) => _removeEntry(goal, e),
                          child: _EntryTile(
                            entry: e,
                            walletName: e.walletId == null
                                ? null
                                : _store.walletById(e.walletId!)?.name,
                          ),
                        ),
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

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, required this.color});

  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(color: context.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              formatMoney(value),
              style: TextStyle(fontWeight: FontWeight.bold, color: color),
            ),
          ),
        ],
      ),
    );
  }
}

class _EntryTile extends StatelessWidget {
  const _EntryTile({required this.entry, this.walletName});

  final GoalEntry entry;
  final String? walletName;

  @override
  Widget build(BuildContext context) {
    final deposit = entry.isDeposit;
    final color = deposit ? AppTheme.primary : Colors.red.shade400;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Row(
        children: [
          CategoryIcon(
            icon: deposit ? Icons.arrow_upward : Icons.arrow_downward,
            color: color,
            size: 34,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.note.isEmpty
                      ? (deposit ? 'Nạp tiền' : 'Rút tiền')
                      : entry.note,
                ),
                Text(
                  walletName == null
                      ? formatDate(entry.date)
                      : '${formatDate(entry.date)} · $walletName',
                  style: TextStyle(color: context.textTertiary, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            '${deposit ? '+' : '-'}${formatMoney(entry.amount.abs())}',
            style: TextStyle(fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }
}
