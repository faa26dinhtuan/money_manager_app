import 'package:flutter/material.dart';
import 'package:money_manager_app/core/extensions/l10n_extensions.dart';
import 'package:money_manager_app/core/theme/app_theme.dart';
import 'package:money_manager_app/core/widgets/app_icon.dart';

Future<void> showOverviewGuideDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (_) => const _OverviewGuideDialog(),
  );
}

class _OverviewGuideDialog extends StatefulWidget {
  const _OverviewGuideDialog();

  @override
  State<_OverviewGuideDialog> createState() => _OverviewGuideDialogState();
}

class _OverviewGuideDialogState extends State<_OverviewGuideDialog> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final steps = <(IconData?, AppIconData?, String, String)>[
      (null, AppIcons.wallet, l.overviewGuideWalletTitle, l.overviewGuideWalletDescription),
      (Icons.visibility_outlined, null, l.overviewGuideBalanceTitle, l.overviewGuideBalanceDescription),
      (null, AppIcons.transactions, l.overviewGuideTypeTitle, l.overviewGuideTypeDescription),
      (null, AppIcons.calendar, l.overviewGuidePeriodTitle, l.overviewGuidePeriodDescription),
      (Icons.pie_chart_outline, null, l.overviewGuideChartTitle, l.overviewGuideChartDescription),
      (null, AppIcons.settings, l.overviewGuideSettingsTitle, l.overviewGuideSettingsDescription),
      (null, AppIcons.add, l.overviewGuideAddTitle, l.overviewGuideAddDescription),
    ];
    final step = steps[_index];
    final isLast = _index == steps.length - 1;

    return AlertDialog(
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: Container(
                key: ValueKey(_index),
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Center(
                  child: step.$1 != null
                      ? Icon(step.$1, color: AppTheme.primary, size: 34)
                      : AppIcon(step.$2!, color: AppTheme.primary, size: 34),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l.overviewGuideTitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: Column(
                key: ValueKey('$_index-description'),
                children: [
                  Text(
                    step.$3,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    step.$4,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Theme.of(context).hintColor),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < steps.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == _index ? 18 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: i == _index
                          ? AppTheme.primary
                          : AppTheme.primary.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l.skipGuide),
        ),
        FilledButton(
          onPressed: () {
            if (isLast) {
              Navigator.of(context).pop();
            } else {
              setState(() => _index++);
            }
          },
          child: Text(isLast ? l.done : l.continueText),
        ),
      ],
    );
  }
}
