import 'package:flutter/material.dart';
import 'package:money_manager_app/core/widgets/app_icon.dart';
import 'package:flutter/services.dart';
import 'package:money_manager_app/core/theme/app_colors.dart';
import 'package:money_manager_app/core/theme/app_theme.dart';
import 'package:money_manager_app/core/utils/app_snackbar.dart';
import 'package:money_manager_app/core/utils/currency.dart';
import 'package:money_manager_app/core/utils/formatters.dart';
import 'package:money_manager_app/data/services/exchange_rates.dart';
import 'package:money_manager_app/features/settings/currency_switch_dialog.dart';

class CurrencyConverterScreen extends StatefulWidget {
  const CurrencyConverterScreen({super.key});

  @override
  State<CurrencyConverterScreen> createState() =>
      _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState extends State<CurrencyConverterScreen> {
  final _rates = ExchangeRates.instance;
  late AppCurrency _from = AppCurrency.current;
  late AppCurrency _to = AppCurrency.current.code == 'USD'
      ? AppCurrency.vnd
      : AppCurrency.usd;
  late final _amountCtrl = TextEditingController(
    text: _from.quickAmounts[1].toString(),
  );

  @override
  void initState() {
    super.initState();
    _rates.ensureLoaded().then((_) {
      if (mounted && _rates.isStale) _rates.refresh();
    });
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  double _parse(String text) {
    var t = text.replaceAll(RegExp(r'\s'), '');
    final separators = RegExp(r'[.,]').allMatches(t).length;
    t = separators > 1 ? t.replaceAll(RegExp(r'[.,]'), '') : t.replaceAll(',', '.');
    return double.tryParse(t) ?? 0;
  }

  Future<AppCurrency?> _pick(AppCurrency selected) {
    return showDialog<AppCurrency>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Chọn tiền tệ'),
        children: [
          for (final c in AppCurrency.all)
            ListTile(
              title: Text(c.name),
              subtitle: Text(c.label),
              trailing: c.code == selected.code
                  ? const AppIcon(AppIcons.check, color: AppTheme.primary)
                  : null,
              onTap: () => Navigator.of(ctx).pop(c),
            ),
        ],
      ),
    );
  }

  Future<void> _refresh() async {
    final ok = await _rates.refresh();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showApp(
      ok ? 'Đã cập nhật tỷ giá' : 'Không có kết nối, đang dùng tỷ giá đã lưu',
    );
  }

  void _swap() {
    setState(() {
      final tmp = _from;
      _from = _to;
      _to = tmp;
    });
  }

  Widget _currencyTile(
    String label,
    AppCurrency value,
    ValueChanged<AppCurrency> onChanged,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () async {
        final picked = await _pick(value);
        if (picked != null) onChanged(picked);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: context.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '${value.code} · ${value.name}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const AppIcon(AppIcons.chevronDown),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đổi tiền tệ')),
      body: ListenableBuilder(
        listenable: _rates,
        builder: (context, _) {
          final amount = _parse(_amountCtrl.text);
          final rate = _rates.rate(_from, _to);
          final updated = _rates.updatedAt;
          return ListView(
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
                    children: [
                      TextField(
                        controller: _amountCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                        ],
                        onChanged: (_) => setState(() {}),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Số tiền',
                          hintText: '0',
                          suffixText: _from.symbol,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _currencyTile(
                        'Từ',
                        _from,
                        (c) => setState(() => _from = c),
                      ),
                      const Divider(height: 1),
                      Align(
                        child: IconButton(
                          onPressed: _swap,
                          icon: const AppIcon(
                            AppIcons.swap,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                      _currencyTile('Sang', _to, (c) => setState(() => _to = c)),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${formatMoney(amount, _from)} =',
                        style: TextStyle(color: context.textSecondary),
                      ),
                      const SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          formatMoney(amount * rate, _to),
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        formatRateLine(_from, _to, rate),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        updated == null
                            ? 'Đang dùng tỷ giá mặc định có sẵn trong app, có thể đã cũ. Kết nối mạng và bấm cập nhật để lấy tỷ giá mới nhất.'
                            : 'Cập nhật lần cuối: ${formatUpdatedAt(updated)}',
                        style: TextStyle(
                          color: context.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 48,
                child: FilledButton.tonalIcon(
                  onPressed: _rates.refreshing ? null : _refresh,
                  icon: _rates.refreshing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const AppIcon(AppIcons.refresh),
                  label: const Text('Cập nhật tỷ giá'),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Tỷ giá cung cấp bởi ExchangeRate-API (exchangerate-api.com), cập nhật mỗi ngày, chỉ mang tính tham khảo.',
                textAlign: TextAlign.center,
                style: TextStyle(color: context.textSecondary, fontSize: 12),
              ),
            ],
          );
        },
      ),
    );
  }
}
