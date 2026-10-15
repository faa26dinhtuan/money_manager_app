import 'package:flutter/material.dart';

enum TxType {
  expense('CHI TIÊU'),
  income('THU NHẬP');

  const TxType(this.label);
  final String label;
}

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
