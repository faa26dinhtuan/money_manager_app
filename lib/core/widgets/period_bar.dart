import 'package:flutter/material.dart';
import 'package:money_manager_app/core/widgets/app_icon.dart';
import 'package:money_manager_app/core/theme/app_colors.dart';
import 'package:money_manager_app/core/theme/app_theme.dart';
import 'package:money_manager_app/core/utils/date_range.dart';

class PeriodBar extends StatelessWidget {
  const PeriodBar({
    super.key,
    required this.period,
    required this.anchor,
    required this.onPeriodChanged,
    required this.onShift,
    this.periods = _defaultPeriods,
    this.customRange,
    this.onLabelTap,
  });

  static const _defaultPeriods = [
    Period.day,
    Period.week,
    Period.month,
    Period.year,
  ];

  final Period period;
  final DateTime anchor;
  final ValueChanged<Period> onPeriodChanged;
  final ValueChanged<int> onShift;
  final List<Period> periods;
  final DateRange? customRange;
  final VoidCallback? onLabelTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            for (final p in periods)
              Flexible(
                child: GestureDetector(
                  onTap: () => onPeriodChanged(p),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: p == period
                              ? AppTheme.primary
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        p.label,
                        style: TextStyle(
                          color: p == period
                              ? AppTheme.primary
                              : context.textSecondary,
                          fontWeight: p == period
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            if (period == Period.custom)
              const SizedBox(width: 48)
            else
              IconButton(
                icon: const AppIcon(AppIcons.chevronLeft),
                onPressed: () => onShift(-1),
              ),
            Expanded(
              child: GestureDetector(
                onTap: period == Period.custom ? onLabelTap : null,
                behavior: HitTestBehavior.opaque,
                child: Center(
                  child: Text(
                    DateRange.label(period, anchor, customRange),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
            if (period == Period.custom)
              const SizedBox(width: 48)
            else
              IconButton(
                icon: const AppIcon(AppIcons.chevronRight),
                onPressed: () => onShift(1),
              ),
          ],
        ),
      ],
    );
  }
}
