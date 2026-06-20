import '../../domain/entity/finance/fixed_expense_entry_entity.dart';
import '../../domain/entity/finance/fixed_expense_status_entity.dart';
import '../../domain/repository/fixed_expense_repository.dart';
import '../datasource/fixed_expense_datasource.dart';

class FixedExpenseRepositoryImpl implements FixedExpenseRepository {
  final FixedExpenseRemoteDatasource _datasource;
  FixedExpenseRepositoryImpl(this._datasource);

  @override
  Future<List<FixedExpenseEntryEntity>> getFixedExpenses({String? jenis, int? bulan, int? tahun}) =>
      _datasource.getFixedExpenses(jenis: jenis, bulan: bulan, tahun: tahun);

  @override
  Future<FixedExpenseEntryEntity> updateFixedExpense(int id, double amount, String? notes) {
    final data = <String, dynamic>{
      'amount': amount,
      if (notes != null) 'notes': notes,
    };
    return _datasource.updateFixedExpense(id, data);
  }

  @override
  Future<FixedExpenseStatusEntity> getFixedExpenseStatus({int? bulan, int? tahun}) =>
      _datasource.getFixedExpenseStatus(bulan: bulan, tahun: tahun);

  @override
  Future<int> generateBulanIni({int? bulan, int? tahun}) =>
      _datasource.generateBulanIni(bulan: bulan, tahun: tahun);
}
