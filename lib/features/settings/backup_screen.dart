import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    ScaffoldMessenger.of(
      context,
    ).showApp('Đã sao chép bản sao lưu. Hãy dán vào nơi an toàn để lưu lại');
  }

  Future<void> _restore(BuildContext context) async {
    final clip = await Clipboard.getData(Clipboard.kTextPlain);
    if (!context.mounted) return;
    final BackupData backup;
    try {
      backup = BackupData.parse(clip?.text ?? '');
    } on FormatException {
      ScaffoldMessenger.of(
        context,
      ).showApp('Không tìm thấy bản sao lưu hợp lệ trong bộ nhớ tạm');
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Khôi phục dữ liệu?'),
        content: Text(
          'Bản sao lưu${backup.exportedAt == null ? '' : ' ngày ${formatDate(backup.exportedAt!)}'} '
          'có ${backup.wallets.length} ví, ${backup.transactions.length} giao dịch, '
          '${backup.categories.length} danh mục.\n\n'
          'Toàn bộ dữ liệu hiện tại sẽ bị thay thế.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red.shade400),
            child: const Text('Khôi phục'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await AppStore.instance.restoreBackup(backup);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showApp('Đã khôi phục dữ liệu');
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
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = AppStore.instance;
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final data = store.createBackup();
        return Scaffold(
          appBar: AppBar(title: const Text('Sao lưu & khôi phục')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                color: context.surfaceColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tính năng này để làm gì?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Dữ liệu chỉ nằm trên máy này. Nếu bạn đổi điện thoại hoặc xóa app, dữ liệu sẽ mất.\n\n'
                        'Sao lưu: tạo một đoạn mã chứa toàn bộ dữ liệu và chép vào bộ nhớ tạm. '
                        'Hãy dán nó vào Ghi chú, Zalo hoặc email gửi cho chính mình.\n\n'
                        'Khôi phục: chép lại đoạn mã đó rồi bấm Khôi phục để đưa dữ liệu về.',
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
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _row(context, 'Ví', data.wallets.length),
                      _row(context, 'Giao dịch', data.transactions.length),
                      _row(context, 'Danh mục', data.categories.length),
                      _row(context, 'Ngân sách', data.budgets.length),
                      _row(context, 'Mục tiêu tiết kiệm', data.goals.length),
                      _row(context, 'Khoản nợ', data.debts.length),
                      _row(
                        context,
                        'Giao dịch định kỳ',
                        data.recurrings.length,
                      ),
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
                  icon: const Icon(Icons.cloud_upload_outlined),
                  label: const Text(
                    'Sao lưu dữ liệu',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 52,
                child: FilledButton.icon(
                  style: _style(AppTheme.accent),
                  onPressed: () => _restore(context),
                  icon: const Icon(Icons.cloud_download_outlined),
                  label: const Text(
                    'Khôi phục từ bộ nhớ tạm',
                    style: TextStyle(fontSize: 16),
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
