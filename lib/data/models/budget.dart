import 'package:money_manager_app/core/utils/currency.dart';

class Budget {
  const Budget({
    required this.id,
    required this.categoryId,
    required this.limit,
    this.currencyCode = 'VND',
  });

  final String id;
  final String categoryId;
  final double limit;
  final String currencyCode;

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      id: json['id'] as String,
      categoryId: json['categoryId'] as String,
      limit: (json['limit'] as num).toDouble(),
      currencyCode: json['currencyCode'] as String? ?? AppCurrency.current.code,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryId': categoryId,
      'limit': limit,
      'currencyCode': currencyCode,
    };
  }
}
