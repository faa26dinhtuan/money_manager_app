import 'dart:convert';
import 'dart:io';

import 'package:money_manager_app/data/models/budget.dart';
import 'package:money_manager_app/data/models/category.dart';
import 'package:money_manager_app/data/models/debt.dart';
import 'package:money_manager_app/data/models/goal.dart';
import 'package:money_manager_app/data/models/recurring_transaction.dart';
import 'package:money_manager_app/data/models/transaction.dart';
import 'package:money_manager_app/data/models/wallet.dart';

class BackupData {
  const BackupData({
    required this.categories,
    required this.transactions,
    required this.wallets,
    required this.budgets,
    required this.goals,
    required this.debts,
    required this.recurrings,
    this.exportedAt,
    this.currency,
  });

  static const _prefix = 'MMBK1:';
  static const _appId = 'money_manager_app';
  static const _version = 1;

  final List<Category> categories;
  final List<Transaction> transactions;
  final List<Wallet> wallets;
  final List<Budget> budgets;
  final List<Goal> goals;
  final List<Debt> debts;
  final List<RecurringTransaction> recurrings;
  final DateTime? exportedAt;
  final String? currency;

  String encode() {
    final json = jsonEncode({
      'app': _appId,
      'version': _version,
      'exportedAt': DateTime.now().toIso8601String(),
      'categories': categories.map((e) => e.toJson()).toList(),
      'transactions': transactions.map((e) => e.toJson()).toList(),
      'wallets': wallets.map((e) => e.toJson()).toList(),
      'budgets': budgets.map((e) => e.toJson()).toList(),
      'goals': goals.map((e) => e.toJson()).toList(),
      'debts': debts.map((e) => e.toJson()).toList(),
      'recurrings': recurrings.map((e) => e.toJson()).toList(),
      if (currency != null) 'currency': currency,
    });
    return _prefix + base64Encode(gzip.encode(utf8.encode(json)));
  }

  factory BackupData.parse(String raw) {
    try {
      var text = raw.trim();
      if (text.startsWith(_prefix)) {
        final body = text.substring(_prefix.length).replaceAll(RegExp(r'\s'), '');
        text = utf8.decode(gzip.decode(base64Decode(body)));
      }
      final map = jsonDecode(text);
      if (map is! Map<String, dynamic> || map['app'] != _appId) {
        throw const FormatException('not a backup');
      }
      if ((map['version'] as int) > _version) {
        throw const FormatException('newer version');
      }

      List<T> read<T>(String key, T Function(Map<String, dynamic>) from) {
        return ((map[key] as List?) ?? const [])
            .map((e) => from(e as Map<String, dynamic>))
            .toList();
      }

      final wallets = read('wallets', Wallet.fromJson);
      if (wallets.isEmpty) throw const FormatException('no wallets');
      final exported = map['exportedAt'] as String?;

      return BackupData(
        categories: read('categories', Category.fromJson),
        transactions: read('transactions', Transaction.fromJson),
        wallets: wallets,
        budgets: read('budgets', Budget.fromJson),
        goals: read('goals', Goal.fromJson),
        debts: read('debts', Debt.fromJson),
        recurrings: read('recurrings', RecurringTransaction.fromJson),
        exportedAt: exported == null ? null : DateTime.tryParse(exported),
        currency: map['currency'] as String?,
      );
    } on FormatException {
      rethrow;
    } catch (_) {
      throw const FormatException('invalid backup');
    }
  }
}
