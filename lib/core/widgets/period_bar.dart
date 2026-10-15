import 'package:flutter/material.dart';
import 'package:money_manager_app/core/theme/app_theme.dart';
import 'package:money_manager_app/core/utils/date_range.dart';

class PeriodBar extends StatelessWidget {
  const PeriodBar({
    super.key,
    required this.period,
    required this.anchor,
    required this.onPeriodChanged,
    required this.onShift,
  });

  final Period period;
  final DateTime anchor;
  final ValueChanged<Period> onPeriodChanged;
  final ValueChanged<int> onShift;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            for (final p in Period.values)
              GestureDetector(
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
                  child: Text(
                    p.label,
                    style: TextStyle(
                      color: p == period ? AppTheme.primary : Colors.black54,
                      fontWeight: p == period
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () => onShift(-1),
            ),
            Expanded(
              child: Center(
                child: Text(
                  DateRange.label(period, anchor),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () => onShift(1),
            ),
          ],
        ),
      ],
    );
  }
}
