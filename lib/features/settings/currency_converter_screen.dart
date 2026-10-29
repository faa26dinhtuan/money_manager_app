import 'package:flutter/material.dart';
import 'package:money_manager_app/core/widgets/app_icon.dart';
import 'package:money_manager_app/core/extensions/l10n_extensions.dart';
import 'package:money_manager_app/core/extensions/model_l10n.dart';
import 'package:money_manager_app/core/theme/app_colors.dart';
import 'package:money_manager_app/core/theme/app_theme.dart';
import 'package:money_manager_app/core/utils/app_snackbar.dart';
import 'package:money_manager_app/core/utils/currency.dart';
import 'package:money_manager_app/core/utils/formatters.dart';
import 'package:money_manager_app/core/widgets/money_field.dart';
import 'package:money_manager_app/data/services/app_store.dart';
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
  late final _amountCtrl = MoneyController(currency: _from)
    ..amount = _from.quickAmounts[1].toDouble();

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

  Future<AppCurrency?> _pick(AppCurrency selected) {
    final l = context.l10n;
    return showAdaptiveDialog<AppCurrency>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(l.selectCurrency),
        children: [
          for (final c in AppCurrency.all)
            ListTile(
              title: Text(c.localizedName(context)),
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
    final l = context.l10n;
    final ok = await _rates.refresh();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showApp(
      ok ? l.ratesUpdated : l.ratesOffline,
    );
  }

  Future<AppCurrency?> _pickTargetCurrency(AppCurrency from) {
    final options = AppCurrency.all
        .where((currency) => currency.code != from.code)
        .toList();
    var selected = options.firstWhere(
      (currency) => currency.code == _to.code,
      orElse: () => options.first,
    );
    final l = context.l10n;
    return showAdaptiveDialog<AppCurrency>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l.selectTargetCurrency),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${l.fromCurrency}: ${from.localizedName(context)} (${from.code})'),
              const SizedBox(height: 12),
              DropdownButtonFormField<AppCurrency>(
                initialValue: selected,
                decoration: InputDecoration(labelText: l.toCurrency),
                items: [
                  for (final currency in options)
                    DropdownMenuItem(
                      value: currency,
                      child: Text('${currency.localizedName(context)} (${currency.code})'),
                    ),
                ],
                onChanged: (currency) {
                  if (currency != null) setDialogState(() => selected = currency);
                },
              ),
              const SizedBox(height: 12),
              Text(formatRateLine(from, selected, _rates.rate(from, selected))),
              const SizedBox(height: 4),
              Text(
                _rates.updatedAt == null
                    ? l.defaultRatesWarning
                    : l.lastUpdated(formatUpdatedAt(_rates.updatedAt!)),
                style: TextStyle(color: context.textSecondary, fontSize: 12),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(selected),
              child: Text(l.convertSelectedWallets),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _convertWallets() async {
    final walletIds = await showWalletConversionDialog(context);
    if (walletIds == null || walletIds.isEmpty || !mounted) return;
    final source = AppStore.instance.walletById(walletIds.first);
    if (source == null) return;
    final from = AppCurrency.byCode(source.currencyCode);
    if (walletIds.any(
      (id) => AppStore.instance.walletById(id)?.currencyCode != from.code,
    )) {
      return;
    }
    await _rates.ensureLoaded();
    if (!mounted) return;
    final to = await _pickTargetCurrency(from);
    if (to == null || !mounted) return;
    await AppStore.instance.convertCurrency(
      from,
      to,
      _rates.rate(from, to),
      walletIds: walletIds,
    );
    if (mounted) setState(() {});
  }

  Future<void> _undoLastWalletConversion() async {
    final restored = await AppStore.instance.undoLastCurrencyConversion();
    if (!mounted) return;
    if (restored) {
      setState(() {});
      ScaffoldMessenger.of(context).showApp(context.l10n.walletConversionUndone);
    }
  }

  void _swap() {
    setState(() {
      final tmp = _from;
      _from = _to;
      _to = tmp;
      _amountCtrl.useCurrency(_from);
    });
  }

  void _setFromCurrency(AppCurrency currency) {
    setState(() {
      _from = currency;
      _amountCtrl.useCurrency(currency);
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
                    '${value.code} · ${value.localizedName(context)}',
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
    final l = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l.currencyConverter)),
      body: ListenableBuilder(
        listenable: _rates,
        builder: (context, _) {
          final amount = _amountCtrl.amount;
          final rate = _rates.rate(_from, _to);
          final updated = _rates.updatedAt;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                color: context.surfaceColor,
                elevation: 1.25,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      MoneyField(
                        controller: _amountCtrl,
                        title: l.amount,
                        onChanged: (_) => setState(() {}),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          labelText: l.amount,
                          hintText: '0',
                          suffixText: _from.symbol,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _currencyTile(
                        l.fromCurrency,
                        _from,
                        _setFromCurrency,
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
                      _currencyTile(l.toCurrency, _to, (c) => setState(() => _to = c)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                color: context.surfaceColor,
                elevation: 1.25,
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
                            ? l.defaultRatesWarning
                            : l.lastUpdated(formatUpdatedAt(updated)),
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
                  label: Text(l.refreshRates),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                color: context.surfaceColor,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.convertWallets,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l.walletConversionSubtitle,
                        style: TextStyle(color: context.textSecondary),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.tonalIcon(
                          onPressed: _convertWallets,
                          icon: const AppIcon(AppIcons.exchange),
                          label: Text(l.convertWallets),
                        ),
                      ),
                      if (AppStore.instance.canUndoCurrencyConversion) ...[
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _undoLastWalletConversion,
                            icon: const Icon(Icons.undo),
                            label: Text(l.undoLastWalletConversion),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l.currencyDisclaimer,
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


