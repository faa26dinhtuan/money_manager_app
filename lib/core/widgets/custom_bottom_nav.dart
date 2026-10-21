import 'package:flutter/material.dart';
import 'package:money_manager_app/core/widgets/app_icon.dart';
import 'package:money_manager_app/core/theme/app_colors.dart';
import 'package:money_manager_app/core/theme/app_theme.dart';

import 'package:money_manager_app/core/extensions/l10n_extensions.dart';

class CustomBottomNav extends StatelessWidget {
  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const double barHeight = 64;
  static const double buttonSize = 68;
  static const double protrusion = 20;

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Container(
      height: barHeight + bottomInset,
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        boxShadow: context.isDark
            ? const []
            : [
                BoxShadow(
                  color: AppTheme.primaryDark.withValues(alpha: 0.12),
                  blurRadius: 24,
                  offset: const Offset(0, -6),
                ),
              ],
        border: context.isDark
            ? Border.all(color: context.outlineColor, width: 0.5)
            : null,
      ),
      child: Row(
        children: [
          _item(context, 0, AppIcons.overview, AppIcons.overview,
              context.l10n.overview),
          _item(context, 1, AppIcons.transactions, AppIcons.transactions,
              context.l10n.transactions),
          const Expanded(child: SizedBox.shrink()),
          _item(context, 2, AppIcons.categories, AppIcons.categories,
              context.l10n.categories),
          _item(context, 3, AppIcons.wallet,
              AppIcons.wallet, context.l10n.wallet),
        ],
      ),
    );
  }

  Widget _item(
    BuildContext context,
    int index,
    AppIconData icon,
    AppIconData selectedIcon,
    String label,
  ) {
    final selected = index == currentIndex;
    final color = selected ? AppTheme.primary : context.textSecondary;
    return Expanded(
      child: InkResponse(
        onTap: () => onTap(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
              decoration: BoxDecoration(
                color: selected
                    ? AppTheme.primary.withValues(alpha: 0.14)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: AppIcon(selected ? selectedIcon : icon, color: color),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddNavButton extends StatelessWidget {
  const AddNavButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: CustomBottomNav.buttonSize,
      height: CustomBottomNav.buttonSize,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: context.backgroundColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppTheme.accent.withValues(alpha: 0.45),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: Ink(
          decoration: const ShapeDecoration(
            shape: CircleBorder(),
            gradient: AppTheme.accentGradient,
          ),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onPressed,
            child: const Center(
              child: AppIcon(AppIcons.add, color: Colors.white, size: 36),
            ),
          ),
        ),
      ),
    );
  }
}

class AddNavButtonLocation extends FloatingActionButtonLocation {
  const AddNavButtonLocation();

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry geometry) {
    final x =
        (geometry.scaffoldSize.width - geometry.floatingActionButtonSize.width) /
        2;
    final navTop =
        geometry.scaffoldSize.height -
        CustomBottomNav.barHeight -
        geometry.minViewPadding.bottom;
    return Offset(x, navTop - CustomBottomNav.protrusion);
  }
}
