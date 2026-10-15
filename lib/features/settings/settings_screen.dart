import 'package:flutter/material.dart';

/// Màn hình Cài đặt (tạm thời để trống).
/// Sau này: tiền tệ mặc định, sao lưu dữ liệu, giao diện...
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt')),
      body: const Center(child: Text('Cài đặt ứng dụng')),
    );
  }
}
