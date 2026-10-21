import 'package:flutter/material.dart';
import 'package:money_manager_app/core/widgets/app_icon.dart';
import 'package:money_manager_app/core/theme/app_colors.dart';
import 'package:money_manager_app/core/theme/app_theme.dart';
import 'package:money_manager_app/core/utils/constants.dart';

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
        border: Border(
          top: BorderSide(color: context.outlineColor, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          _item(context, 0, AppIcons.overview, AppIcons.overview,
              AppConstants.tabOverview),
          _item(context, 1, AppIcons.transactions, AppIcons.transactions,
              AppConstants.tabTransactions),
          const Expanded(child: SizedBox.shrink()),
          _item(context, 2, AppIcons.categories, AppIcons.categories,
              AppConstants.tabCategories),
          _item(context, 3, AppIcons.wallet,
              AppIcons.wallet, AppConstants.tabWallet),
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
            AppIcon(selected ? selectedIcon : icon, color: color),
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
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: AppTheme.accent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: const AppIcon(AppIcons.add, color: Colors.white, size: 36),
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
