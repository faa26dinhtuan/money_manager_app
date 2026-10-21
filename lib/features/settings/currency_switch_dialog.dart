import 'package:flutter/material.dart';
import 'package:money_manager_app/core/widgets/app_icon.dart';
import 'package:money_manager_app/core/theme/app_colors.dart';
import 'package:money_manager_app/core/utils/app_snackbar.dart';
import 'package:money_manager_app/core/utils/currency.dart';
import 'package:money_manager_app/core/utils/formatters.dart';
import 'package:money_manager_app/data/services/exchange_rates.dart';

enum CurrencySwitchChoice { displayOnly, convert }

Future<CurrencySwitchChoice?> showCurrencySwitchDialog(
  BuildContext context,
  AppCurrency from,
  AppCurrency to,
) {
  return showDialog<CurrencySwitchChoice>(
    context: context,
    builder: (_) => _CurrencySwitchDialog(from: from, to: to),
  );
}

String formatRateLine(AppCurrency from, AppCurrency to, double rate) {
  final forward = rate >= 1;
  final value = forward ? rate : 1 / rate;
  final digits = value >= 100 ? 2 : 4;
  var text = value.toStringAsFixed(digits);
  if (text.contains('.')) {
    text = text.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }
  final parts = text.split('.');
  final grouped = groupDigits(parts.first);
  final number = parts.length > 1
      ? '$grouped${AppCurrency.current.decimalSep}${parts[1]}'
      : grouped;
  return forward
      ? '1 ${from.code} = $number ${to.code}'
      : '1 ${to.code} = $number ${from.code}';
}

String formatUpdatedAt(DateTime d) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${formatDate(d)} ${two(d.hour)}:${two(d.minute)}';
}

class _CurrencySwitchDialog extends StatefulWidget {
  const _CurrencySwitchDialog({required this.from, required this.to});

  final AppCurrency from;
  final AppCurrency to;

  @override
  State<_CurrencySwitchDialog> createState() => _CurrencySwitchDialogState();
}

class _CurrencySwitchDialogState extends State<_CurrencySwitchDialog> {
  final _rates = ExchangeRates.instance;

  @override
  void initState() {
    super.initState();
    _rates.ensureLoaded();
  }

  Future<void> _refresh() async {
    final ok = await _rates.refresh();
    if (!mounted || ok) return;
    ScaffoldMessenger.of(
      context,
    ).showApp('Không có kết nối, đang dùng tỷ giá đã lưu');
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _rates,
      builder: (context, _) {
        final updated = _rates.updatedAt;
        return AlertDialog(
          title: Text('Đổi sang ${widget.to.code}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Quy đổi toàn bộ số tiền hiện có (giao dịch, ví, ngân sách, mục tiêu, sổ nợ, định kỳ) theo tỷ giá, hay chỉ đổi cách hiển thị?',
                ),
                const SizedBox(height: 12),
                Text(
                  formatRateLine(
                    widget.from,
                    widget.to,
                    _rates.rate(widget.from, widget.to),
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  updated == null
                      ? 'Tỷ giá mặc định có sẵn trong app, có thể đã cũ'
                      : 'Cập nhật: ${formatUpdatedAt(updated)}',
                  style: TextStyle(color: context.textSecondary),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: _rates.refreshing ? null : _refresh,
                    icon: _rates.refreshing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const AppIcon(AppIcons.refresh),
                    label: const Text('Cập nhật tỷ giá'),
                  ),
                ),
                Text(
                  'Số tiền được làm tròn theo loại tiền mới nên không thể khôi phục chính xác. Nên sao lưu trước khi quy đổi.',
                  style: TextStyle(color: context.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(CurrencySwitchChoice.displayOnly),
              child: const Text('Chỉ đổi hiển thị'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(context).pop(CurrencySwitchChoice.convert),
              child: const Text('Quy đổi'),
            ),
          ],
        );
      },
    );
  }
}
