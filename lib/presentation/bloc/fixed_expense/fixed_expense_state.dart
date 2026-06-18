import '../../../domain/entity/finance/fixed_expense_entry_entity.dart';
import '../../../domain/entity/finance/fixed_expense_status_entity.dart';

abstract class FixedExpenseState {}

class FixedExpenseInitial extends FixedExpenseState {}

class FixedExpenseLoading extends FixedExpenseState {}

class FixedExpenseLoaded extends FixedExpenseState {
  final List<FixedExpenseEntryEntity> entries;
  final FixedExpenseStatusEntity? status;
  FixedExpenseLoaded({required this.entries, this.status});
}

class FixedExpenseOperationSuccess extends FixedExpenseState {
  final String message;
  FixedExpenseOperationSuccess(this.message);
}

class FixedExpenseError extends FixedExpenseState {
  final String message;
  FixedExpenseError(this.message);
}
