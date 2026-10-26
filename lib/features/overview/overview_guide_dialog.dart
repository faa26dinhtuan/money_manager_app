import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:money_manager_app/core/extensions/l10n_extensions.dart';
import 'package:money_manager_app/core/theme/app_theme.dart';
import 'package:money_manager_app/core/widgets/app_icon.dart';
import 'package:money_manager_app/core/widgets/custom_bottom_nav.dart';

class OverviewGuideTargets {
  OverviewGuideTargets._();

  static final wallet = GlobalKey();
  static final balance = GlobalKey();
  static final type = GlobalKey();
  static final period = GlobalKey();
  static final chart = GlobalKey();
  static final transactions = GlobalKey();
  static final settings = GlobalKey();
  static final addTransaction = GlobalKey();
}

Future<void> showOverviewGuideDialog(BuildContext context) {
  final l = context.l10n;
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierLabel: l.skipGuide,
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 180),
    pageBuilder: (context, _, _) => const _OverviewGuideOverlay(),
    transitionBuilder: (context, animation, _, child) => FadeTransition(
      opacity: animation,
      child: child,
    ),
  );
}

class _OverviewGuideOverlay extends StatefulWidget {
  const _OverviewGuideOverlay();

  @override
  State<_OverviewGuideOverlay> createState() => _OverviewGuideOverlayState();
}

class _OverviewGuideOverlayState extends State<_OverviewGuideOverlay> {
  int _index = 0;
  int _measureAttempts = 0;
  bool _started = false;
  Rect? _targetRect;

  List<_OverviewGuideStep> _steps(BuildContext context) {
    final l = context.l10n;
    return [
      _OverviewGuideStep(
        target: OverviewGuideTargets.wallet,
        icon: AppIcons.wallet,
        title: l.overviewGuideWalletTitle,
        description: l.overviewGuideWalletDescription,
      ),
      _OverviewGuideStep(
        target: OverviewGuideTargets.balance,
        materialIcon: Icons.visibility_outlined,
        title: l.overviewGuideBalanceTitle,
        description: l.overviewGuideBalanceDescription,
      ),
      _OverviewGuideStep(
        target: OverviewGuideTargets.type,
        icon: AppIcons.transactions,
        title: l.overviewGuideTypeTitle,
        description: l.overviewGuideTypeDescription,
      ),
      _OverviewGuideStep(
        target: OverviewGuideTargets.period,
        icon: AppIcons.calendar,
        title: l.overviewGuidePeriodTitle,
        description: l.overviewGuidePeriodDescription,
      ),
      _OverviewGuideStep(
        target: OverviewGuideTargets.chart,
        materialIcon: Icons.pie_chart_outline,
        title: l.overviewGuideChartTitle,
        description: l.overviewGuideChartDescription,
      ),
      _OverviewGuideStep(
        target: OverviewGuideTargets.transactions,
        icon: AppIcons.transactions,
        title: l.overviewGuideTransactionsTitle,
        description: l.overviewGuideTransactionsDescription,
      ),
      _OverviewGuideStep(
        target: OverviewGuideTargets.settings,
        icon: AppIcons.settings,
        title: l.overviewGuideSettingsTitle,
        description: l.overviewGuideSettingsDescription,
      ),
      _OverviewGuideStep(
        target: OverviewGuideTargets.addTransaction,
        icon: AppIcons.add,
        title: l.overviewGuideAddTitle,
        description: l.overviewGuideAddDescription,
      ),
    ];
  }

  void _startSteps() {
    setState(() => _started = true);
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusCurrentTarget());
  }

  Future<void> _focusCurrentTarget() async {
    if (!mounted) return;
    final targetContext = _steps(context)[_index].target.currentContext;
    if (targetContext == null) {
      _measureTarget();
      return;
    }
    await Scrollable.ensureVisible(
      targetContext,
      duration: const Duration(milliseconds: 240),
      alignment: 0.35,
    );
    if (mounted) _measureTarget();
  }

  Rect? _rectFor(GlobalKey key) {
    final renderObject = key.currentContext?.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) return null;
    final rect = renderObject.localToGlobal(Offset.zero) & renderObject.size;
    return rect.intersect(Offset.zero & MediaQuery.sizeOf(context));
  }

  void _measureTarget() {
    if (!mounted) return;
    final rect = _rectFor(_steps(context)[_index].target);
    if (rect == null || rect.isEmpty) {
      if (_measureAttempts < 4) {
        _measureAttempts++;
        WidgetsBinding.instance.addPostFrameCallback((_) => _measureTarget());
      }
      return;
    }
    _measureAttempts = 0;
    setState(() => _targetRect = rect);
  }

  void _nextStep() {
    final steps = _steps(context);
    if (_index == steps.length - 1) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _index++;
      _measureAttempts = 0;
      _targetRect = null;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusCurrentTarget());
  }

  double _bubbleTop(Size size, EdgeInsets padding, Rect target) {
    const bubbleHeight = 230.0;
    final topLimit = padding.top + 12;
    final bottomLimit = size.height -
        padding.bottom -
        CustomBottomNav.barHeight -
        CustomBottomNav.protrusion -
        12;
    final maximum = math.max(topLimit, bottomLimit - bubbleHeight);
    final preferred = target.center.dy < size.height * 0.5
        ? target.bottom + 22
        : target.top - bubbleHeight - 22;
    return preferred.clamp(topLimit, maximum).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final steps = _steps(context);
    final step = steps[_index];
    final target = _targetRect;
    final media = MediaQuery.of(context);

    return Material(
      type: MaterialType.transparency,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);
          final safeTarget = target ?? Rect.fromCenter(
            center: Offset(size.width / 2, size.height / 2),
            width: 64,
            height: 64,
          );
          final top = _bubbleTop(size, media.padding, safeTarget);
          final bubbleRect = Rect.fromLTWH(
            16,
            top,
            size.width - 32,
            math
                .min(230.0, size.height - top - media.padding.bottom - 12)
                .toDouble(),
          );

          return Stack(
            children: [
              if (_started) ...[
                Positioned.fill(
                  child: CustomPaint(
                    painter: _SpotlightPainter(
                      target: target,
                      bubble: bubbleRect,
                    ),
                  ),
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  top: top,
                  child: _OverviewGuideCallout(
                    step: step,
                    index: _index,
                    count: steps.length,
                    onNext: _nextStep,
                    onSkip: () => Navigator.of(context).pop(),
                  ),
                ),
              ] else
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: media.padding.bottom +
                      CustomBottomNav.barHeight +
                      CustomBottomNav.protrusion +
                      12,
                  child: _OverviewGuideIntro(
                    onStart: _startSteps,
                    onSkip: () => Navigator.of(context).pop(),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _OverviewGuideIntro extends StatelessWidget {
  const _OverviewGuideIntro({required this.onStart, required this.onSkip});

  final VoidCallback onStart;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.primary.withValues(alpha: 0.32)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.24),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.overviewGuideTitle,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(l.overviewGuideIntro),
            const SizedBox(height: 8),
            Row(
              children: [
                const Spacer(),
                TextButton(onPressed: onSkip, child: Text(l.skipGuide)),
                const SizedBox(width: 4),
                FilledButton(onPressed: onStart, child: Text(l.continueText)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OverviewGuideStep {
  const _OverviewGuideStep({
    required this.target,
    required this.title,
    required this.description,
    this.icon,
    this.materialIcon,
  });

  final GlobalKey target;
  final AppIconData? icon;
  final IconData? materialIcon;
  final String title;
  final String description;
}

class _OverviewGuideCallout extends StatelessWidget {
  const _OverviewGuideCallout({
    required this.step,
    required this.index,
    required this.count,
    required this.onNext,
    required this.onSkip,
  });

  final _OverviewGuideStep step;
  final int index;
  final int count;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final isLast = index == count - 1;

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.primary.withValues(alpha: 0.32)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.24),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: step.materialIcon != null
                        ? Icon(step.materialIcon, color: AppTheme.primary, size: 22)
                        : AppIcon(step.icon!, color: AppTheme.primary, size: 22),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    step.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              step.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                for (var i = 0; i < count; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.only(right: 4),
                    width: i == index ? 14 : 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: i == index
                          ? AppTheme.primary
                          : AppTheme.primary.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                const Spacer(),
                TextButton(onPressed: onSkip, child: Text(l.skipGuide)),
                const SizedBox(width: 4),
                FilledButton(
                  onPressed: onNext,
                  child: Text(isLast ? l.done : l.continueText),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SpotlightPainter extends CustomPainter {
  const _SpotlightPainter({required this.target, required this.bubble});

  final Rect? target;
  final Rect bubble;

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    canvas.saveLayer(bounds, Paint());
    canvas.drawRect(
      bounds,
      Paint()..color = Colors.black.withValues(alpha: 0.76),
    );
    final targetRect = target;
    if (targetRect != null && !targetRect.isEmpty) {
      final spotlight = RRect.fromRectAndRadius(
        targetRect.inflate(8),
        const Radius.circular(18),
      );
      canvas.drawRRect(spotlight, Paint()..blendMode = BlendMode.clear);
    }
    canvas.restore();
    if (targetRect == null || targetRect.isEmpty) return;

    final spotlightRect = targetRect.inflate(8);
    canvas.drawRRect(
      RRect.fromRectAndRadius(spotlightRect, const Radius.circular(18)),
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    final placeBelow = bubble.top >= spotlightRect.bottom;
    final start = Offset(
      spotlightRect.center.dx,
      placeBelow ? spotlightRect.bottom : spotlightRect.top,
    );
    final end = Offset(
      start.dx.clamp(bubble.left + 24, bubble.right - 24).toDouble(),
      placeBelow ? bubble.top : bubble.bottom,
    );
    canvas.drawLine(
      start,
      end,
      Paint()
        ..color = Colors.white
        ..strokeWidth = 2,
    );
    canvas.drawCircle(start, 3, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(_SpotlightPainter oldDelegate) =>
      oldDelegate.target != target || oldDelegate.bubble != bubble;
}
