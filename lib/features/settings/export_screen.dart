import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:money_manager_app/core/widgets/app_icon.dart';
import 'package:money_manager_app/core/theme/app_colors.dart';
import 'package:money_manager_app/core/theme/app_theme.dart';
import 'package:money_manager_app/core/utils/csv_export.dart';
import 'package:money_manager_app/data/services/app_store.dart';
import 'package:share_plus/share_plus.dart';

class ExportScreen extends StatefulWidget {
  const ExportScreen({super.key});

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  final _store = AppStore.instance;
  final Set<ExportSection> _selected = {...ExportSection.values};

  int _count(ExportSection section) {
    switch (section) {
      case ExportSection.transactions:
        return _store.transactions.length;
      case ExportSection.wallets:
        return _store.wallets.length;
      case ExportSection.budgets:
        return _store.budgets.length;
      case ExportSection.goals:
        return _store.goals.length;
      case ExportSection.debts:
        return _store.debts.length;
      case ExportSection.recurrings:
        return _store.recurrings.length;
    }
  }

  void _toggle(ExportSection section, bool checked) {
    setState(() {
      if (checked) {
        _selected.add(section);
      } else {
        _selected.remove(section);
      }
    });
  }

  void _toggleAll() {
    setState(() {
      if (_selected.length == ExportSection.values.length) {
        _selected.clear();
      } else {
        _selected.addAll(ExportSection.values);
      }
    });
  }

  Future<void> _export() async {
    final now = DateTime.now();
    final stamp =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final name = 'money_manager_$stamp.csv';
    final bytes = Uint8List.fromList(
      utf8.encode('\uFEFF${exportToCsv(_store, _selected)}'),
    );
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile.fromData(bytes, mimeType: 'text/csv')],
        fileNameOverrides: [name],
        subject: name,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _store,
      builder: (context, _) {
        final allSelected = _selected.length == ExportSection.values.length;
        return Scaffold(
          appBar: AppBar(title: const Text('Xuất dữ liệu')),
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
                        'Xuất ra file CSV',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'CSV là file bảng tính dạng văn bản đơn giản. Chọn các phần dữ liệu muốn xuất bên dưới, mỗi phần sẽ có tiêu đề riêng trong file. '
                        'Bạn có thể mở bằng Excel hoặc Google Sheets để xem, lọc và tính toán.\n\n'
                        'Khác với Sao lưu, file này dùng để xem và phân tích dữ liệu, không dùng để khôi phục lại vào app.',
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
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    CheckboxListTile(
                      value: allSelected
                          ? true
                          : (_selected.isEmpty ? false : null),
                      tristate: true,
                      activeColor: AppTheme.primary,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: const Text(
                        'Chọn tất cả',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      onChanged: (_) => _toggleAll(),
                    ),
                    const Divider(height: 1),
                    for (final section in ExportSection.values)
                      CheckboxListTile(
                        value: _selected.contains(section),
                        activeColor: AppTheme.primary,
                        controlAffinity: ListTileControlAffinity.leading,
                        title: Text(section.label),
                        secondary: Text(
                          '${_count(section)}',
                          style: TextStyle(color: context.textSecondary),
                        ),
                        onChanged: (v) => _toggle(section, v ?? false),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 52,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  onPressed: _selected.isEmpty ? null : _export,
                  icon: const AppIcon(AppIcons.download),
                  label: const Text(
                    'Xuất file CSV',
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
