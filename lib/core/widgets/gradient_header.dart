import 'package:flutter/material.dart';
import 'package:money_manager_app/core/theme/app_colors.dart';
import 'package:money_manager_app/core/theme/app_theme.dart';

class GradientHeader extends StatelessWidget {
  const GradientHeader({super.key, required this.child, this.bottomRadius = 32});

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
            color: AppTheme.primary.withValues(alpha: 0.30),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: DecoratedBox(
          decoration: BoxDecoration(gradient: context.headerGradient),
          child: Stack(
            children: [
              const Positioned(top: -60, right: -40, child: _Bubble(180, 0.08)),
              const Positioned(
                bottom: -50,
                left: -50,
                child: _Bubble(150, 0.06),
              ),
              const Positioned(top: 70, left: -20, child: _Bubble(70, 0.05)),
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
