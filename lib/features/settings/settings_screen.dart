import 'package:flutter/material.dart';
import 'package:money_manager_app/core/theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _soon(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Tính năng sẽ có ở bước sau')),
      );
  }

  @override
  Widget build(BuildContext context) {
    final items = <(IconData, String, String)>[
      (Icons.attach_money, 'Tiền tệ mặc định', 'VND (₫)'),
      (Icons.palette_outlined, 'Giao diện', 'Sáng'),
      (Icons.cloud_upload_outlined, 'Sao lưu & khôi phục', ''),
      (Icons.file_download_outlined, 'Xuất dữ liệu', 'CSV'),
      (Icons.info_outline, 'Giới thiệu', 'Phiên bản 1.0.0'),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Colors.white,
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
                    onTap: () => _soon(context),
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
  }
}
