import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/domain/repository/dashboard_repository.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardRepository repository;

  DashboardBloc({required this.repository}) : super(DashboardInitial()) {
    on<FetchAdminDashboard>(_onFetchAdminDashboard);
    on<FetchResidentDashboard>(_onFetchResidentDashboard);
  }

  Future<void> _onFetchAdminDashboard(
    FetchAdminDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());
    try {
      final result = await repository.getAdminDashboard();
      emit(AdminDashboardLoaded(result));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }

  Future<void> _onFetchResidentDashboard(
    FetchResidentDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());
    try {
      final result = await repository.getResidentDashboard();
      emit(ResidentDashboardLoaded(result));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }
}
