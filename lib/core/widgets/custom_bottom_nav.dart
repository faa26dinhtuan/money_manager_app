import 'package:flutter/material.dart';
import 'package:money_manager_app/core/extensions/l10n_extensions.dart';
import 'package:money_manager_app/core/theme/app_colors.dart';
import 'package:money_manager_app/core/theme/app_theme.dart';
import 'package:money_manager_app/core/widgets/app_icon.dart';

class CustomBottomNav extends StatelessWidget {
  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const double barHeight = 66;
  static const double buttonSize = 66;
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
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryDark.withValues(alpha: context.isDark ? 0.12 : 0.09),
            blurRadius: 24,
            offset: const Offset(0, -7),
          ),
        ],
        border: Border(
          top: BorderSide(color: context.outlineColor.withValues(alpha: 0.8), width: 0.65),
        ),
      ),
      child: Row(
        children: [
          _item(context, 0, AppIcons.overview, context.l10n.overview),
          _item(context, 1, AppIcons.transactions, context.l10n.transactions),
          const Expanded(child: SizedBox.shrink()),
          _item(context, 2, AppIcons.calendar, context.l10n.calendar),
          _item(context, 3, AppIcons.wallet, context.l10n.wallet),
        ],
      ),
    );
  }

  Widget _item(
    BuildContext context,
    int index,
    AppIconData icon,
    String label,
  ) {
    final selected = index == currentIndex;
    final selectedColor = context.isDark ? AppTheme.primaryLight : AppTheme.primary;
    final color = selected ? selectedColor : context.textSecondary;
    return Expanded(
      child: InkResponse(
        radius: 34,
        onTap: () => onTap(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 5),
              decoration: BoxDecoration(
                color: selected ? selectedColor.withValues(alpha: 0.13) : Colors.transparent,
                borderRadius: BorderRadius.circular(17),
              ),
              child: AnimatedScale(
                duration: const Duration(milliseconds: 220),
                scale: selected ? 1.04 : 1,
                child: AppIcon(icon, color: color, size: 22),
              ),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 180),
              style: TextStyle(
                fontSize: 10.5,
                height: 1.15,
                color: color,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
              child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
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
            color: AppTheme.accent.withValues(alpha: 0.36),
            blurRadius: 20,
            offset: const Offset(0, 7),
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
              child: AppIcon(AppIcons.add, color: AppTheme.primaryDeep, size: 32),
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
