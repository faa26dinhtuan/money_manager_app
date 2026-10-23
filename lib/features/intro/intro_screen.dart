import 'package:flutter/material.dart';
import 'package:money_manager_app/core/widgets/app_icon.dart';
import 'package:money_manager_app/core/extensions/l10n_extensions.dart';
import 'package:money_manager_app/core/theme/app_theme.dart';
import 'package:money_manager_app/core/widgets/welcome_icon_tile.dart';
import 'package:money_manager_app/core/widgets/welcome_backdrop.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key, required this.next});

  final Widget next;

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goNext() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, _, _) => widget.next,
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  void _onContinue(int total) {
    if (_index == total - 1) {
      _goNext();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final pages = [
      _IntroPage(
        icon: AppIcons.overview,
        title: l.introTrackTitle,
        description: l.introTrackDesc,
      ),
      _IntroPage(
        icon: AppIcons.wallet,
        title: l.introWalletTitle,
        description: l.introWalletDesc,
      ),
      _IntroPage(
        icon: AppIcons.budget,
        title: l.introBudgetTitle,
        description: l.introBudgetDesc,
      ),
      _IntroPage(
        icon: AppIcons.repeat,
        title: l.introRecurringTitle,
        description: l.introRecurringDesc,
      ),
    ];
    final isLast = _index == pages.length - 1;

    return Scaffold(
      backgroundColor: AppTheme.primaryDeep,
      body: WelcomeBackdrop(
        child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: pages.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (_, i) => _PageContent(page: pages[i]),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < pages.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == _index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == _index ? Colors.white : Colors.white38,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.accent,
                    foregroundColor: AppTheme.primaryDeep,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                  ),
                  onPressed: () => _onContinue(pages.length),
                  child: Text(
                    isLast ? l.start : l.continueText,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}

class _IntroPage {
  const _IntroPage({
    required this.icon,
    required this.title,
    required this.description,
  });

  final AppIconData icon;
  final String title;
  final String description;
}

class _PageContent extends StatelessWidget {
  const _PageContent({required this.page});

  final _IntroPage page;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _IntroArtwork(icon: page.icon),
          const SizedBox(height: 34),
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            page.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _IntroArtwork extends StatelessWidget {
  const _IntroArtwork({required this.icon});

  final AppIconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      height: 230,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 194,
            height: 194,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.23),
                  Colors.white.withValues(alpha: 0.02),
                ],
              ),
              border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
            ),
          ),
          Positioned(
            top: 4,
            right: 12,
            child: _FloatingIcon(icon: AppIcons.trendingUp, size: 48),
          ),
          Positioned(
            bottom: 6,
            left: 8,
            child: _FloatingIcon(icon: AppIcons.exchange, size: 42),
          ),
          Positioned(
            top: 50,
            left: 4,
            child: Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: AppTheme.accent,
                shape: BoxShape.circle,
              ),
            ),
          ),
          WelcomeIconTile(
            icon: icon,
            size: 142,
            iconSize: 76,
            radius: 42,
          ),
        ],
      ),
    );
  }
}

class _FloatingIcon extends StatelessWidget {
  const _FloatingIcon({required this.icon, required this.size});

  final AppIconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryDeep.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: AppIcon(icon, color: Colors.white, size: size * 0.46),
    );
  }
}
