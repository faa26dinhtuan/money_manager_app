import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:money_manager_app/core/utils/date_range.dart';
import 'package:money_manager_app/data/models/category.dart';
import 'package:money_manager_app/data/models/transaction.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppStore extends ChangeNotifier {
  AppStore._();
  static final AppStore instance = AppStore._();

  static const _categoriesKey = 'categories';
  static const _transactionsKey = 'transactions';

  late final SharedPreferences _prefs;

  final List<Category> _categories = [];
  final List<Transaction> _transactions = [];

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    final rawCategories = _prefs.getString(_categoriesKey);
    final rawTransactions = _prefs.getString(_transactionsKey);
    if (rawCategories != null && rawTransactions != null) {
      try {
        final categories = (jsonDecode(rawCategories) as List)
            .map((e) => Category.fromJson(e as Map<String, dynamic>))
            .toList();
        final transactions = (jsonDecode(rawTransactions) as List)
            .map((e) => Transaction.fromJson(e as Map<String, dynamic>))
            .toList();
        _categories
          ..clear()
          ..addAll(categories);
        _transactions
          ..clear()
          ..addAll(transactions);
        return;
      } catch (_) {
        _categories.clear();
        _transactions.clear();
      }
    }
    _seed();
    await _save();
  }

  Future<void> _save() async {
    await _prefs.setString(
      _categoriesKey,
      jsonEncode(_categories.map((c) => c.toJson()).toList()),
    );
    await _prefs.setString(
      _transactionsKey,
      jsonEncode(_transactions.map((t) => t.toJson()).toList()),
    );
  }

  List<Category> categoriesOf(TxType type) =>
      _categories.where((c) => c.type == type).toList();

  Category? categoryById(String id) {
    for (final c in _categories) {
      if (c.id == id) return c;
    }
    return null;
  }

  List<Transaction> query(TxType type, DateRange range) {
    final list = _transactions
        .where((t) => t.type == type && range.contains(t.date))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  double get balance {
    var sum = 0.0;
    for (final t in _transactions) {
      sum += t.type == TxType.income ? t.amount : -t.amount;
    }
    return sum;
  }

  void addTransaction(Transaction t) {
    _transactions.add(t);
    notifyListeners();
    _save();
  }

  void updateTransaction(Transaction updated) {
    final index = _transactions.indexWhere((t) => t.id == updated.id);
    if (index == -1) return;
    _transactions[index] = updated;
    notifyListeners();
    _save();
  }

  void removeTransaction(String id) {
    _transactions.removeWhere((t) => t.id == id);
    notifyListeners();
    _save();
  }

  void addCategory(Category c) {
    _categories.add(c);
    notifyListeners();
    _save();
  }

  int transactionCountOf(String categoryId) =>
      _transactions.where((t) => t.categoryId == categoryId).length;

  void updateCategory(Category updated) {
    final index = _categories.indexWhere((c) => c.id == updated.id);
    if (index == -1) return;
    _categories[index] = updated;
    notifyListeners();
    _save();
  }

  void removeCategory(String id) {
    _categories.removeWhere((c) => c.id == id);
    _transactions.removeWhere((t) => t.categoryId == id);
    notifyListeners();
    _save();
  }

  String newId() => DateTime.now().microsecondsSinceEpoch.toString();

  void _seed() {
    const e = TxType.expense;
    const i = TxType.income;
    _categories.addAll(const [
      Category(id: 'food', name: 'Ăn uống', icon: Icons.restaurant, color: Color(0xFFF5B82E), type: e),
      Category(id: 'grocery', name: 'Đi chợ', icon: Icons.shopping_basket, color: Color(0xFF4C9BE8), type: e),
      Category(id: 'shop', name: 'Mua sắm', icon: Icons.shopping_cart, color: Color(0xFF9B5DE5), type: e),
      Category(id: 'home', name: 'Nhà cửa', icon: Icons.home, color: Color(0xFFE8506E), type: e),
      Category(id: 'transport', name: 'Di chuyển', icon: Icons.directions_bus, color: Color(0xFF3CC6B0), type: e),
      Category(id: 'health', name: 'Sức khỏe', icon: Icons.favorite, color: Color(0xFFEF6C57), type: e),
      Category(id: 'bill', name: 'Hóa đơn', icon: Icons.bolt, color: Color(0xFF6BB94A), type: e),
      Category(id: 'other_e', name: 'Khác', icon: Icons.help_outline, color: Color(0xFF8E9A93), type: e),
      Category(id: 'salary', name: 'Lương', icon: Icons.account_balance_wallet, color: Color(0xFF2A8C66), type: i),
      Category(id: 'bonus', name: 'Thưởng', icon: Icons.card_giftcard, color: Color(0xFFF5B82E), type: i),
      Category(id: 'invest', name: 'Đầu tư', icon: Icons.trending_up, color: Color(0xFF4C9BE8), type: i),
      Category(id: 'other_i', name: 'Khác', icon: Icons.help_outline, color: Color(0xFF8E9A93), type: i),
    ]);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    Transaction tx(String id, TxType type, String cat, double amount, int daysAgo, [String note = '']) =>
        Transaction(
          id: id,
          type: type,
          categoryId: cat,
          amount: amount,
          date: today.subtract(Duration(days: daysAgo)).add(const Duration(hours: 12)),
          note: note,
        );

    _transactions.addAll([
      tx('1', e, 'food', 85000, 0, 'Cơm trưa'),
      tx('2', e, 'transport', 30000, 0, 'Grab'),
      tx('3', e, 'grocery', 220000, 1, 'Rau củ ở chợ'),
      tx('4', e, 'shop', 450000, 2, 'Áo thun'),
      tx('5', e, 'food', 120000, 3, 'Cà phê + bánh'),
      tx('6', e, 'bill', 650000, 5, 'Tiền điện'),
      tx('7', e, 'home', 3000000, 8, 'Tiền nhà'),
      tx('8', e, 'health', 180000, 12, 'Thuốc'),
      tx('9', e, 'food', 95000, 15),
      tx('10', i, 'salary', 15000000, 4, 'Lương tháng'),
      tx('11', i, 'bonus', 1000000, 10, 'Thưởng dự án'),
      tx('12', i, 'invest', 350000, 20, 'Lãi tiết kiệm'),
    ]);
  }
}
