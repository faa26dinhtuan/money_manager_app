import 'dart:math' as math;
import 'package:flutter/material.dart';

class DonutSlice {
  const DonutSlice(this.value, this.color);
  final double value;
  final Color color;
}

/// Biểu đồ tròn (donut) tự vẽ, không cần thư viện ngoài.
class DonutChart extends StatelessWidget {
  const DonutChart({
    super.key,
    required this.slices,
    this.size = 220,
    this.thickness = 28,
    this.center,
  });

  final List<DonutSlice> slices;
  final double size;
  final double thickness;
  final Widget? center;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _DonutPainter(slices, thickness),
        child: Center(child: center),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter(this.slices, this.thickness);

  final List<DonutSlice> slices;
  final double thickness;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      thickness / 2,
      thickness / 2,
      size.width - thickness,
      size.height - thickness,
    );
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness;

    final total = slices.fold<double>(0, (s, e) => s + e.value);
    if (total <= 0) {
      paint.color = Colors.black12;
      canvas.drawArc(rect, 0, 2 * math.pi, false, paint);
      return;
    }

    final gap = slices.length > 1 ? 0.04 : 0.0;
    var start = -math.pi / 2;
    for (final s in slices) {
      final sweep = s.value / total * 2 * math.pi;
      paint.color = s.color;
      canvas.drawArc(
        rect,
        start + gap / 2,
        math.max(sweep - gap, 0.001),
        false,
        paint,
      );
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) =>
      old.slices != slices || old.thickness != thickness;
}
