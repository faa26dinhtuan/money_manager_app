import 'package:flutter/material.dart';

extension AppSnackBar on ScaffoldMessengerState {
  void showApp(String message, {SnackBarAction? action}) {
    hideCurrentSnackBar();
    showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        persist: false,
        dismissDirection: DismissDirection.horizontal,
        action: action,
      ),
    );
  }
}
