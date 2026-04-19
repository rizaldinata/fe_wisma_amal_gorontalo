import '../../entity/finance/expense_entity.dart';
import '../../repository/finance_repository.dart';

class GetExpensesUseCase {
  final FinanceRepository repository;

  GetExpensesUseCase(this.repository);

  Future<List<ExpenseEntity>> execute() async {
    return await repository.getExpenses();
  }
}
