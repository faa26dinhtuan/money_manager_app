import 'package:flutter/material.dart';
import 'package:money_manager_app/core/extensions/model_l10n.dart';
import 'package:money_manager_app/core/theme/app_colors.dart';
import 'package:money_manager_app/core/theme/app_theme.dart';
import 'package:money_manager_app/data/models/category.dart';

class TypeTabs extends StatelessWidget {
  const TypeTabs({
    super.key,
    required this.type,
    required this.onChanged,
    this.onPrimary = false,
  });

  final TxType type;
  final ValueChanged<TxType> onChanged;
  final bool onPrimary;

  @override
  Widget build(BuildContext context) {
    final selectedColor = onPrimary ? Colors.white : AppTheme.primary;
    final idleColor = onPrimary ? Colors.white60 : context.textTertiary;
    return Row(
      children: [
        for (final t in TxType.values)
          Expanded(
            child: InkWell(
              onTap: () => onChanged(t),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: t == type ? selectedColor : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
                child: Center(
                  child: Text(
                    t.localizedLabel(context),
                    style: TextStyle(
                      color: t == type ? selectedColor : idleColor,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
