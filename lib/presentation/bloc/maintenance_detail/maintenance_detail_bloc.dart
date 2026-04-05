import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/network/exception.dart';
import '../../../../domain/usecase/maintenance/get_detail_usecase.dart';
import 'maintenance_detail_event.dart';
import 'maintenance_detail_state.dart';

class MaintenanceDetailBloc extends Bloc<MaintenanceDetailEvent, MaintenanceDetailState> {
  final GetDetailUseCase getDetailUseCase;

  MaintenanceDetailBloc({
    required this.getDetailUseCase,
  }) : super(MaintenanceDetailInitial()) {
    on<FetchMaintenanceDetail>(_onFetchDetail);
  }

  Future<void> _onFetchDetail(
    FetchMaintenanceDetail event,
    Emitter<MaintenanceDetailState> emit,
  ) async {
    emit(MaintenanceDetailLoading());
    try {
      final result = await getDetailUseCase(event.id);
      emit(MaintenanceDetailLoaded(result));
    } on AppException catch (e) {
      emit(MaintenanceDetailError(e.message));
    } catch (e) {
      emit(MaintenanceDetailError(e.toString()));
    }
  }
}
