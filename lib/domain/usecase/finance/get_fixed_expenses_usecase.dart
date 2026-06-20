import '../../entity/finance/fixed_expense_entry_entity.dart';
import '../../repository/fixed_expense_repository.dart';

class GetFixedExpensesUseCase {
  final FixedExpenseRepository repository;
  GetFixedExpensesUseCase(this.repository);

  Future<List<FixedExpenseEntryEntity>> execute({String? jenis, int? bulan, int? tahun}) {
    return repository.getFixedExpenses(jenis: jenis, bulan: bulan, tahun: tahun);
  }
}
