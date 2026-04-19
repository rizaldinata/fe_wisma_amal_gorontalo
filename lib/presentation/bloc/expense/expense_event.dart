import 'package:equatable/equatable.dart';
import '../../../../domain/entity/finance/expense_entity.dart';

abstract class ExpenseEvent extends Equatable {
  const ExpenseEvent();

  @override
  List<Object?> get props => [];
}

class FetchExpenses extends ExpenseEvent {}

class CreateExpense extends ExpenseEvent {
  final ExpenseEntity expense;

  const CreateExpense(this.expense);

  @override
  List<Object?> get props => [expense];
}

class UpdateExpense extends ExpenseEvent {
  final ExpenseEntity expense;

  const UpdateExpense(this.expense);

  @override
  List<Object?> get props => [expense];
}

class DeleteExpense extends ExpenseEvent {
  final int id;

  const DeleteExpense(this.id);

  @override
  List<Object?> get props => [id];
}
