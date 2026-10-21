import 'package:flutter/material.dart';
import 'package:money_manager_app/core/widgets/app_icon.dart';
import 'package:money_manager_app/core/extensions/l10n_extensions.dart';
import 'package:money_manager_app/core/theme/app_colors.dart';
import 'package:money_manager_app/core/theme/app_theme.dart';
import 'package:money_manager_app/core/utils/app_snackbar.dart';
import 'package:money_manager_app/core/utils/formatters.dart';
import 'package:money_manager_app/core/utils/goal_status.dart';
import 'package:money_manager_app/core/widgets/category_icon.dart';
import 'package:money_manager_app/core/widgets/confirm_delete_dialog.dart';
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
          .showApp(context.l10n.congratsGoalCompleted(goal.name));
    }
  }

  void _removeEntry(Goal goal, GoalEntry entry) {
    _store.removeGoalEntry(goal.id, entry.id);
  }

  void _edit(Goal goal) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => GoalFormScreen(goal: goal)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
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
                icon: const AppIcon(AppIcons.edit),
                tooltip: l.editGoal,
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
                            label: l.savedLabel,
                            value: goal.saved,
                            color: AppTheme.primary,
                          ),
                          _Stat(
                            label: l.targetAmount,
                            value: goal.target,
                            color: context.textPrimary,
                          ),
                          _Stat(
                            label: l.remaining,
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
                          AppIcon(
                            state == GoalState.completed
                                ? AppIcons.checkCircle
                                : AppIcons.calendar,
                            size: 20,
                            color: state.color,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              goal.deadline == null
                                  ? goalDeadlineText(goal, now, context.l10n)
                                  : state == GoalState.completed
                                      ? '${l.completed} · ${formatDate(goal.deadline!)}'
                                      : '${formatDate(goal.deadline!)} · ${goalDeadlineText(goal, now, context.l10n)}',
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
                                ? '${l.amount}: ${formatMoney(perDay * 30)}/${l.month}'
                                : '${l.amount}: ${formatMoney(perDay)}/${l.day}',
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
                        icon: const AppIcon(AppIcons.add),
                        label: Text(l.deposit),
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
                        icon: const AppIcon(AppIcons.remove),
                        label: Text(l.withdraw),
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
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 8),
                        child: Text(
                          l.history,
                          style: const TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (entries.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: Text(
                              l.noTransactions,
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
                            child: const AppIcon(AppIcons.delete, color: Colors.white),
                          ),
                          confirmDismiss: (_) => confirmDelete(
                            context,
                            title: e.isDeposit ? l.deleteEntryTitle : l.deleteEntryTitle,
                            message: l.deleteEntryMessage,
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
    final l = context.l10n;
    final deposit = entry.isDeposit;
    final color = deposit ? AppTheme.primary : Colors.red.shade400;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Row(
        children: [
          CategoryIcon(
            icon: deposit ? AppIcons.arrowUp : AppIcons.arrowDown,
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
                      ? (deposit ? l.deposit : l.withdraw)
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
