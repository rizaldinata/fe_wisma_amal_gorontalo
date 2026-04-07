import '../../entity/finance/expense_entity.dart';
import '../../repository/finance_repository.dart';

class UpdateExpenseUseCase {
  final FinanceRepository repository;

  UpdateExpenseUseCase(this.repository);

  Future<ExpenseEntity> execute(ExpenseEntity expense) async {
    return await repository.updateExpense(expense);
  }
}
