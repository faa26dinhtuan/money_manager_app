import 'package:flutter/widgets.dart';
import 'package:lottie/lottie.dart';

class AppAnimations {
  AppAnimations._();

  static const onboarding = 'assets/animations/finance_app_onboarding.json';
  static const wallet = 'assets/animations/wallet_minimal.json';
  static const success = 'assets/animations/payment_success.json';
  static const empty = 'assets/animations/empty_state_finance.json';
  static const goals = 'assets/animations/savings_goal_progress.json';
  static const calendar = 'assets/animations/calendar_event_reminder.json';
  static const budget = 'assets/animations/expense_chart.json';
}

class AppLottie extends StatelessWidget {
  const AppLottie({
    super.key,
    required this.asset,
    required this.size,
    this.repeat = false,
  });

  final String asset;
  final double size;
  final bool repeat;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Lottie.asset(asset, fit: BoxFit.contain, repeat: repeat),
    );
  }
}
