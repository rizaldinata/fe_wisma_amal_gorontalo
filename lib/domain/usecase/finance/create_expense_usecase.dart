import '../../entity/finance/expense_entity.dart';
import '../../repository/finance_repository.dart';

class CreateExpenseUseCase {
  final FinanceRepository repository;

  CreateExpenseUseCase(this.repository);

  Future<ExpenseEntity> execute(ExpenseEntity expense) async {
    return await repository.createExpense(expense);
  }
}
