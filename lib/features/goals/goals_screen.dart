import 'package:flutter/material.dart';
import 'package:money_manager_app/core/theme/app_colors.dart';
import 'package:money_manager_app/core/theme/app_theme.dart';
import 'package:money_manager_app/core/utils/formatters.dart';
import 'package:money_manager_app/core/utils/goal_status.dart';
import 'package:money_manager_app/core/widgets/budget_progress_bar.dart';
import 'package:money_manager_app/core/widgets/category_icon.dart';
import 'package:money_manager_app/data/models/goal.dart';
import 'package:money_manager_app/data/services/app_store.dart';
import 'package:money_manager_app/features/goals/goal_detail_screen.dart';
import 'package:money_manager_app/features/goals/goal_form_screen.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  final _store = AppStore.instance;
  bool _showDone = false;

  int _byDeadline(Goal a, Goal b) {
    final da = a.deadline;
    final db = b.deadline;
    if (da == null && db == null) return 0;
    if (da == null) return 1;
    if (db == null) return -1;
    return da.compareTo(db);
  }

  void _openDetail(Goal goal) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => GoalDetailScreen(goalId: goal.id)),
    );
  }

  void _openForm() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const GoalFormScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _store,
      builder: (context, _) {
        final all = _store.goals;
        final active = all.where((g) => !g.isCompleted).toList()
          ..sort(_byDeadline);
        final done = all.where((g) => g.isCompleted).toList();
        final items = _showDone ? done : active;
        final totalSaved = all.fold<double>(0, (s, g) => s + g.saved);
        final totalTarget = all.fold<double>(0, (s, g) => s + g.target);

        return Scaffold(
          appBar: AppBar(title: const Text('Mục tiêu kiếm tiền')),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            children: [
              if (all.isNotEmpty) ...[
                _Summary(
                  saved: totalSaved,
                  target: totalTarget,
                  done: done.length,
                  total: all.length,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<bool>(
                    segments: [
                      ButtonSegment(
                        value: false,
                        label: Text('Đang thực hiện (${active.length})'),
                      ),
                      ButtonSegment(
                        value: true,
                        label: Text('Hoàn thành (${done.length})'),
                      ),
                    ],
                    selected: {_showDone},
                    onSelectionChanged: (s) =>
                        setState(() => _showDone = s.first),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (all.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Column(
                    children: [
                      Icon(Icons.flag_outlined, size: 56, color: context.textDisabled),
                      SizedBox(height: 12),
                      Text(
                        'Chưa có mục tiêu nào',
                        style: TextStyle(color: context.textSecondary),
                      ),
                    ],
                  ),
                )
              else if (items.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: Text(
                      _showDone
                          ? 'Chưa có mục tiêu nào hoàn thành'
                          : 'Không có mục tiêu đang thực hiện',
                      style: TextStyle(color: context.textSecondary),
                    ),
                  ),
                ),
              for (final g in items)
                _GoalTile(goal: g, onTap: () => _openDetail(g)),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            shape: const StadiumBorder(),
            icon: const Icon(Icons.add),
            label: const Text('Thêm mục tiêu'),
            onPressed: _openForm,
          ),
        );
      },
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({
    required this.saved,
    required this.target,
    required this.done,
    required this.total,
  });

  final double saved;
  final double target;
  final int done;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tổng đã tiết kiệm',
              style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              formatMoney(saved),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 14),
          BudgetProgressBar(
            value: target <= 0 ? 0 : saved / target,
            color: Colors.white,
            backgroundColor: Colors.white24,
            height: 10,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Mục tiêu ${formatMoney(target)}',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              Text(
                '$done/$total hoàn thành',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GoalTile extends StatelessWidget {
  const _GoalTile({required this.goal, required this.onTap});

  final Goal goal;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final state = goalStateOf(goal, now);
    final barColor = state == GoalState.ongoing ? goal.color : state.color;
    final percent = goal.progress.clamp(0.0, 1.0) * 100;

    return Card(
      color: context.surfaceColor,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CategoryIcon(icon: goal.icon, color: goal.color, size: 44),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            goal.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Text(
                          formatPercent(percent),
                          style: TextStyle(
                            color: barColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    BudgetProgressBar(value: goal.progress, color: barColor),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${formatMoney(goal.saved)} / ${formatMoney(goal.target)}',
                            style: TextStyle(
                              color: context.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Text(
                          goalDeadlineText(goal, now),
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
