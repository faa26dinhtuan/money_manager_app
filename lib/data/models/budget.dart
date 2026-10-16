class Budget {
  const Budget({
    required this.id,
    required this.categoryId,
    required this.limit,
  });

  final String id;
  final String categoryId;
  final double limit;

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      id: json['id'] as String,
      categoryId: json['categoryId'] as String,
      limit: (json['limit'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryId': categoryId,
      'limit': limit,
    };
  }
}
