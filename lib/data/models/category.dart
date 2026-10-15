import 'package:flutter/material.dart';

/// Loại giao dịch: chi tiêu hoặc thu nhập.
enum TxType {
  expense('CHI TIÊU'),
  income('THU NHẬP');

  const TxType(this.label);
  final String label;
}

/// Danh mục thu/chi (ví dụ: Ăn uống, Lương...).
class Category {
  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
  });

  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final TxType type;
}
