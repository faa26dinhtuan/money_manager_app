import 'package:money_manager_app/data/models/category.dart';

enum Frequency { daily, weekly, monthly, yearly }

class RecurringTransaction {
  const RecurringTransaction({
    required this.id,
    required this.type,
    required this.categoryId,
    required this.walletId,
    required this.amount,
    required this.frequency,
    required this.startDate,
    required this.nextDate,
    this.endDate,
    this.note = '',
    this.active = true,
  });

  final String id;
  final TxType type;
  final String categoryId;
  final String walletId;
  final double amount;
  final Frequency frequency;
  final DateTime startDate;
  final DateTime nextDate;
  final DateTime? endDate;
  final String note;
  final bool active;

  static DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  bool get isFinished {
    final e = endDate;
    return e != null && nextDate.isAfter(e);
  }

  bool isDue(DateTime today) =>
      active && !isFinished && !nextDate.isAfter(today);

  double get monthlyAmount {
    switch (frequency) {
      case Frequency.daily:
        return amount * 30;
      case Frequency.weekly:
        return amount * 52 / 12;
      case Frequency.monthly:
        return amount;
      case Frequency.yearly:
        return amount / 12;
    }
  }

  DateTime advance(DateTime from) {
    switch (frequency) {
      case Frequency.daily:
        return DateTime(from.year, from.month, from.day + 1);
      case Frequency.weekly:
        return DateTime(from.year, from.month, from.day + 7);
      case Frequency.monthly:
        return _addMonths(from, 1);
      case Frequency.yearly:
        return _addMonths(from, 12);
    }
  }

  DateTime _addMonths(DateTime from, int months) {
    final total = from.month - 1 + months;
    final year = from.year + total ~/ 12;
    final month = total % 12 + 1;
    final lastDay = DateTime(year, month + 1, 0).day;
    final day = startDate.day < lastDay ? startDate.day : lastDay;
    return DateTime(year, month, day);
  }

  RecurringTransaction copyWith({
    TxType? type,
    String? categoryId,
    String? walletId,
    double? amount,
    Frequency? frequency,
    DateTime? startDate,
    DateTime? nextDate,
    DateTime? endDate,
    bool clearEndDate = false,
    String? note,
    bool? active,
  }) {
    return RecurringTransaction(
      id: id,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      walletId: walletId ?? this.walletId,
      amount: amount ?? this.amount,
      frequency: frequency ?? this.frequency,
      startDate: startDate ?? this.startDate,
      nextDate: nextDate ?? this.nextDate,
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
      note: note ?? this.note,
      active: active ?? this.active,
    );
  }

  factory RecurringTransaction.fromJson(Map<String, dynamic> json) {
    final rawEnd = json['endDate'] as String?;
    return RecurringTransaction(
      id: json['id'] as String,
      type: TxType.values.byName(json['type'] as String),
      categoryId: json['categoryId'] as String,
      walletId: json['walletId'] as String,
      amount: (json['amount'] as num).toDouble(),
      frequency: Frequency.values.byName(json['frequency'] as String),
      startDate: DateTime.parse(json['startDate'] as String),
      nextDate: DateTime.parse(json['nextDate'] as String),
      endDate: rawEnd == null ? null : DateTime.parse(rawEnd),
      note: json['note'] as String? ?? '',
      active: json['active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'categoryId': categoryId,
      'walletId': walletId,
      'amount': amount,
      'frequency': frequency.name,
      'startDate': startDate.toIso8601String(),
      'nextDate': nextDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'note': note,
      'active': active,
    };
  }
}
