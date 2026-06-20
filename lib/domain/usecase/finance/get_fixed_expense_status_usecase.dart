import '../../entity/finance/fixed_expense_status_entity.dart';
import '../../repository/fixed_expense_repository.dart';

class GetFixedExpenseStatusUseCase {
  final FixedExpenseRepository repository;
  GetFixedExpenseStatusUseCase(this.repository);

  Future<FixedExpenseStatusEntity> execute({int? bulan, int? tahun}) {
    return repository.getFixedExpenseStatus(bulan: bulan, tahun: tahun);
  }
}
