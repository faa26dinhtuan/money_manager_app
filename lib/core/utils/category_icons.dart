import 'package:money_manager_app/core/widgets/app_icon.dart';

const Map<String, AppIconData> categoryIcons = {
  'restaurant': AppIcons.restaurant,
  'shopping_basket': AppIcons.shoppingBasket,
  'shopping_cart': AppIcons.shoppingCart,
  'home': AppIcons.home,
  'directions_bus': AppIcons.bus,
  'favorite': AppIcons.favorite,
  'bolt': AppIcons.bolt,
  'help_outline': AppIcons.help,
  'account_balance_wallet': AppIcons.wallet,
  'card_giftcard': AppIcons.gift,
  'trending_up': AppIcons.trendingUp,
  'account_balance': AppIcons.bank,
  'family_restroom': AppIcons.family,
  'flight': AppIcons.flight,
  'pets': AppIcons.pets,
  'directions_car': AppIcons.car,
  'brush': AppIcons.brush,
  'fitness_center': AppIcons.fitness,
  'school': AppIcons.school,
  'movie': AppIcons.movie,
  'coffee': AppIcons.coffee,
  'phone_android': AppIcons.phone,
  'credit_card': AppIcons.creditCard,
  'savings': AppIcons.savings,
  'payments': AppIcons.payments,
  'attach_money': AppIcons.dollar,
  'flag': AppIcons.flag,
  'beach_access': AppIcons.beach,
  'laptop_mac': AppIcons.laptop,
  'camera_alt': AppIcons.camera,
  'diamond': AppIcons.diamond,
  'celebration': AppIcons.celebration,
  'two_wheeler': AppIcons.motorcycle,
  'health_and_safety': AppIcons.health,
};

const List<AppIconData> availableCategoryIcons = [
  AppIcons.restaurant,
  AppIcons.coffee,
  AppIcons.shoppingBasket,
  AppIcons.shoppingCart,
  AppIcons.home,
  AppIcons.bus,
  AppIcons.car,
  AppIcons.motorcycle,
  AppIcons.flight,
  AppIcons.bolt,
  AppIcons.favorite,
  AppIcons.health,
  AppIcons.fitness,
  AppIcons.family,
  AppIcons.pets,
  AppIcons.gift,
  AppIcons.celebration,
  AppIcons.movie,
  AppIcons.beach,
  AppIcons.camera,
  AppIcons.brush,
  AppIcons.school,
  AppIcons.phone,
  AppIcons.laptop,
  AppIcons.creditCard,
  AppIcons.bank,
  AppIcons.wallet,
  AppIcons.savings,
  AppIcons.payments,
  AppIcons.dollar,
  AppIcons.diamond,
  AppIcons.trendingUp,
  AppIcons.flag,
];

String iconToKey(AppIconData icon) {
  for (final entry in categoryIcons.entries) {
    if (entry.value == icon) return entry.key;
  }
  return 'help_outline';
}

AppIconData iconFromKey(String key) => categoryIcons[key] ?? AppIcons.help;
