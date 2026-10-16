import 'package:money_manager_app/data/models/category.dart';

class Transaction {
  const Transaction({
    required this.id,
    required this.type,
    required this.categoryId,
    required this.walletId,
    required this.amount,
    required this.date,
    this.note = '',
  });

  final String id;
  final TxType type;
  final String categoryId;
  final String walletId;
  final double amount;
  final DateTime date;
  final String note;

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      type: TxType.values.byName(json['type'] as String),
      categoryId: json['categoryId'] as String,
      walletId: json['walletId'] as String? ?? 'cash',
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      note: json['note'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'categoryId': categoryId,
      'walletId': walletId,
      'amount': amount,
      'date': date.toIso8601String(),
      'note': note,
    };
  }
}
