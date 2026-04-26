import '../../../domain/entity/finance/expense_entity.dart';

class ExpenseModel extends ExpenseEntity {
  ExpenseModel({
    required super.id,
    required super.title,
    required super.amount,
    required super.date,
    super.category,
    super.notes,
    super.isIntegrated,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      date: json['expense_date'] ?? json['created_at'] ?? '',
      category: json['source'],
      notes: json['description'],
      isIntegrated: json['is_integrated'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'amount': amount,
      'expense_date': date,      
      'category': category,
      'description': notes,  
      'is_integrated': isIntegrated,    
    };
  }
}
