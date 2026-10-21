import 'package:flutter/material.dart';

@immutable
class AppIconData {
  const AppIconData(this.name, {this.scale = 1});

  final String name;
  final double scale;

  String get path => 'assets/icons/$name.png';

  @override
  bool operator ==(Object other) => other is AppIconData && other.name == name;

  @override
  int get hashCode => name.hashCode;
}

class AppIcons {
  const AppIcons._();

  static const overview = AppIconData('overview');
  static const transactions = AppIconData('transactions');
  static const categories = AppIconData('categories');
  static const wallet = AppIconData('wallet');
  static const add = AppIconData('add');
  static const remove = AppIconData('remove');
  static const close = AppIconData('close');
  static const check = AppIconData('check');
  static const delete = AppIconData('delete');
  static const edit = AppIconData('edit');
  static const search = AppIconData('search');
  static const refresh = AppIconData('refresh');
  static const settings = AppIconData('settings');
  static const info = AppIconData('info');
  static const warning = AppIconData('warning');
  static const arrowLeft = AppIconData('arrow_left');
  static const arrowRight = AppIconData('arrow_right');
  static const arrowUp = AppIconData('arrow_up');
  static const arrowDown = AppIconData('arrow_down');
  static const chevronLeft = AppIconData('chevron_left', scale: 1.5);
  static const chevronRight = AppIconData('chevron_right', scale: 1.5);
  static const chevronDown = AppIconData('chevron_down', scale: 1.5);
  static const doubleLeft = AppIconData('double_left', scale: 1.5);
  static const doubleRight = AppIconData('double_right', scale: 1.5);
  static const backspace = AppIconData('backspace');
  static const checkCircle = AppIconData('check_circle');
  static const clock = AppIconData('clock');
  static const calendar = AppIconData('calendar');
  static const notes = AppIconData('notes');
  static const repeat = AppIconData('repeat');
  static const swap = AppIconData('swap');
  static const exchange = AppIconData('exchange');
  static const download = AppIconData('download');
  static const upload = AppIconData('upload');
  static const flag = AppIconData('flag');
  static const received = AppIconData('received');
  static const sent = AppIconData('sent');
  static const restaurant = AppIconData('restaurant');
  static const coffee = AppIconData('coffee');
  static const shoppingBasket = AppIconData('shopping_basket');
  static const shoppingCart = AppIconData('shopping_cart');
  static const home = AppIconData('home');
  static const bolt = AppIconData('bolt');
  static const bus = AppIconData('bus');
  static const car = AppIconData('car');
  static const motorcycle = AppIconData('motorcycle');
  static const flight = AppIconData('flight');
  static const family = AppIconData('family');
  static const favorite = AppIconData('favorite');
  static const health = AppIconData('health');
  static const pets = AppIconData('pets');
  static const gift = AppIconData('gift');
  static const celebration = AppIconData('celebration');
  static const movie = AppIconData('movie');
  static const beach = AppIconData('beach');
  static const camera = AppIconData('camera');
  static const brush = AppIconData('brush');
  static const school = AppIconData('school');
  static const fitness = AppIconData('fitness');
  static const phone = AppIconData('phone');
  static const laptop = AppIconData('laptop');
  static const creditCard = AppIconData('credit_card');
  static const bank = AppIconData('bank');
  static const savings = AppIconData('savings');
  static const payments = AppIconData('payments');
  static const dollar = AppIconData('dollar');
  static const diamond = AppIconData('diamond');
  static const trendingUp = AppIconData('trending_up');
  static const help = AppIconData('help');
  static const theme = AppIconData('theme', scale: 1.2);
  static const language = AppIconData('language');
  static const backup = AppIconData('backup');
  static const exportFile = AppIconData('export_file');
  static const budget = AppIconData('budget');
  static const goal = AppIconData('goal');
  static const debt = AppIconData('debt');
}

class AppIcon extends StatelessWidget {
  const AppIcon(this.icon, {super.key, this.size, this.color});

  final AppIconData icon;
  final double? size;
  final Color? color;

  static const double _fill = 0.85;

  @override
  Widget build(BuildContext context) {
    final iconTheme = IconTheme.of(context);
    final s = size ?? iconTheme.size ?? 24;
    Widget image = ImageIcon(
      AssetImage(icon.path),
      size: s * _fill,
      color: color,
    );
    if (icon.scale != 1) {
      image = Transform.scale(scale: icon.scale, child: image);
    }
    return SizedBox(width: s, height: s, child: Center(child: image));
  }
}
