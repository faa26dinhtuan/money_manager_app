import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:money_manager_app/core/widgets/app_icon.dart';
import 'package:flutter/services.dart';
import 'package:money_manager_app/core/extensions/l10n_extensions.dart';
import 'package:money_manager_app/core/theme/app_colors.dart';
import 'package:money_manager_app/core/theme/app_theme.dart';
import 'package:money_manager_app/core/utils/app_snackbar.dart';
import 'package:money_manager_app/core/utils/formatters.dart';
import 'package:money_manager_app/data/models/backup_data.dart';
import 'package:money_manager_app/data/services/app_store.dart';

class BackupScreen extends StatelessWidget {
  const BackupScreen({super.key});

  Future<void> _backup(BuildContext context) async {
    final code = AppStore.instance.createBackup().encode();
    await Clipboard.setData(ClipboardData(text: code));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showApp(context.l10n.backupCopied);
  }

  Future<void> _restore(BuildContext context) async {
    final l = context.l10n;
    final clip = await Clipboard.getData(Clipboard.kTextPlain);
    if (!context.mounted) return;
    final BackupData backup;
    try {
      backup = BackupData.parse(clip?.text ?? '');
    } on FormatException {
      ScaffoldMessenger.of(context).showApp(l.restoreNotFound);
      return;
    }
    final confirmed = await showAdaptiveDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(l.restoreConfirmTitle),
        content: Text(
          '${backup.exportedAt == null ? '' : '${formatDate(backup.exportedAt!)}\n'}'
          '${backup.wallets.length} ${l.wallet}, ${backup.transactions.length} ${l.transactions}, '
          '${backup.categories.length} ${l.categories}.\n\n'
          '${l.restoreConfirmMessage}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red.shade400),
            child: Text(l.restoreData),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await AppStore.instance.restoreBackup(backup);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showApp(l.restoreSuccess);
  }

  Widget _row(BuildContext context, String label, int value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: TextStyle(color: context.textSecondary)),
          ),
          Text('$value', style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  ButtonStyle _style(Color color) {
    return FilledButton.styleFrom(
      backgroundColor: color,
      foregroundColor: color == AppTheme.accent ? AppTheme.primaryDeep : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = AppStore.instance;
    final l = context.l10n;
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final data = store.createBackup();
        return Scaffold(
          appBar: AppBar(title: Text(l.backupAndRestore)),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                color: context.surfaceColor,
                elevation: 1.25,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.backupExplainTitle,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l.backupExplainBody,
                        style: TextStyle(
                          color: context.textSecondary,
                          height: 1.4,
                        ),
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
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _row(context, l.wallet, data.wallets.length),
                      _row(context, l.transactions, data.transactions.length),
                      _row(context, l.categories, data.categories.length),
                      _row(context, l.budget, data.budgets.length),
                      _row(context, l.goals, data.goals.length),
                      _row(context, l.debts, data.debts.length),
                      _row(context, l.recurring, data.recurrings.length),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 52,
                child: FilledButton.icon(
                  style: _style(AppTheme.primary),
                  onPressed: () => _backup(context),
                  icon: const AppIcon(AppIcons.upload),
                  label: Text(
                    l.backupData,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 52,
                child: FilledButton.icon(
                  style: _style(AppTheme.accent),
                  onPressed: () => _restore(context),
                  icon: const AppIcon(AppIcons.download),
                  label: Text(
                    l.restoreFromClipboard,
                    style: const TextStyle(fontSize: 16),
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
