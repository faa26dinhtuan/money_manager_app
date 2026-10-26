import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:money_manager_app/core/theme/app_colors.dart';

class DonutSlice {
  const DonutSlice(this.value, this.color);
  final double value;
  final Color color;
}

class DonutChart extends StatefulWidget {
  const DonutChart({
    super.key,
    required this.slices,
    this.size = 220,
    this.thickness = 28,
    this.center,
    this.showLabels = false,
    this.interactive = false,
    this.onInteraction,
  });

  final List<DonutSlice> slices;
  final double size;
  final double thickness;
  final Widget? center;
  final bool showLabels;
  final bool interactive;
  final VoidCallback? onInteraction;

  @override
  State<DonutChart> createState() => _DonutChartState();
}

class _DonutChartState extends State<DonutChart> {
  static const double _lift = 6;
  int _touched = -1;

  Color _lighten(Color c) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness + 0.12).clamp(0.0, 1.0)).toColor();
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.slices.fold<double>(0, (s, e) => s + e.value);
    final empty = total <= 0;
    final pad = widget.interactive ? _lift : 0.0;
    final sections = <PieChartSectionData>[];

    if (empty) {
      sections.add(
        PieChartSectionData(
          value: 1,
          color: context.outlineColor,
          radius: widget.thickness,
          showTitle: false,
        ),
      );
    } else {
      for (var i = 0; i < widget.slices.length; i++) {
        final s = widget.slices[i];
        final percent = s.value / total * 100;
        final touched = i == _touched;
        sections.add(
          PieChartSectionData(
            value: s.value,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_lighten(s.color), s.color],
            ),
            radius: widget.thickness + (touched ? _lift : 0),
            showTitle: widget.showLabels && percent >= 7,
            title: '${percent.round()}%',
            titlePositionPercentageOffset: 0.5,
            titleStyle: TextStyle(
              color: Colors.white,
              fontSize: touched ? 15 : 12,
              fontWeight: FontWeight.w700,
            ),
            borderSide: BorderSide.none,
          ),
        );
      }
    }

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: widget.size / 2 - widget.thickness - pad,
              sectionsSpace: empty || widget.slices.length < 2 ? 0 : 3,
              startDegreeOffset: -90,
              borderData: FlBorderData(show: false),
              pieTouchData: PieTouchData(
                enabled: widget.interactive && !empty,
                touchCallback: (event, response) {
                  final index = response?.touchedSection?.touchedSectionIndex;
                  final next = !event.isInterestedForInteractions || index == null
                      ? -1
                      : index;
                  if (next != _touched) {
                    setState(() => _touched = next);
                    if (next >= 0) widget.onInteraction?.call();
                  }
                },
              ),
            ),
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
          ),
          IgnorePointer(child: widget.center),
        ],
      ),
    );
  }
}
