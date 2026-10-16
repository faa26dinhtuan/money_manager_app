import 'package:flutter/material.dart';
import 'package:money_manager_app/features/settings/settings_screen.dart';

class SettingsButton extends StatelessWidget {
  const SettingsButton({super.key, this.color});

  final Color? color;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.settings_outlined, color: color),
      tooltip: 'Cài đặt',
      onPressed: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const SettingsScreen()),
      ),
    );
  }
}
