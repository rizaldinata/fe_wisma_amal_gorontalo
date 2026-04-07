class ExpenseEntity {
  final int id;
  final String title;
  final double amount;
  final String date;
  final String? category;
  final String? notes;

  ExpenseEntity({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    this.category,
    this.notes,
  });
}
