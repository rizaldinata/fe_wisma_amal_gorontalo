import '../../repository/finance_repository.dart';

class DeleteExpenseUseCase {
  final FinanceRepository repository;

  DeleteExpenseUseCase(this.repository);

  Future<void> execute(int id) async {
    return await repository.deleteExpense(id);
  }
}
