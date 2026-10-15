import 'package:flutter/material.dart';

/// Màn hình Giao dịch (tạm thời để trống).
/// Sau này: danh sách thu/chi theo ngày, tuần, tháng.
class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Giao dịch')),
      body: const Center(child: Text('Danh sách giao dịch')),
    );
  }
}
