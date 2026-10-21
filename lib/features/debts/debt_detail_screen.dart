import 'package:flutter/material.dart';
import 'package:money_manager_app/core/widgets/app_icon.dart';
import 'package:money_manager_app/core/theme/app_colors.dart';
import 'package:money_manager_app/core/theme/app_theme.dart';
import 'package:money_manager_app/core/utils/app_snackbar.dart';
import 'package:money_manager_app/core/utils/debt_status.dart';
import 'package:money_manager_app/core/utils/formatters.dart';
import 'package:money_manager_app/core/widgets/budget_progress_bar.dart';
import 'package:money_manager_app/core/widgets/category_icon.dart';
import 'package:money_manager_app/core/widgets/confirm_delete_dialog.dart';
import 'package:money_manager_app/data/models/debt.dart';
import 'package:money_manager_app/data/services/app_store.dart';
import 'package:money_manager_app/features/debts/debt_form_screen.dart';
import 'package:money_manager_app/features/debts/debt_payment_dialog.dart';

class DebtDetailScreen extends StatefulWidget {
  const DebtDetailScreen({super.key, required this.debtId});

  final String debtId;

  @override
  State<DebtDetailScreen> createState() => _DebtDetailScreenState();
}

class _DebtDetailScreenState extends State<DebtDetailScreen> {
  final _store = AppStore.instance;
  Debt? _last;

  Future<void> _openPayment(Debt debt) async {
    final payment = await showDialog<DebtPayment>(
      context: context,
      builder: (_) => DebtPaymentDialog(debt: debt),
    );
    if (payment == null || !mounted) return;
    final wasSettled = debt.isSettled;
    _store.addDebtPayment(debt.id, payment);
    final updated = _store.debtById(debt.id);
    if (!wasSettled && updated != null && updated.isSettled) {
      ScaffoldMessenger.of(context)
          .showApp('Đã tất toán khoản của "${debt.person}"');
    }
  }

  void _removePayment(Debt debt, DebtPayment payment) {
    _store.removeDebtPayment(debt.id, payment.id);
  }

  void _edit(Debt debt) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => DebtFormScreen(debt: debt)));
  }

  String? _walletName(String? id) =>
      id == null ? null : _store.walletById(id)?.name;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _store,
      builder: (context, _) {
        final debt = _store.debtById(widget.debtId) ?? _last;
        if (debt == null) return const Scaffold();
        _last = debt;

        final now = DateTime.now();
        final state = debtStateOf(debt, now);
        final barColor = state == DebtState.ongoing
            ? debt.type.color
            : state.color;
        final percent = (debt.progress * 100).clamp(0.0, 100.0);
        final payments = [...debt.payments]
          ..sort((a, b) => b.date.compareTo(a.date));
        final walletName = _walletName(debt.walletId);
        final isLend = debt.type == DebtType.lend;

        return Scaffold(
          appBar: AppBar(
            title: Text(debt.person),
            actions: [
              IconButton(
                icon: const AppIcon(AppIcons.edit),
                tooltip: 'Sửa khoản nợ',
                onPressed: () => _edit(debt),
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
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
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
                                Text(
                                  debt.type.label,
                                  style: TextStyle(
                                    color: debt.type.color,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  debt.isSettled
                                      ? 'Đã tất toán'
                                      : 'Còn ${formatMoney(debt.remaining)}',
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
                      const SizedBox(height: 16),
                      BudgetProgressBar(
                        value: debt.progress,
                        color: barColor,
                        height: 10,
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          formatPercent(percent),
                          style: TextStyle(
                            color: barColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _Stat(
                            label: 'Số tiền gốc',
                            value: debt.amount,
                            color: context.textPrimary,
                          ),
                          _Stat(
                            label: debt.type.paidLabel,
                            value: debt.paid,
                            color: AppTheme.primary,
                          ),
                          _Stat(
                            label: 'Còn lại',
                            value: debt.remaining,
                            color: debt.remaining > 0
                                ? Colors.red.shade400
                                : AppTheme.primary,
                          ),
                        ],
                      ),
                      const Divider(height: 28),
                      _InfoRow(
                        icon: AppIcons.calendar,
                        text:
                            '${isLend ? 'Cho vay' : 'Vay'} ngày ${formatDate(debt.date)}',
                      ),
                      const SizedBox(height: 8),
                      _InfoRow(
                        icon: AppIcons.clock,
                        color: state.color,
                        text: debt.dueDate == null
                            ? 'Không có hạn trả'
                            : debt.isSettled
                            ? 'Hạn trả ${formatDate(debt.dueDate!)}'
                            : 'Hạn trả ${formatDate(debt.dueDate!)} · ${debtDueText(debt, now)}',
                      ),
                      if (walletName != null) ...[
                        const SizedBox(height: 8),
                        _InfoRow(
                          icon: AppIcons.wallet,
                          text: 'Ví: $walletName',
                        ),
                      ],
                      if (debt.note.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        _InfoRow(icon: AppIcons.notes, text: debt.note),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 48,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.accent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  icon: const AppIcon(AppIcons.payments),
                  label: Text(debt.type.paymentLabel),
                  onPressed: debt.isSettled ? null : () => _openPayment(debt),
                ),
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
                      for (final p in payments)
                        Dismissible(
                          key: ValueKey(p.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            color: Colors.red.shade400,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const AppIcon(
                              AppIcons.delete,
                              color: Colors.white,
                            ),
                          ),
                          confirmDismiss: (_) => confirmDelete(
                            context,
                            title: 'Xóa lần thanh toán?',
                            message: 'Số tiền còn lại của khoản nợ sẽ được tính lại.',
                          ),
                          onDismissed: (_) => _removePayment(debt, p),
                          child: _HistoryTile(
                            icon: AppIcons.payments,
                            color: AppTheme.primary,
                            title: p.note.isEmpty
                                ? debt.type.paymentLabel
                                : p.note,
                            date: p.date,
                            walletName: _walletName(p.walletId),
                            amount: debt.paymentFlow(p),
                          ),
                        ),
                      _HistoryTile(
                        icon: debt.type.icon,
                        color: debt.type.color,
                        title: isLend ? 'Khoản cho vay' : 'Khoản đi vay',
                        date: debt.date,
                        walletName: walletName,
                        amount: debt.principalFlow,
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

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text, this.color});

  final AppIconData icon;
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? context.textSecondary;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppIcon(icon, size: 20, color: c),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: c, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.date,
    required this.walletName,
    required this.amount,
  });

  final AppIconData icon;
  final Color color;
  final String title;
  final DateTime date;
  final String? walletName;
  final double amount;

  @override
  Widget build(BuildContext context) {
    final positive = amount > 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Row(
        children: [
          CategoryIcon(icon: icon, color: color, size: 34),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title),
                Text(
                  walletName == null
                      ? formatDate(date)
                      : '${formatDate(date)} · $walletName',
                  style: TextStyle(color: context.textTertiary, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            '${positive ? '+' : '-'}${formatMoney(amount.abs())}',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: positive ? AppTheme.primary : Colors.red.shade400,
            ),
          ),
        ],
      ),
    );
  }
}
