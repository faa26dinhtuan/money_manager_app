import 'package:flutter/material.dart';
import 'package:money_manager_app/core/widgets/app_lottie.dart';

extension AppSnackBar on ScaffoldMessengerState {
  void showApp(String message, {SnackBarAction? action}) {
    hideCurrentSnackBar();
    showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        persist: false,
        behavior: SnackBarBehavior.floating,
        dismissDirection: DismissDirection.horizontal,
        action: action,
      ),
    );
  }

  void showAppWithAnimation(String message, {required String animation}) {
    hideCurrentSnackBar();
    showSnackBar(
      SnackBar(
        content: Row(
          children: [
            AppLottie(asset: animation, size: 36),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        duration: const Duration(milliseconds: 1800),
        persist: false,
        behavior: SnackBarBehavior.floating,
        dismissDirection: DismissDirection.horizontal,
      ),
    );
  }
}
