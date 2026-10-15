import 'package:flutter/material.dart';

/// Màn hình Danh mục (tạm thời để trống).
/// Sau này: xem, thêm, sửa danh mục thu/chi.
class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Danh mục')),
      body: const Center(child: Text('Danh sách danh mục')),
    );
  }
}
