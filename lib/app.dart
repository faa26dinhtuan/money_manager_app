import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money_manager_app/core/extensions/l10n_extensions.dart';
import 'package:money_manager_app/core/theme/app_theme.dart';
import 'package:money_manager_app/core/theme/ios_scroll_behavior.dart';
import 'package:money_manager_app/core/utils/app_snackbar.dart';
import 'package:money_manager_app/core/utils/constants.dart';
import 'package:money_manager_app/core/widgets/custom_bottom_nav.dart';
import 'package:money_manager_app/data/services/app_store.dart';
import 'package:money_manager_app/data/services/event_reminder_service.dart';
import 'package:money_manager_app/features/intro/intro_screen.dart';
import 'package:money_manager_app/features/calendar/calendar_screen.dart';
import 'package:money_manager_app/features/onboarding/onboarding_screen.dart';
import 'package:money_manager_app/features/overview/overview_screen.dart';
import 'package:money_manager_app/features/overview/overview_guide_dialog.dart';
import 'package:money_manager_app/features/splash/splash_screen.dart';
import 'package:money_manager_app/features/transactions/add_transaction_screen.dart';
import 'package:money_manager_app/features/transactions/transactions_screen.dart';
import 'package:money_manager_app/features/wallet/wallet_screen.dart';
import 'package:money_manager_app/l10n/app_localizations.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppStore.instance,
      builder: (context, _) => MaterialApp(
        onGenerateTitle: (context) => context.l10n.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: AppStore.instance.themeMode,
        locale: AppStore.instance.locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        scrollBehavior: const IosScrollBehavior(),
        home: SplashScreen(
          next:
              AppStore.instance.onboarded && AppStore.instance.wallets.isNotEmpty && !AppConstants.alwaysShowOnboarding
              ? const MainShell()
              : const IntroScreen(next: OnboardingScreen(next: MainShell())),
        ),
      ),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with WidgetsBindingObserver {
  int _currentIndex = 0;
  late final _overviewGuideController = OverviewGuideController(
    active: !AppStore.instance.overviewGuideShown,
  );
  late final List<Widget> _screens = [
    OverviewScreen(guideController: _overviewGuideController),
    const TransactionsScreen(),
    const CalendarScreen(),
    const WalletScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _overviewGuideController.addListener(_onOverviewGuideChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _runRecurring());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _overviewGuideController
      ..removeListener(_onOverviewGuideChanged)
      ..dispose();
    super.dispose();
  }

  void _onOverviewGuideChanged() {
    if (!mounted) return;
    if (!_overviewGuideController.active &&
        !AppStore.instance.overviewGuideShown) {
      AppStore.instance.markOverviewGuideShown();
    }
    setState(() {
      if (!_overviewGuideController.active) {
        _currentIndex = _overviewGuideController.step == 8 ? 3 : 0;
      } else if (_overviewGuideController.previewing &&
          _overviewGuideController.step >= 6) {
        _currentIndex = _overviewGuideController.step - 5;
      } else if (_overviewGuideController.step == 6) {
        _currentIndex = 0;
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _runRecurring();
  }

  void _runRecurring() {
    final count = AppStore.instance.processRecurring();
    EventReminderService.instance.sync(
      AppStore.instance.allPlannedEvents,
      localization: context.l10n,
    );
    if (count > 0 && mounted) {
      ScaffoldMessenger.of(context)
          .showApp(context.l10n.autoAddedRecurring(count));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
      body: Padding(
        padding: EdgeInsets.only(
          bottom: _overviewGuideController.previewing &&
                  _overviewGuideController.step >= 6
              ? 60
              : 0,
        ),
        child: AbsorbPointer(
          absorbing: _overviewGuideController.previewing,
          child: IndexedStack(index: _currentIndex, children: _screens),
        ),
      ),
      floatingActionButtonLocation: const AddNavButtonLocation(),
      floatingActionButton: AddNavButton(
        key: OverviewGuideTargets.addTransaction,
        onPressed: () {
          if (_overviewGuideController.active) {
            if (_overviewGuideController.step == 5 &&
                !_overviewGuideController.previewing) {
              _overviewGuideController.enterPreview();
              Navigator.of(context)
                  .push<void>(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          const AddTransactionScreen(previewOnly: true),
                    ),
                  )
                  .then((_) {
                    if (mounted &&
                        _overviewGuideController.active &&
                        _overviewGuideController.step == 5 &&
                        _overviewGuideController.previewing) {
                      _overviewGuideController.next();
                    }
                  });
            }
            return;
          }
          HapticFeedback.lightImpact();
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
          );
        },
      ),
      bottomNavigationBar: CustomBottomNav(
        key: OverviewGuideTargets.navigation,
        currentIndex: _currentIndex,
        itemKeys: [
          OverviewGuideTargets.navigationOverview,
          OverviewGuideTargets.navigationTransactions,
          OverviewGuideTargets.navigationCalendar,
          OverviewGuideTargets.navigationWallet,
        ],
        onTap: (index) {
          if (_overviewGuideController.active) {
            if (!_overviewGuideController.previewing) {
              final expectedIndex = switch (_overviewGuideController.step) {
                6 => 1,
                7 => 2,
                8 => 3,
                _ => -1,
              };
              if (index == expectedIndex) {
                setState(() => _currentIndex = index);
                _overviewGuideController.enterPreview();
              }
            }
            return;
          }
          if (index != _currentIndex) HapticFeedback.selectionClick();
          setState(() => _currentIndex = index);
        },
      ),
        ),
        if (_overviewGuideController.active)
          Positioned.fill(
            child: OverviewGuideOverlay(controller: _overviewGuideController),
          ),
      ],
    );
  }
}



