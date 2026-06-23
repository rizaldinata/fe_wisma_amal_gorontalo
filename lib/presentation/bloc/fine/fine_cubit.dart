import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecase/finance/cancel_fine_usecase.dart';
import '../../../domain/usecase/finance/create_fine_usecase.dart';
import '../../../domain/usecase/finance/get_all_fines_usecase.dart';
import '../../../domain/usecase/finance/waive_fine_usecase.dart';
import 'fine_state.dart';

class FineCubit extends Cubit<FineState> {
  final GetAllFinesUseCase _getAllFines;
  final CreateFineUseCase _createFine;
  final WaiveFineUseCase _waiveFine;
  final CancelFineUseCase _cancelFine;

  FineCubit({
    required GetAllFinesUseCase getAllFines,
    required CreateFineUseCase createFine,
    required WaiveFineUseCase waiveFine,
    required CancelFineUseCase cancelFine,
  })  : _getAllFines = getAllFines,
        _createFine = createFine,
        _waiveFine = waiveFine,
        _cancelFine = cancelFine,
        super(FineInitial());

  Future<void> loadFines({String? status}) async {
    final current = state is FineLoaded
        ? (state as FineLoaded).fines
        : state is FineOperationSuccess
            ? (state as FineOperationSuccess).fines
            : null;
    emit(current != null ? FineRefreshing(current) : FineLoading());
    try {
      final fines = await _getAllFines.execute(status: status);
      emit(FineLoaded(fines));
    } catch (e) {
      emit(FineError(e.toString()));
    }
  }

  Future<void> createFine({required int tenantUserId, required double amount, required String reason}) async {
    final current = state is FineLoaded ? (state as FineLoaded).fines : <dynamic>[];
    try {
      final fine = await _createFine.execute(tenantUserId: tenantUserId, amount: amount, reason: reason);
      final updated = [fine, ...current];
      emit(FineOperationSuccess('Denda berhasil dibuat dan notifikasi telah dikirim.', List.from(updated)));
    } catch (e) {
      emit(FineError(e.toString()));
    }
  }

  Future<void> waiveFine(int fineId, String waiveReason) async {
    try {
      final updated = await _waiveFine.execute(fineId, waiveReason);
      if (state is FineLoaded) {
        final updatedList = (state as FineLoaded).fines.map((f) => f.id == fineId ? updated : f).toList();
        emit(FineOperationSuccess('Denda berhasil dimaafkan.', updatedList));
      }
    } catch (e) {
      emit(FineError(e.toString()));
    }
  }

  Future<void> cancelFine(int fineId) async {
    try {
      final updated = await _cancelFine.execute(fineId);
      if (state is FineLoaded) {
        final updatedList = (state as FineLoaded).fines.map((f) => f.id == fineId ? updated : f).toList();
        emit(FineOperationSuccess('Denda berhasil dibatalkan.', updatedList));
      }
    } catch (e) {
      emit(FineError(e.toString()));
    }
  }
}
