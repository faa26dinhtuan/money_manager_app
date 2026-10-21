import 'package:flutter/material.dart';
import 'package:money_manager_app/core/theme/app_colors.dart';
import 'package:money_manager_app/core/theme/app_theme.dart';
import 'package:money_manager_app/core/utils/currency.dart';
import 'package:money_manager_app/data/services/app_store.dart';
import 'package:money_manager_app/data/services/exchange_rates.dart';
import 'package:money_manager_app/features/settings/backup_screen.dart';
import 'package:money_manager_app/features/settings/currency_converter_screen.dart';
import 'package:money_manager_app/features/settings/currency_switch_dialog.dart';
import 'package:money_manager_app/features/settings/export_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const _modeLabels = <ThemeMode, String>{
    ThemeMode.light: 'Sáng',
    ThemeMode.dark: 'Tối',
    ThemeMode.system: 'Theo hệ thống',
  };

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

  Future<void> _pickCurrency(BuildContext context) {
    final store = AppStore.instance;
    return showDialog<void>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Tiền tệ mặc định'),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: Text(
              'Chỉ đổi cách hiển thị, số tiền đã nhập không được quy đổi.',
              style: TextStyle(color: ctx.textSecondary),
            ),
          ),
          for (final currency in AppCurrency.all)
            ListTile(
              title: Text(currency.name),
              subtitle: Text(currency.label),
              trailing: store.currency.code == currency.code
                  ? const Icon(Icons.check, color: AppTheme.primary)
                  : null,
              onTap: () async {
                Navigator.of(ctx).pop();
                final from = store.currency;
                if (currency.code == from.code) return;
                final choice = await showCurrencySwitchDialog(
                  context,
                  from,
                  currency,
                );
                if (choice == null) return;
                if (choice == CurrencySwitchChoice.convert) {
                  await ExchangeRates.instance.ensureLoaded();
                  await store.convertCurrency(
                    currency,
                    ExchangeRates.instance.rate(from, currency),
                  );
                } else {
                  store.setCurrency(currency);
                }
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
            AppStore.instance.currency.label,
            () => _pickCurrency(context),
          ),
          (
            Icons.currency_exchange,
            'Đổi tiền tệ',
            'Quy đổi theo tỷ giá',
            () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const CurrencyConverterScreen(),
              ),
            ),
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
            () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ExportScreen()),
            ),
          ),
          (
            Icons.info_outline,
            'Giới thiệu',
            'Phiên bản 1.0.0',
            () {},
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
