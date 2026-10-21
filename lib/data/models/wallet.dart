import 'package:flutter/material.dart';
import 'package:money_manager_app/core/widgets/app_icon.dart';
import 'package:money_manager_app/core/utils/category_icons.dart';

class Wallet {
  const Wallet({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.initialBalance = 0,
  });

  final String id;
  final String name;
  final AppIconData icon;
  final Color color;
  final double initialBalance;

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: iconFromKey(json['icon'] as String),
      color: Color(json['color'] as int),
      initialBalance: (json['initialBalance'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': iconToKey(icon),
      'color': color.toARGB32(),
      'initialBalance': initialBalance,
    };
  }
}
