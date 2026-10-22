import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money_manager_app/core/widgets/app_icon.dart';
import 'package:money_manager_app/core/extensions/l10n_extensions.dart';
import 'package:money_manager_app/core/theme/app_colors.dart';
import 'package:money_manager_app/core/utils/app_snackbar.dart';
import 'package:money_manager_app/core/utils/currency.dart';
import 'package:money_manager_app/core/utils/formatters.dart';
import 'package:money_manager_app/data/services/exchange_rates.dart';
import 'package:money_manager_app/data/services/app_store.dart';

enum CurrencySwitchChoice { existingWallets, newWallet, convert }

Future<CurrencySwitchChoice?> showCurrencySwitchDialog(
  BuildContext context,
  AppCurrency from,
  AppCurrency to, {
  required bool hasExistingWallets,
}) {
  return showDialog<CurrencySwitchChoice>(
    context: context,
    builder: (_) => _CurrencySwitchDialog(
      from: from,
      to: to,
      hasExistingWallets: hasExistingWallets,
    ),
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
  const _CurrencySwitchDialog({
    required this.from,
    required this.to,
    required this.hasExistingWallets,
  });

  final AppCurrency from;
  final AppCurrency to;
  final bool hasExistingWallets;

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
    ScaffoldMessenger.of(context).showApp(context.l10n.ratesOffline);
  }

  Future<void> _copyBackup() async {
    final data = AppStore.instance.createBackup().encode();
    await Clipboard.setData(ClipboardData(text: data));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showApp(context.l10n.backupCopied);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return ListenableBuilder(
      listenable: _rates,
      builder: (context, _) {
        final updated = _rates.updatedAt;
        return AlertDialog(
          title: Text(l.convertCurrencyTitle(widget.to.code)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.convertCurrencyPrompt(widget.to.label)),
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
                      ? l.defaultRatesWarning
                      : l.lastUpdated(formatUpdatedAt(updated)),
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
                    label: Text(l.refreshRates),
                  ),
                ),
                Text(
                  l.currencyConvertWarning,
                  style: TextStyle(color: context.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _copyBackup,
                  icon: const AppIcon(AppIcons.backup),
                  label: Text(l.backupData),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(
                widget.hasExistingWallets
                    ? CurrencySwitchChoice.existingWallets
                    : CurrencySwitchChoice.newWallet,
              ),
              child: Text(
                widget.hasExistingWallets ? l.useExistingWallets : l.addWallet,
              ),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(context).pop(CurrencySwitchChoice.convert),
              child: Text(l.convertAll),
            ),
          ],
        );
      },
    );
  }
}
