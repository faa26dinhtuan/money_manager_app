import 'package:flutter/material.dart';
import 'package:money_manager_app/core/theme/app_theme.dart';
import 'package:money_manager_app/core/utils/constants.dart';
import 'package:money_manager_app/core/widgets/custom_bottom_nav.dart';
import 'package:money_manager_app/features/categories/categories_screen.dart';
import 'package:money_manager_app/features/overview/overview_screen.dart';
import 'package:money_manager_app/features/settings/settings_screen.dart';
import 'package:money_manager_app/features/transactions/transactions_screen.dart';

/// MaterialApp gốc của ứng dụng.
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const MainShell(),
    );
  }
}

/// Khung chính: nội dung + thanh điều hướng dưới.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  // Thứ tự phải khớp với thứ tự tab trong CustomBottomNav.
  static const List<Widget> _screens = [
    OverviewScreen(),
    TransactionsScreen(),
    CategoriesScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack giữ nguyên trạng thái từng tab khi chuyển qua lại.
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
