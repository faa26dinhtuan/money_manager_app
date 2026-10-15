import 'package:money_manager_app/data/models/category.dart';

class Transaction {
  const Transaction({
    required this.id,
    required this.type,
    required this.categoryId,
    required this.amount,
    required this.date,
    this.note = '',
  });

  final String id;
  final TxType type;
  final String categoryId;
  final double amount;
  final DateTime date;
  final String note;
}
