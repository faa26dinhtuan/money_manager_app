import 'package:flutter/material.dart';
import 'package:money_manager_app/core/utils/category_icons.dart';

class GoalEntry {
  const GoalEntry({
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

  bool get isDeposit => amount > 0;

  GoalEntry withoutWallet() {
    return GoalEntry(id: id, amount: amount, date: date, note: note);
  }

  factory GoalEntry.fromJson(Map<String, dynamic> json) {
    return GoalEntry(
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

class Goal {
  const Goal({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.target,
    this.deadline,
    this.entries = const [],
  });

  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final double target;
  final DateTime? deadline;
  final List<GoalEntry> entries;

  double get saved => entries.fold<double>(0, (sum, e) => sum + e.amount);

  double get remaining => target > saved ? target - saved : 0;

  double get progress => target <= 0 ? 0 : saved / target;

  bool get isCompleted => target > 0 && saved >= target;

  int? daysLeft(DateTime now) {
    final d = deadline;
    if (d == null) return null;
    final end = DateTime.utc(d.year, d.month, d.day);
    final today = DateTime.utc(now.year, now.month, now.day);
    return end.difference(today).inDays;
  }

  double? requiredPerDay(DateTime now) {
    final days = daysLeft(now);
    if (days == null || days <= 0 || isCompleted) return null;
    return remaining / days;
  }

  Goal copyWith({
    String? name,
    IconData? icon,
    Color? color,
    double? target,
    DateTime? deadline,
    bool clearDeadline = false,
    List<GoalEntry>? entries,
  }) {
    return Goal(
      id: id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      target: target ?? this.target,
      deadline: clearDeadline ? null : (deadline ?? this.deadline),
      entries: entries ?? this.entries,
    );
  }

  factory Goal.fromJson(Map<String, dynamic> json) {
    final rawDeadline = json['deadline'] as String?;
    return Goal(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: iconFromKey(json['icon'] as String),
      color: Color(json['color'] as int),
      target: (json['target'] as num).toDouble(),
      deadline: rawDeadline == null ? null : DateTime.parse(rawDeadline),
      entries: (json['entries'] as List? ?? [])
          .map((e) => GoalEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': iconToKey(icon),
      'color': color.toARGB32(),
      'target': target,
      'deadline': deadline?.toIso8601String(),
      'entries': entries.map((e) => e.toJson()).toList(),
    };
  }
}
