import 'package:flutter/material.dart';
import 'package:money_manager_app/core/widgets/app_icon.dart';
import 'package:money_manager_app/core/extensions/l10n_extensions.dart';
import 'package:money_manager_app/core/extensions/model_l10n.dart';
import 'package:money_manager_app/core/theme/app_colors.dart';
import 'package:money_manager_app/core/utils/app_snackbar.dart';
import 'package:money_manager_app/core/utils/currency.dart';
import 'package:money_manager_app/core/utils/formatters.dart';
import 'package:money_manager_app/data/services/exchange_rates.dart';
import 'package:money_manager_app/data/services/app_store.dart';

Future<Set<String>?> showWalletConversionDialog(
  BuildContext context,
  AppCurrency from,
  AppCurrency to,
) {
  return showDialog<Set<String>>(
    context: context,
    builder: (_) => _CurrencySwitchDialog(
      from: from,
      to: to,
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
  });

  final AppCurrency from;
  final AppCurrency to;

  @override
  State<_CurrencySwitchDialog> createState() => _CurrencySwitchDialogState();
}

class _CurrencySwitchDialogState extends State<_CurrencySwitchDialog> {
  final _rates = ExchangeRates.instance;
  final _store = AppStore.instance;
  final _selectedWalletIds = <String>{};

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

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return ListenableBuilder(
      listenable: _rates,
      builder: (context, _) {
        final updated = _rates.updatedAt;
        return AlertDialog(
          title: Text(l.convertWallets),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.selectWalletsToConvert),
                const SizedBox(height: 8),
                Text(
                  l.currencyConvertLinkedNotice,
                  style: TextStyle(color: context.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 12),
                for (final wallet in _store.wallets.where(
                  (wallet) => wallet.currencyCode == widget.from.code,
                ))
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _selectedWalletIds.contains(wallet.id),
                    controlAffinity: ListTileControlAffinity.leading,
                    secondary: AppIcon(wallet.icon, color: wallet.color),
                    title: Text(wallet.localizedName(context)),
                    subtitle: Text(
                      formatMoney(_store.walletBalance(wallet.id), widget.from),
                    ),
                    onChanged: (selected) => setState(() {
                      if (selected == true) {
                        _selectedWalletIds.add(wallet.id);
                      } else {
                        _selectedWalletIds.remove(wallet.id);
                      }
                    }),
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
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l.cancel),
            ),
            FilledButton(
              onPressed: _selectedWalletIds.isEmpty
                  ? null
                  : () => Navigator.of(context).pop(Set.of(_selectedWalletIds)),
              child: Text(l.convertSelectedWallets),
            ),
          ],
        );
      },
    );
  }
}
