abstract class FixedExpenseEvent {}

class FetchFixedExpenses extends FixedExpenseEvent {
  final String? jenis;
  final int? bulan;
  final int? tahun;
  FetchFixedExpenses({this.jenis, this.bulan, this.tahun});
}

class FetchFixedExpenseStatus extends FixedExpenseEvent {
  final int? bulan;
  final int? tahun;
  FetchFixedExpenseStatus({this.bulan, this.tahun});
}

class UpdateFixedExpense extends FixedExpenseEvent {
  final int id;
  final double amount;
  final String? notes;
  UpdateFixedExpense({required this.id, required this.amount, this.notes});
}

class GenerateFixedExpenses extends FixedExpenseEvent {
  final int? bulan;
  final int? tahun;
  GenerateFixedExpenses({this.bulan, this.tahun});
}
