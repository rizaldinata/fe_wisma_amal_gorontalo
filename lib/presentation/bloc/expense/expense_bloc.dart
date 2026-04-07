import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/usecase/finance/get_expenses_usecase.dart';
import '../../../../domain/usecase/finance/create_expense_usecase.dart';
import '../../../../domain/usecase/finance/update_expense_usecase.dart';
import '../../../../domain/usecase/finance/delete_expense_usecase.dart';
import 'expense_event.dart';
import 'expense_state.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final GetExpensesUseCase getExpensesUseCase;
  final CreateExpenseUseCase createExpenseUseCase;
  final UpdateExpenseUseCase updateExpenseUseCase;
  final DeleteExpenseUseCase deleteExpenseUseCase;

  ExpenseBloc({
    required this.getExpensesUseCase,
    required this.createExpenseUseCase,
    required this.updateExpenseUseCase,
    required this.deleteExpenseUseCase,
  }) : super(ExpenseInitial()) {
    on<FetchExpenses>((event, emit) async {
      emit(ExpenseLoading());
      try {
        final expenses = await getExpensesUseCase.execute();
        emit(ExpenseLoaded(expenses));
      } catch (e) {
        emit(ExpenseError(e.toString()));
      }
    });

    on<CreateExpense>((event, emit) async {
      emit(ExpenseLoading());
      try {
        await createExpenseUseCase.execute(event.expense);
        emit(const ExpenseOperationSuccess("Pengeluaran berhasil ditambahkan"));
        // add(FetchExpenses()); <-- Dihapus, dipindahkan ke UI
      } catch (e) {
        emit(ExpenseError(e.toString()));
      }
    });

    on<UpdateExpense>((event, emit) async {
      emit(ExpenseLoading());
      try {
        await updateExpenseUseCase.execute(event.expense);
        emit(const ExpenseOperationSuccess("Pengeluaran berhasil diperbarui"));
      } catch (e) {
        emit(ExpenseError(e.toString()));
      }
    });

    on<DeleteExpense>((event, emit) async {
      emit(ExpenseLoading());
      try {
        await deleteExpenseUseCase.execute(event.id);
        emit(const ExpenseOperationSuccess("Pengeluaran berhasil dihapus"));
      } catch (e) {
        emit(ExpenseError(e.toString()));
      }
    });
  }
}