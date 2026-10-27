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
  static final balanceLabel = GlobalKey();
  static final type = GlobalKey();
  static final period = GlobalKey();
  static final chart = GlobalKey();
  static final transactions = GlobalKey();
  static final navigation = GlobalKey();
  static final navigationOverview = GlobalKey();
  static final navigationTransactions = GlobalKey();
  static final navigationCalendar = GlobalKey();
  static final navigationWallet = GlobalKey();
  static final settings = GlobalKey();
  static final addTransaction = GlobalKey();
}

class OverviewGuideController extends ChangeNotifier {
  bool active = true;
  bool started = false;
  bool interacted = false;
  int step = 0;

  void start() {
    started = true;
    notifyListeners();
  }

  void markInteraction(int targetStep) {
    if (!active || !started || step != targetStep || interacted) return;
    interacted = true;
    notifyListeners();
  }

  void next() {
    if (!active || !started || (!interacted && step != 5)) return;
    if (step == 5) {
      active = false;
    } else {
      step++;
      interacted = false;
    }
    notifyListeners();
  }

  void skip() {
    active = false;
    notifyListeners();
  }
}

class OverviewGuideOverlay extends StatefulWidget {
  const OverviewGuideOverlay({super.key, required this.controller});

  final OverviewGuideController controller;

  @override
  State<OverviewGuideOverlay> createState() => _OverviewGuideOverlayState();
}

class _OverviewGuideOverlayState extends State<OverviewGuideOverlay> {
  List<Rect> _targetRects = [];
  int _lastStep = -1;
  bool _lastStarted = false;

  List<_OverviewGuideStep> _steps(BuildContext context) {
    final l = context.l10n;
    return [
      _OverviewGuideStep(
        targets: [OverviewGuideTargets.wallet],
        icon: AppIcons.wallet,
        title: l.overviewGuideWalletTitle,
        description: l.overviewGuideWalletDescription,
      ),
      _OverviewGuideStep(
        targets: [
          OverviewGuideTargets.balanceLabel,
          OverviewGuideTargets.balance,
        ],
        materialIcon: Icons.visibility_outlined,
        title: l.overviewGuideBalanceTitle,
        description: l.overviewGuideBalanceDescription,
      ),
      _OverviewGuideStep(
        targets: [OverviewGuideTargets.type, OverviewGuideTargets.chart],
        icon: AppIcons.transactions,
        title: l.overviewGuideTypeTitle,
        description: l.overviewGuideTypeDescription,
      ),
      _OverviewGuideStep(
        targets: [
          OverviewGuideTargets.period,
          OverviewGuideTargets.chart,
          OverviewGuideTargets.transactions,
        ],
        icon: AppIcons.calendar,
        title: l.overviewGuidePeriodTitle,
        description: l.overviewGuidePeriodDescription,
      ),
      _OverviewGuideStep(
        targets: [OverviewGuideTargets.transactions],
        icon: AppIcons.transactions,
        title: l.overviewGuideTransactionsTitle,
        description: l.overviewGuideTransactionsDescription,
      ),
      _OverviewGuideStep(
        targets: [
          OverviewGuideTargets.navigationOverview,
          OverviewGuideTargets.navigationTransactions,
          OverviewGuideTargets.navigationCalendar,
          OverviewGuideTargets.navigationWallet,
          OverviewGuideTargets.addTransaction,
        ],
        materialIcon: Icons.dashboard_outlined,
        title: l.overviewGuideNavigationTitle,
        description: l.overviewGuideNavigationDescription,
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(covariant OverviewGuideOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerChanged);
      widget.controller.addListener(_onControllerChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    if (!mounted) return;
    final controller = widget.controller;
    final shouldRefocus = controller.started &&
        (controller.step != _lastStep || !_lastStarted);
    _lastStep = controller.step;
    _lastStarted = controller.started;
    setState(() {});
    if (controller.started) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (shouldRefocus) {
          _focusCurrentTarget();
        } else {
          _measureTarget();
        }
      });
    }
  }

  Future<void> _focusCurrentTarget() async {
    if (!mounted || !widget.controller.active || !widget.controller.started) return;
    final targetContext =
        _steps(context)[widget.controller.step].targets.last.currentContext;
    if (targetContext == null) {
      _measureTarget();
      return;
    }
    await Scrollable.ensureVisible(
      targetContext,
      duration: const Duration(milliseconds: 220),
      alignment: 0.35,
    );
    if (mounted) _measureTarget();
  }

  void _measureTarget() {
    if (!mounted) return;
    final overlayObject = context.findRenderObject();
    if (overlayObject is! RenderBox || !overlayObject.hasSize) {
      return;
    }
    final origin = overlayObject.localToGlobal(Offset.zero);
    final next = <Rect>[];
    for (final key in _steps(context)[widget.controller.step].targets) {
      final object = key.currentContext?.findRenderObject();
      if (object is! RenderBox || !object.hasSize) continue;
      final global = object.localToGlobal(Offset.zero) & object.size;
      var rect = global.shift(-origin).intersect(Offset.zero & overlayObject.size);
      if (widget.controller.step == 0 && identical(key, OverviewGuideTargets.wallet)) {
        rect = Rect.fromLTRB(
          math.min(rect.right, rect.left + 12),
          rect.top,
          rect.right,
          rect.bottom,
        );
      }
      if (!rect.isEmpty) next.add(rect);
    }
    if (widget.controller.step == 1 && next.length > 1) {
      final combined = next.reduce((a, b) => Rect.fromLTRB(
            math.min(a.left, b.left),
            math.min(a.top, b.top),
            math.max(a.right, b.right),
            math.max(a.bottom, b.bottom),
          ));
      next
        ..clear()
        ..add(combined);
    }
    if (next.length == _targetRects.length &&
        List.generate(next.length, (index) => next[index] == _targetRects[index])
            .every((matches) => matches)) {
      return;
    }
    setState(() => _targetRects = next);
  }

  double _bubbleTop(Size size, EdgeInsets padding, Rect target) {
    const bubbleHeight = 190.0;
    final topLimit = padding.top + 12;
    final maximum = math.max(topLimit, size.height - bubbleHeight - 16);
    final preferred = target.center.dy < size.height * 0.5
        ? target.bottom + 20
        : target.top - bubbleHeight - 20;
    return preferred.clamp(topLimit, maximum).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        if (!widget.controller.active) return const SizedBox.shrink();
        final steps = _steps(context);
        final step = steps[widget.controller.step];
        final media = MediaQuery.of(context);
        return LayoutBuilder(
          builder: (context, constraints) {
            final size = Size(constraints.maxWidth, constraints.maxHeight);
            final targets = widget.controller.started ? _targetRects : <Rect>[];
            final anchor = targets.isNotEmpty ? targets.first : Rect.fromCenter(
              center: Offset(size.width / 2, size.height / 2),
              width: 64,
              height: 64,
            );
            final bottomAnchoredStep = widget.controller.step == 1 ||
                widget.controller.step == 2;
            final top = widget.controller.step == 3
                ? media.padding.top + 12
                : bottomAnchoredStep
                ? math.max(
                    media.padding.top + 12,
                    size.height - media.padding.bottom - 202.0,
                  ).toDouble()
                : _bubbleTop(size, media.padding, anchor);
            return Stack(
              children: [
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _OverviewSpotlightPainter(
                        targets: targets,
                        step: widget.controller.step,
                      ),
                    ),
                  ),
                ),
                if (!widget.controller.started)
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: media.padding.bottom +
                        CustomBottomNav.barHeight +
                        CustomBottomNav.protrusion +
                        12,
                    child: _OverviewGuideIntro(
                      onStart: widget.controller.start,
                      onSkip: widget.controller.skip,
                    ),
                  )
                else
                  Positioned(
                    left: 16,
                    right: 16,
                    top: top,
                    child: _OverviewGuideCallout(
                      step: step,
                      index: widget.controller.step,
                      count: steps.length,
                      interacted: widget.controller.interacted || widget.controller.step == 5,
                      onNext: widget.controller.next,
                      onSkip: widget.controller.skip,
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

class _OverviewGuideStep {
  const _OverviewGuideStep({
    required this.targets,
    required this.title,
    required this.description,
    this.icon,
    this.materialIcon,
  });

  final List<GlobalKey> targets;
  final AppIconData? icon;
  final IconData? materialIcon;
  final String title;
  final String description;
}

class _OverviewGuideIntro extends StatelessWidget {
  const _OverviewGuideIntro({required this.onStart, required this.onSkip});

  final VoidCallback onStart;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return _GuideCard(
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
          const SizedBox(height: 10),
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
    );
  }
}

class _OverviewGuideCallout extends StatelessWidget {
  const _OverviewGuideCallout({
    required this.step,
    required this.index,
    required this.count,
    required this.interacted,
    required this.onNext,
    required this.onSkip,
  });

  final _OverviewGuideStep step;
  final int index;
  final int count;
  final bool interacted;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return _GuideCard(
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
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(step.description),
          const SizedBox(height: 8),
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
                onPressed: interacted ? onNext : null,
                child: Text(index == count - 1 ? l.done : l.continueText),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GuideCard extends StatelessWidget {
  const _GuideCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
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
        child: child,
      ),
    );
  }
}

class _OverviewSpotlightPainter extends CustomPainter {
  const _OverviewSpotlightPainter({required this.targets, required this.step});

  final List<Rect> targets;
  final int step;

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    canvas.saveLayer(bounds, Paint());
    canvas.drawRect(bounds, Paint()..color = Colors.black.withValues(alpha: 0.76));
    for (final targetRect in targets) {
      final spotlight = targetRect.inflate(step == 9 ? 2 : 4);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          spotlight,
          Radius.circular(step == 9 ? spotlight.width / 2 : 18),
        ),
        Paint()..blendMode = BlendMode.clear,
      );
    }
    canvas.restore();
    if (targets.isEmpty) return;
    for (var index = 0; index < targets.length; index++) {
      final spotlight = targets[index].inflate(step == 9 ? 2 : 4);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          spotlight,
          Radius.circular(step == 9 ? spotlight.width / 2 : 18),
        ),
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  @override
  bool shouldRepaint(_OverviewSpotlightPainter oldDelegate) =>
      oldDelegate.targets != targets || oldDelegate.step != step;
}


