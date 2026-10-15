import 'package:flutter/material.dart';
import 'package:money_manager_app/core/utils/constants.dart';

/// Thanh điều hướng dưới (4 tab).
class CustomBottomNav extends StatelessWidget {
  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.donut_large_outlined),
          selectedIcon: Icon(Icons.donut_large),
          label: AppConstants.tabOverview,
        ),
        NavigationDestination(
          icon: Icon(Icons.receipt_long_outlined),
          selectedIcon: Icon(Icons.receipt_long),
          label: AppConstants.tabTransactions,
        ),
        NavigationDestination(
          icon: Icon(Icons.category_outlined),
          selectedIcon: Icon(Icons.category),
          label: AppConstants.tabCategories,
        ),
        NavigationDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings),
          label: AppConstants.tabSettings,
        ),
      ],
    );
  }
}
