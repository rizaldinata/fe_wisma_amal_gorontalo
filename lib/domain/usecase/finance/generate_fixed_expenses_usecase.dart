import '../../repository/fixed_expense_repository.dart';

class GenerateFixedExpensesUseCase {
  final FixedExpenseRepository repository;
  GenerateFixedExpensesUseCase(this.repository);

  Future<int> execute({int? bulan, int? tahun}) {
    return repository.generateBulanIni(bulan: bulan, tahun: tahun);
  }
}
