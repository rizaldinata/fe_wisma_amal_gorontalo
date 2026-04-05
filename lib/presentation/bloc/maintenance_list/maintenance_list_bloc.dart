import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/network/exception.dart';
import '../../../../domain/usecase/maintenance/get_my_requests_usecase.dart';
import '../../../../domain/usecase/maintenance/get_all_requests_usecase.dart';
import '../../../../domain/usecase/usecase.dart';
import 'maintenance_list_event.dart';
import 'maintenance_list_state.dart';

class MaintenanceListBloc extends Bloc<MaintenanceListEvent, MaintenanceListState> {
  final GetMyRequestsUseCase getMyRequestsUseCase;
  final GetAllRequestsUseCase getAllRequestsUseCase;

  MaintenanceListBloc({
    required this.getMyRequestsUseCase,
    required this.getAllRequestsUseCase,
  }) : super(MaintenanceListInitial()) {
    on<FetchMyMaintenanceRequests>(_onFetchMyRequests);
    on<FetchAllMaintenanceRequests>(_onFetchAllRequests);
  }

  Future<void> _onFetchMyRequests(
    FetchMyMaintenanceRequests event,
    Emitter<MaintenanceListState> emit,
  ) async {
    emit(MaintenanceListLoading());
    try {
      final results = await getMyRequestsUseCase(NoParams());
      emit(MaintenanceListLoaded(results));
    } on AppException catch (e) {
      emit(MaintenanceListError(e.message));
    } catch (e) {
      emit(MaintenanceListError(e.toString()));
    }
  }

  Future<void> _onFetchAllRequests(
    FetchAllMaintenanceRequests event,
    Emitter<MaintenanceListState> emit,
  ) async {
    emit(MaintenanceListLoading());
    try {
      final results = await getAllRequestsUseCase(NoParams());
      emit(MaintenanceListLoaded(results));
    } on AppException catch (e) {
      emit(MaintenanceListError(e.message));
    } catch (e) {
      emit(MaintenanceListError(e.toString()));
    }
  }
}
