import 'package:flutter/material.dart';
import 'package:money_manager_app/core/theme/app_theme.dart';

extension AppColors on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  Color get surfaceColor => isDark ? AppTheme.darkSurface : Colors.white;

  Color get backgroundColor =>
      isDark ? AppTheme.darkBackground : AppTheme.background;

  Color get textPrimary =>
      isDark ? Colors.white.withValues(alpha: 0.87) : Colors.black87;

  Color get textSecondary => isDark ? Colors.white70 : Colors.black54;

  Color get textTertiary => isDark ? Colors.white54 : Colors.black45;

  Color get textDisabled => isDark ? Colors.white30 : Colors.black26;

  Color get outlineColor => isDark ? Colors.white12 : Colors.black12;

  LinearGradient get headerGradient =>
      isDark ? AppTheme.headerGradientDark : AppTheme.headerGradient;

  List<BoxShadow> get softShadow => isDark
      ? const []
      : [
          BoxShadow(
            color: AppTheme.primaryDark.withValues(alpha: 0.10),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ];

  BoxDecoration cardDecoration({double radius = 20}) => BoxDecoration(
    color: surfaceColor,
    borderRadius: BorderRadius.circular(radius),
    boxShadow: softShadow,
    border: isDark ? Border.all(color: outlineColor, width: 0.5) : null,
  );
}
