import 'package:flutter/material.dart';
import 'package:money_manager_app/core/theme/app_theme.dart';
import 'package:money_manager_app/core/utils/constants.dart';

class CustomBottomNav extends StatelessWidget {
  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onAdd,
  });

  static const double _barHeight = 64;
  static const double _buttonSize = 68;
  static const double _protrusion = 20;

  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return SizedBox(
      height: _barHeight + _protrusion + bottomInset,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: _barHeight + bottomInset,
            child: Container(
              padding: EdgeInsets.only(bottom: bottomInset),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _item(0, Icons.donut_large_outlined, Icons.donut_large,
                      AppConstants.tabOverview),
                  _item(1, Icons.receipt_long_outlined, Icons.receipt_long,
                      AppConstants.tabTransactions),
                  const Expanded(child: SizedBox.shrink()),
                  _item(2, Icons.category_outlined, Icons.category,
                      AppConstants.tabCategories),
                  _item(3, Icons.account_balance_wallet_outlined,
                      Icons.account_balance_wallet, AppConstants.tabWallet),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: _AddButton(size: _buttonSize, onPressed: onAdd),
          ),
        ],
      ),
    );
  }

  Widget _item(int index, IconData icon, IconData selectedIcon, String label) {
    final selected = index == currentIndex;
    final color = selected ? AppTheme.primary : Colors.black54;
    return Expanded(
      child: InkResponse(
        onTap: () => onTap(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(selected ? selectedIcon : icon, color: color),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
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

class _AddButton extends StatelessWidget {
  const _AddButton({required this.size, required this.onPressed});

  final double size;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppTheme.background,
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
          child: const Icon(Icons.add, color: Colors.white, size: 36),
        ),
      ),
    );
  }
}
