import 'package:flutter/material.dart';
import 'package:money_manager_app/core/theme/app_theme.dart';
import 'package:money_manager_app/core/widgets/app_icon.dart';

class WelcomeIconTile extends StatelessWidget {
  const WelcomeIconTile({
    super.key,
    required this.icon,
    required this.size,
    required this.iconSize,
    required this.radius,
  });

  final AppIconData icon;
  final double size;
  final double iconSize;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: AppIcon(icon, size: iconSize, color: AppTheme.primary),
    );
  }
}
