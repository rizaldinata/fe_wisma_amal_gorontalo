import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecase/finance/get_fixed_expenses_usecase.dart';
import '../../../domain/usecase/finance/update_fixed_expense_usecase.dart';
import '../../../domain/usecase/finance/get_fixed_expense_status_usecase.dart';
import '../../../domain/usecase/finance/generate_fixed_expenses_usecase.dart';
import 'fixed_expense_event.dart';
import 'fixed_expense_state.dart';

class FixedExpenseBloc extends Bloc<FixedExpenseEvent, FixedExpenseState> {
  final GetFixedExpensesUseCase getFixedExpenses;
  final UpdateFixedExpenseUseCase updateFixedExpense;
  final GetFixedExpenseStatusUseCase getFixedExpenseStatus;
  final GenerateFixedExpensesUseCase generateFixedExpenses;

  FixedExpenseBloc({
    required this.getFixedExpenses,
    required this.updateFixedExpense,
    required this.getFixedExpenseStatus,
    required this.generateFixedExpenses,
  }) : super(FixedExpenseInitial()) {
    on<FetchFixedExpenses>(_onFetch);
    on<FetchFixedExpenseStatus>(_onFetchStatus);
    on<UpdateFixedExpense>(_onUpdate);
    on<GenerateFixedExpenses>(_onGenerate);
  }

  Future<void> _onFetch(FetchFixedExpenses event, Emitter<FixedExpenseState> emit) async {
    emit(FixedExpenseLoading());
    try {
      // Auto-generate entri bulan ini terlebih dahulu (idempotent)
      await generateFixedExpenses.execute();

      final entries = await getFixedExpenses.execute(
        jenis: event.jenis, bulan: event.bulan, tahun: event.tahun,
      );
      final status = await getFixedExpenseStatus.execute();
      emit(FixedExpenseLoaded(entries: entries, status: status));
    } catch (e) {
      emit(FixedExpenseError(_errorMessage(e)));
    }
  }

  Future<void> _onFetchStatus(FetchFixedExpenseStatus event, Emitter<FixedExpenseState> emit) async {
    try {
      final status = await getFixedExpenseStatus.execute(bulan: event.bulan, tahun: event.tahun);
      final current = state;
      final entries = current is FixedExpenseLoaded ? current.entries : <dynamic>[];
      emit(FixedExpenseLoaded(entries: entries.cast(), status: status));
    } catch (e) {
      emit(FixedExpenseError(_errorMessage(e)));
    }
  }

  Future<void> _onUpdate(UpdateFixedExpense event, Emitter<FixedExpenseState> emit) async {
    try {
      await updateFixedExpense.execute(event.id, event.amount, event.notes);
      emit(FixedExpenseOperationSuccess('Pengeluaran tetap berhasil diperbarui.'));
    } catch (e) {
      emit(FixedExpenseError(_errorMessage(e)));
    }
  }

  Future<void> _onGenerate(GenerateFixedExpenses event, Emitter<FixedExpenseState> emit) async {
    try {
      await generateFixedExpenses.execute(bulan: event.bulan, tahun: event.tahun);
    } catch (_) {
      // silent — generate bersifat optional/idempotent
    }
  }

  String _errorMessage(Object e) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map) {
        final msg = data['message'];
        if (msg != null) return msg.toString();
      }
    }
    return e.toString();
  }
}
