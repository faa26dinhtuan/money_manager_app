import 'package:flutter/material.dart';
import 'package:money_manager_app/core/theme/app_colors.dart';
import 'package:money_manager_app/core/theme/app_theme.dart';
import 'package:money_manager_app/core/utils/app_snackbar.dart';
import 'package:money_manager_app/data/services/app_store.dart';
import 'package:money_manager_app/features/settings/backup_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const _modeLabels = <ThemeMode, String>{
    ThemeMode.light: 'Sáng',
    ThemeMode.dark: 'Tối',
    ThemeMode.system: 'Theo hệ thống',
  };

  void _soon(BuildContext context) {
    ScaffoldMessenger.of(context).showApp('Tính năng sẽ có ở bước sau');
  }

  Future<void> _pickTheme(BuildContext context) {
    final store = AppStore.instance;
    return showDialog<void>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Giao diện'),
        children: [
          for (final entry in _modeLabels.entries)
            ListTile(
              title: Text(entry.value),
              trailing: store.themeMode == entry.key
                  ? const Icon(Icons.check, color: AppTheme.primary)
                  : null,
              onTap: () {
                store.setThemeMode(entry.key);
                Navigator.of(ctx).pop();
              },
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppStore.instance,
      builder: (context, _) {
        final items = <(IconData, String, String, VoidCallback)>[
          (
            Icons.attach_money,
            'Tiền tệ mặc định',
            'VND (₫)',
            () => _soon(context),
          ),
          (
            Icons.palette_outlined,
            'Giao diện',
            _modeLabels[AppStore.instance.themeMode]!,
            () => _pickTheme(context),
          ),
          (
            Icons.cloud_upload_outlined,
            'Sao lưu & khôi phục',
            '',
            () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const BackupScreen()),
            ),
          ),
          (
            Icons.file_download_outlined,
            'Xuất dữ liệu',
            'CSV',
            () => _soon(context),
          ),
          (
            Icons.info_outline,
            'Giới thiệu',
            'Phiên bản 1.0.0',
            () => _soon(context),
          ),
        ];

        return Scaffold(
          appBar: AppBar(title: const Text('Cài đặt')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                color: context.surfaceColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    for (var i = 0; i < items.length; i++) ...[
                      ListTile(
                        leading: Icon(items[i].$1, color: AppTheme.primary),
                        title: Text(items[i].$2),
                        subtitle: items[i].$3.isEmpty ? null : Text(items[i].$3),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: items[i].$4,
                      ),
                      if (i < items.length - 1)
                        const Divider(height: 1, indent: 56),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
