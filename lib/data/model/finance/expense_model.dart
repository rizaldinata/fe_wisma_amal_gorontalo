import '../../../domain/entity/finance/expense_entity.dart';

class ExpenseModel extends ExpenseEntity {
  ExpenseModel({
    required super.id,
    required super.title,
    required super.amount,
    required super.date,
    super.category,
    super.notes,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    String safeDate = json['expense_date']?.toString() ?? '';
    if (safeDate.isEmpty) {
      safeDate = DateTime.now().toIso8601String();
    }

    return ExpenseModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      amount: json['amount'] != null
          ? double.tryParse(json['amount'].toString()) ?? 0.0
          : 0.0,
      date: safeDate,
      category: json['category'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'amount': amount,
      'expense_date': date,      
      'category': category,
      'description': notes,      
    };
  }
}
