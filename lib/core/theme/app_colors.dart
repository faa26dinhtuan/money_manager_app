import 'package:flutter/material.dart';
import 'package:money_manager_app/core/theme/app_theme.dart';

extension AppColors on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  Color get surfaceColor => isDark ? AppTheme.darkSurface : AppTheme.lightSurface;

  Color get backgroundColor => isDark ? AppTheme.darkBackground : AppTheme.background;

  Color get textPrimary => isDark
      ? const Color(0xFFF1F6F2)
      : const Color(0xFF18251E);

  Color get textSecondary => isDark
      ? const Color(0xFFA2B5A9)
      : const Color(0xFF66766C);

  Color get textTertiary => isDark
      ? const Color(0xFF82968A)
      : const Color(0xFF819087);

  Color get textDisabled => isDark
      ? const Color(0xFF56685D)
      : const Color(0xFFB2BDB5);

  Color get outlineColor => isDark ? AppTheme.darkOutline : AppTheme.lightOutline;

  Color get positiveColor => isDark ? AppTheme.primaryLight : AppTheme.success;

  Color get negativeColor => AppTheme.danger;

  LinearGradient get headerGradient =>
      isDark ? AppTheme.headerGradientDark : AppTheme.headerGradient;

  LinearGradient get surfaceGradient => isDark
      ? const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.darkSurfaceRaised, AppTheme.darkSurface],
        )
      : const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.lightSurface, AppTheme.lightSurfaceTint],
        );

  List<BoxShadow> get softShadow => [
    BoxShadow(
      color: AppTheme.primaryDark.withValues(alpha: isDark ? 0.08 : 0.075),
      blurRadius: isDark ? 18 : 24,
      offset: const Offset(0, 8),
    ),
  ];

  BoxDecoration cardDecoration({double radius = 20}) => BoxDecoration(
    gradient: surfaceGradient,
    borderRadius: BorderRadius.circular(radius),
    boxShadow: softShadow,
    border: Border.all(color: outlineColor.withValues(alpha: 0.72), width: 0.65),
  );
}
