import 'package:flutter/material.dart';
import 'package:money_manager_app/core/widgets/app_icon.dart';
import 'package:money_manager_app/core/extensions/l10n_extensions.dart';
import 'package:money_manager_app/core/extensions/model_l10n.dart';
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

  Map<ThemeMode, String> _modeLabels(BuildContext context) {
    final l = context.l10n;
    return {
      ThemeMode.light: l.themeLight,
      ThemeMode.dark: l.themeDark,
      ThemeMode.system: l.themeSystem,
    };
  }

  Future<void> _pickTheme(BuildContext context) {
    final store = AppStore.instance;
    final labels = _modeLabels(context);
    return showDialog<void>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(context.l10n.theme),
        children: [
          for (final entry in labels.entries)
            ListTile(
              title: Text(entry.value),
              trailing: store.themeMode == entry.key
                  ? const AppIcon(AppIcons.check, color: AppTheme.primary)
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

  String _localeLabel(BuildContext context, Locale? locale) {
    final l = context.l10n;
    if (locale == null) return l.langSystem;
    return switch (locale.languageCode) {
      'vi' => l.langVi,
      'en' => l.langEn,
      _ => locale.languageCode,
    };
  }

  Future<void> _pickLanguage(BuildContext context) {
    final store = AppStore.instance;
    final l = context.l10n;
    final options = <(String, Locale?)>[
      (l.langSystem, null),
      (l.langVi, const Locale('vi')),
      (l.langEn, const Locale('en')),
    ];

    return showDialog<void>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(l.language),
        children: [
          for (final (label, loc) in options)
            ListTile(
              title: Text(label),
              trailing: (loc == null && store.locale == null) ||
                      (loc != null && store.locale?.languageCode == loc.languageCode)
                  ? const AppIcon(AppIcons.check, color: AppTheme.primary)
                  : null,
              onTap: () {
                store.setLocale(loc);
                Navigator.of(ctx).pop();
              },
            ),
        ],
      ),
    );
  }

  Future<void> _pickCurrency(BuildContext context) {
    final store = AppStore.instance;
    final l = context.l10n;
    return showDialog<void>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(l.currencyDefault),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: Text(
              l.currencyDefaultNotice,
              style: TextStyle(color: ctx.textSecondary),
            ),
          ),
          for (final currency in AppCurrency.all)
            ListTile(
              title: Text(currency.localizedName(context)),
              subtitle: Text(currency.label),
              trailing: store.currency.code == currency.code
                  ? const AppIcon(AppIcons.check, color: AppTheme.primary)
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
        final l = context.l10n;
        final items = <(AppIconData, String, String, VoidCallback)>[
          (
            AppIcons.dollar,
            l.currencyDefault,
            AppStore.instance.currency.label,
            () => _pickCurrency(context),
          ),
          (
            AppIcons.exchange,
            l.currencyConverter,
            l.currencyConverterSubtitle,
            () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const CurrencyConverterScreen(),
              ),
            ),
          ),
          (
            AppIcons.brush,
            l.theme,
            _modeLabels(context)[AppStore.instance.themeMode]!,
            () => _pickTheme(context),
          ),
          (
            AppIcons.flag,
            l.language,
            _localeLabel(context, AppStore.instance.locale),
            () => _pickLanguage(context),
          ),
          (
            AppIcons.upload,
            l.backupAndRestore,
            '',
            () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const BackupScreen()),
            ),
          ),
          (
            AppIcons.download,
            l.exportData,
            'CSV',
            () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ExportScreen()),
            ),
          ),
          (
            AppIcons.info,
            l.about,
            l.appVersion('1.0.0'),
            () {},
          ),
        ];

        return Scaffold(
          appBar: AppBar(title: Text(l.settings)),
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
                        leading: AppIcon(items[i].$1, color: AppTheme.primary),
                        title: Text(items[i].$2),
                        subtitle: items[i].$3.isEmpty ? null : Text(items[i].$3),
                        trailing: const AppIcon(AppIcons.chevronRight),
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
