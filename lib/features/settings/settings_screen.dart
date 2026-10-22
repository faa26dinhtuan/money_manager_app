import 'package:flutter/material.dart';
import 'package:money_manager_app/core/widgets/app_icon.dart';
import 'package:money_manager_app/core/extensions/l10n_extensions.dart';
import 'package:money_manager_app/core/extensions/model_l10n.dart';
import 'package:money_manager_app/core/theme/app_colors.dart';
import 'package:money_manager_app/core/theme/app_theme.dart';
import 'package:money_manager_app/core/utils/app_info.dart';
import 'package:money_manager_app/core/utils/currency.dart';
import 'package:money_manager_app/data/services/app_store.dart';
import 'package:money_manager_app/features/settings/backup_screen.dart';
import 'package:money_manager_app/features/settings/currency_converter_screen.dart';
import 'package:money_manager_app/features/settings/export_screen.dart';
import 'package:money_manager_app/features/wallet/wallet_form_screen.dart';

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

  Future<void> _pickCurrency(BuildContext context) async {
    final store = AppStore.instance;
    final action = await showDialog<_DefaultCurrencyAction>(
      context: context,
      builder: (_) => _DefaultCurrencyDialog(initialCurrency: store.currency),
    );
    if (action == null || !context.mounted) return;
    store.setCurrency(action.currency);
    store.selectWallet(null);
    final l = context.l10n;
    final addWallet = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l.addWallet),
        content: Text(l.askAddWalletForCurrency(action.currency.label)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l.no),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l.addWallet),
          ),
        ],
      ),
    );
    if (addWallet != true || !context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WalletFormScreen(initialCurrency: action.currency),
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
            AppIcons.theme,
            l.theme,
            _modeLabels(context)[AppStore.instance.themeMode]!,
            () => _pickTheme(context),
          ),
          (
            AppIcons.language,
            l.language,
            _localeLabel(context, AppStore.instance.locale),
            () => _pickLanguage(context),
          ),
          (
            AppIcons.backup,
            l.backupAndRestore,
            '',
            () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const BackupScreen()),
            ),
          ),
          (
            AppIcons.exportFile,
            l.exportData,
            'CSV',
            () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ExportScreen()),
            ),
          ),
          (
            AppIcons.info,
            l.about,
            l.appVersion(AppInfo.version),
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
                elevation: 1.25,
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

class _DefaultCurrencyAction {
  const _DefaultCurrencyAction(this.currency);

  final AppCurrency currency;
}

class _DefaultCurrencyDialog extends StatefulWidget {
  const _DefaultCurrencyDialog({required this.initialCurrency});

  final AppCurrency initialCurrency;

  @override
  State<_DefaultCurrencyDialog> createState() => _DefaultCurrencyDialogState();
}

class _DefaultCurrencyDialogState extends State<_DefaultCurrencyDialog> {
  late AppCurrency _currency = widget.initialCurrency;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AlertDialog(
      title: Text(l.currencyDefault),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l.currencyDefaultNotice,
              style: TextStyle(color: context.textSecondary),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<AppCurrency>(
              initialValue: _currency,
              decoration: InputDecoration(labelText: l.currencyCodeLabel),
              items: [
                for (final currency in AppCurrency.all)
                  DropdownMenuItem(
                    value: currency,
                    child: Text(
                      '${currency.localizedName(context)} (${currency.code})',
                    ),
                  ),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _currency = value);
              },
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(
                _DefaultCurrencyAction(_currency),
              ),
              child: Text(l.changeDefaultCurrency),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l.cancel),
        ),
      ],
    );
  }
}
