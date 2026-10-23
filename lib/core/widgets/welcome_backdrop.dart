import 'package:flutter/material.dart';
import 'package:money_manager_app/core/theme/app_theme.dart';

class WelcomeBackdrop extends StatelessWidget {
  const WelcomeBackdrop({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(decoration: BoxDecoration(gradient: AppTheme.primaryGradient)),
        Positioned(
          top: -150,
          right: -105,
          child: _Glow(size: 340, color: AppTheme.primaryLight.withValues(alpha: 0.24)),
        ),
        Positioned(
          left: -160,
          bottom: 80,
          child: _Glow(size: 360, color: AppTheme.accent.withValues(alpha: 0.12)),
        ),
        Positioned(
          top: 92,
          left: 24,
          child: Transform.rotate(
            angle: -0.28,
            child: Container(
              width: 66,
              height: 66,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.white.withValues(alpha: 0.11), width: 1.4),
              ),
            ),
          ),
        ),
        Positioned(
          right: 28,
          bottom: 150,
          child: Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(
              color: AppTheme.accent.withValues(alpha: 0.8),
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: AppTheme.accent.withValues(alpha: 0.42), blurRadius: 16, spreadRadius: 4)],
            ),
          ),
        ),
        Positioned.fill(child: child),
      ],
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withValues(alpha: 0)],
          ),
        ),
      ),
    );
  }
}
