enum DebtType { lend, borrow }

class DebtPayment {
  const DebtPayment({
    required this.id,
    required this.amount,
    required this.date,
    this.note = '',
    this.walletId,
  });

  final String id;
  final double amount;
  final DateTime date;
  final String note;
  final String? walletId;

  DebtPayment withoutWallet() {
    return DebtPayment(id: id, amount: amount, date: date, note: note);
  }

  factory DebtPayment.fromJson(Map<String, dynamic> json) {
    return DebtPayment(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      note: json['note'] as String? ?? '',
      walletId: json['walletId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'date': date.toIso8601String(),
      'note': note,
      'walletId': walletId,
    };
  }
}

class Debt {
  const Debt({
    required this.id,
    required this.type,
    required this.person,
    required this.amount,
    required this.date,
    this.dueDate,
    this.note = '',
    this.walletId,
    this.payments = const [],
  });

  final String id;
  final DebtType type;
  final String person;
  final double amount;
  final DateTime date;
  final DateTime? dueDate;
  final String note;
  final String? walletId;
  final List<DebtPayment> payments;

  double get paid => payments.fold<double>(0, (sum, p) => sum + p.amount);

  double get remaining => amount > paid ? amount - paid : 0;

  double get progress => amount <= 0 ? 0 : paid / amount;

  bool get isSettled => amount > 0 && paid >= amount;

  double get principalFlow => type == DebtType.borrow ? amount : -amount;

  double paymentFlow(DebtPayment p) =>
      type == DebtType.lend ? p.amount : -p.amount;

  int? daysLeft(DateTime now) {
    final d = dueDate;
    if (d == null) return null;
    final end = DateTime.utc(d.year, d.month, d.day);
    final today = DateTime.utc(now.year, now.month, now.day);
    return end.difference(today).inDays;
  }

  Debt copyWith({
    String? person,
    double? amount,
    DateTime? date,
    DateTime? dueDate,
    bool clearDueDate = false,
    String? note,
    String? walletId,
    bool clearWallet = false,
    List<DebtPayment>? payments,
  }) {
    return Debt(
      id: id,
      type: type,
      person: person ?? this.person,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      note: note ?? this.note,
      walletId: clearWallet ? null : (walletId ?? this.walletId),
      payments: payments ?? this.payments,
    );
  }

  factory Debt.fromJson(Map<String, dynamic> json) {
    final rawDue = json['dueDate'] as String?;
    return Debt(
      id: json['id'] as String,
      type: DebtType.values.byName(json['type'] as String),
      person: json['person'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      dueDate: rawDue == null ? null : DateTime.parse(rawDue),
      note: json['note'] as String? ?? '',
      walletId: json['walletId'] as String?,
      payments: (json['payments'] as List? ?? [])
          .map((e) => DebtPayment.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'person': person,
      'amount': amount,
      'date': date.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'note': note,
      'walletId': walletId,
      'payments': payments.map((p) => p.toJson()).toList(),
    };
  }
}
