import '../../entity/finance/fixed_expense_entry_entity.dart';
import '../../repository/fixed_expense_repository.dart';

class UpdateFixedExpenseUseCase {
  final FixedExpenseRepository repository;
  UpdateFixedExpenseUseCase(this.repository);

  Future<FixedExpenseEntryEntity> execute(int id, double amount, String? notes) {
    return repository.updateFixedExpense(id, amount, notes);
  }
}
