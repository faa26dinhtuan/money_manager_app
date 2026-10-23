import 'package:money_manager_app/data/models/category.dart';
import 'package:money_manager_app/data/models/recurring_transaction.dart';

class PlannedEvent {
  const PlannedEvent({
    required this.id,
    required this.title,
    required this.type,
    required this.amount,
    required this.date,
    required this.currencyCode,
    this.note = '',
    this.walletId,
    this.recurringId,
    this.frequency,
    this.seriesStartDate,
  });

  final String id;
  final String title;
  final TxType type;
  final double amount;
  final DateTime date;
  final String currencyCode;
  final String note;
  final String? walletId;
  final String? recurringId;
  final Frequency? frequency;
  final DateTime? seriesStartDate;

  PlannedEvent copyWith({
    String? title,
    TxType? type,
    double? amount,
    DateTime? date,
    String? currencyCode,
    String? note,
    String? recurringId,
    Frequency? frequency,
    DateTime? seriesStartDate,
  }) => PlannedEvent(
    id: id,
    title: title ?? this.title,
    type: type ?? this.type,
    amount: amount ?? this.amount,
    date: date ?? this.date,
    currencyCode: currencyCode ?? this.currencyCode,
    note: note ?? this.note,
    walletId: walletId,
    recurringId: recurringId ?? this.recurringId,
    frequency: frequency ?? this.frequency,
    seriesStartDate: seriesStartDate ?? this.seriesStartDate,
  );

  factory PlannedEvent.fromJson(Map<String, dynamic> json) => PlannedEvent(
    id: json['id'] as String,
    title: json['title'] as String,
    type: TxType.values.byName(json['type'] as String),
    amount: (json['amount'] as num).toDouble(),
    date: DateTime.parse(json['date'] as String),
    currencyCode: json['currencyCode'] as String? ?? 'VND',
    note: json['note'] as String? ?? '',
    walletId: json['walletId'] as String?,
    recurringId: json['recurringId'] as String?,
    frequency: json['frequency'] == null
        ? null
        : Frequency.values.byName(json['frequency'] as String),
    seriesStartDate: json['seriesStartDate'] == null
        ? null
        : DateTime.parse(json['seriesStartDate'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'type': type.name,
    'amount': amount,
    'date': date.toIso8601String(),
    'currencyCode': currencyCode,
    'note': note,
    'walletId': walletId,
    'recurringId': recurringId,
    'frequency': frequency?.name,
    'seriesStartDate': seriesStartDate?.toIso8601String(),
  };
}
