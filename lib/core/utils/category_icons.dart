import 'package:flutter/material.dart';

const Map<String, IconData> categoryIcons = {
  'restaurant': Icons.restaurant,
  'shopping_basket': Icons.shopping_basket,
  'shopping_cart': Icons.shopping_cart,
  'home': Icons.home,
  'directions_bus': Icons.directions_bus,
  'favorite': Icons.favorite,
  'bolt': Icons.bolt,
  'help_outline': Icons.help_outline,
  'account_balance_wallet': Icons.account_balance_wallet,
  'card_giftcard': Icons.card_giftcard,
  'trending_up': Icons.trending_up,
  'account_balance': Icons.account_balance,
  'family_restroom': Icons.family_restroom,
  'flight': Icons.flight,
  'pets': Icons.pets,
  'directions_car': Icons.directions_car,
  'brush': Icons.brush,
  'fitness_center': Icons.fitness_center,
  'school': Icons.school,
  'movie': Icons.movie,
  'coffee': Icons.coffee,
  'phone_android': Icons.phone_android,
  'credit_card': Icons.credit_card,
  'savings': Icons.savings,
  'payments': Icons.payments,
  'attach_money': Icons.attach_money,
  'flag': Icons.flag,
  'beach_access': Icons.beach_access,
  'laptop_mac': Icons.laptop_mac,
  'camera_alt': Icons.camera_alt,
  'diamond': Icons.diamond,
  'celebration': Icons.celebration,
  'two_wheeler': Icons.two_wheeler,
  'health_and_safety': Icons.health_and_safety,
};

String iconToKey(IconData icon) {
  for (final entry in categoryIcons.entries) {
    if (entry.value == icon) return entry.key;
  }
  return 'help_outline';
}

IconData iconFromKey(String key) => categoryIcons[key] ?? Icons.help_outline;
