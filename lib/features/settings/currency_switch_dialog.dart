import 'package:flutter/material.dart';
import 'package:money_manager_app/core/widgets/app_icon.dart';
import 'package:money_manager_app/core/extensions/l10n_extensions.dart';
import 'package:money_manager_app/core/extensions/model_l10n.dart';
import 'package:money_manager_app/core/theme/app_colors.dart';
import 'package:money_manager_app/core/utils/currency.dart';
import 'package:money_manager_app/core/utils/formatters.dart';
import 'package:money_manager_app/data/services/app_store.dart';

Future<Set<String>?> showWalletConversionDialog(BuildContext context) {
  return showDialog<Set<String>>(
    context: context,
    builder: (_) => const _WalletSelectionDialog(),
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

class _WalletSelectionDialog extends StatefulWidget {
  const _WalletSelectionDialog();

  @override
  State<_WalletSelectionDialog> createState() => _WalletSelectionDialogState();
}

class _WalletSelectionDialogState extends State<_WalletSelectionDialog> {
  final _store = AppStore.instance;
  final _selectedWalletIds = <String>{};
  late final _visibleCurrencies =
      _store.wallets.map((wallet) => wallet.currencyCode).toSet();

  String? get _selectedCurrencyCode => _selectedWalletIds.isEmpty
      ? null
      : _store.walletById(_selectedWalletIds.first)?.currencyCode;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final currencies = AppCurrency.all
        .where((currency) => _store.wallets.any(
              (wallet) => wallet.currencyCode == currency.code,
            ))
        .toList()
      ..sort((a, b) => a.code.compareTo(b.code));
    final wallets = _store.wallets
        .where((wallet) => _visibleCurrencies.contains(wallet.currencyCode))
        .toList()
      ..sort((a, b) {
        final currencyOrder = a.currencyCode.compareTo(b.currencyCode);
        return currencyOrder != 0 ? currencyOrder : a.name.compareTo(b.name);
      });
    return AlertDialog(
      title: Text(l.convertWallets),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.selectWalletsToConvert),
              const SizedBox(height: 12),
              Text(l.filterCurrencies, style: TextStyle(color: context.textSecondary)),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  for (final currency in currencies)
                    FilterChip(
                      label: Text(currency.code),
                      selected: _visibleCurrencies.contains(currency.code),
                      onSelected: (visible) => setState(() {
                        if (visible) {
                          _visibleCurrencies.add(currency.code);
                        } else {
                          _visibleCurrencies.remove(currency.code);
                          _selectedWalletIds.removeWhere(
                            (id) => _store.walletById(id)?.currencyCode == currency.code,
                          );
                        }
                      }),
                    ),
                ],
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => setState(() {
                    _visibleCurrencies
                      ..clear()
                      ..addAll(_store.wallets.map((wallet) => wallet.currencyCode));
                  }),
                  child: Text(l.showAllCurrencies),
                ),
              ),
              Text(
                l.walletsMustShareCurrency,
                style: TextStyle(color: context.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 8),
              for (final wallet in wallets)
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _selectedWalletIds.contains(wallet.id),
                  controlAffinity: ListTileControlAffinity.leading,
                  secondary: AppIcon(wallet.icon, color: wallet.color),
                  title: Text(wallet.localizedName(context)),
                  subtitle: Text(
                    '${wallet.currencyCode} · ${formatMoney(_store.walletBalance(wallet.id), AppCurrency.byCode(wallet.currencyCode))}',
                  ),
                  onChanged: _selectedCurrencyCode != null &&
                          _selectedCurrencyCode != wallet.currencyCode &&
                          !_selectedWalletIds.contains(wallet.id)
                      ? null
                      : (selected) => setState(() {
                            if (selected == true) {
                              _selectedWalletIds.add(wallet.id);
                            } else {
                              _selectedWalletIds.remove(wallet.id);
                            }
                          }),
                ),
              const SizedBox(height: 8),
              Text(
                l.currencyConvertLinkedNotice,
                style: TextStyle(color: context.textSecondary, fontSize: 12),
              ),
            ],
          ),
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
  }
}
