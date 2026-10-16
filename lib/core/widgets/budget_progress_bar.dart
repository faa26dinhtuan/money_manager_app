import 'package:flutter/material.dart';

class BudgetProgressBar extends StatelessWidget {
  const BudgetProgressBar({
    super.key,
    required this.value,
    required this.color,
    this.backgroundColor,
    this.height = 8,
  });

  final double value;
  final Color color;
  final Color? backgroundColor;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: LinearProgressIndicator(
        value: value.clamp(0.0, 1.0),
        minHeight: height,
        color: color,
        backgroundColor: backgroundColor ?? color.withValues(alpha: 0.15),
      ),
    );
  }
}
