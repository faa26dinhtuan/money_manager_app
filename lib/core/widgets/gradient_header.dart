import 'package:flutter/material.dart';
import 'package:money_manager_app/core/theme/app_colors.dart';
import 'package:money_manager_app/core/theme/app_theme.dart';

class GradientHeader extends StatelessWidget {
  const GradientHeader({super.key, required this.child, this.bottomRadius = 30});

  final Widget child;
  final double bottomRadius;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.vertical(bottom: Radius.circular(bottomRadius));
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryDark.withValues(alpha: context.isDark ? 0.28 : 0.18),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: DecoratedBox(
          decoration: BoxDecoration(gradient: context.headerGradient),
          child: Stack(
            children: [
              const Positioned(top: -64, right: -40, child: _Bubble(188, 0.09)),
              const Positioned(bottom: -56, left: -48, child: _Bubble(156, 0.07)),
              const Positioned(top: 76, left: -20, child: _Bubble(72, 0.055)),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble(this.size, this.alpha);

  final double size;
  final double alpha;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: alpha),
        ),
      ),
    );
  }
}
