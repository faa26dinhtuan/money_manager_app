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
              AppStore.instance.onboarded && !AppConstants.alwaysShowOnboarding
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _runRecurring());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
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
      ScaffoldMessenger.of(
        context,
      ).showApp(context.l10n.autoAddedRecurring(count));
    }
  }

  static const List<Widget> _screens = [
    OverviewScreen(),
    TransactionsScreen(),
    CalendarScreen(),
    WalletScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      floatingActionButtonLocation: const AddNavButtonLocation(),
      floatingActionButton: AddNavButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
          );
        },
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index != _currentIndex) HapticFeedback.selectionClick();
          setState(() => _currentIndex = index);
        },
      ),
    );
  }
}
