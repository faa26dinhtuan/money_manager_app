import 'package:flutter/material.dart';
import 'package:money_manager_app/core/widgets/app_icon.dart';
import 'package:money_manager_app/core/utils/category_icons.dart';

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
  final AppIconData icon;
  final Color color;
  final TxType type;

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: iconFromKey(json['icon'] as String),
      color: Color(json['color'] as int),
      type: TxType.values.byName(json['type'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': iconToKey(icon),
      'color': color.toARGB32(),
      'type': type.name,
    };
  }
}
