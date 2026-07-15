import '../entity/finance/fixed_expense_entry_entity.dart';
import '../entity/finance/fixed_expense_status_entity.dart';

abstract class FixedExpenseRepository {
  Future<List<FixedExpenseEntryEntity>> getFixedExpenses({String? jenis, int? bulan, int? tahun});
  Future<FixedExpenseEntryEntity> updateFixedExpense(int id, double amount, String? notes);
  Future<FixedExpenseStatusEntity> getFixedExpenseStatus({int? bulan, int? tahun});
  Future<int> generateBulanIni({int? bulan, int? tahun});
}
