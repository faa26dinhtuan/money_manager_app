import 'package:flutter/material.dart';
import 'package:money_manager_app/core/theme/app_theme.dart';

/// Màn hình Tổng quan (tạm thời: header số dư + trạng thái trống).
/// Sau này: biểu đồ tròn chi tiêu theo danh mục + danh sách top danh mục.
class OverviewScreen extends StatelessWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header xanh hiển thị số dư
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
            decoration: const BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
            ),
            child: const SafeArea(
              bottom: false,
              child: Column(
                children: [
                  SizedBox(height: 16),
                  Text(
                    'SỐ DƯ',
                    style: TextStyle(color: Colors.white70, letterSpacing: 1.5),
                  ),
                  SizedBox(height: 6),
                  Text(
                    '0 ₫',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.pie_chart_outline, size: 64, color: Colors.black26),
                  SizedBox(height: 12),
                  Text(
                    'Chưa có dữ liệu chi tiêu',
                    style: TextStyle(color: Colors.black54, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {}, // TODO: mở màn hình thêm giao dịch
        child: const Icon(Icons.add),
      ),
    );
  }
}
