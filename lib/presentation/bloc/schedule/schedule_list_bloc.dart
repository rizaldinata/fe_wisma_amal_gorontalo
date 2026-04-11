import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/domain/usecase/schedule/schedule_usecases.dart';
import 'schedule_list_event.dart';
import 'schedule_list_state.dart';

class ScheduleListBloc extends Bloc<ScheduleListEvent, ScheduleListState> {
  final GetSchedulesUseCase getSchedulesUseCase;

  ScheduleListBloc({required this.getSchedulesUseCase})
      : super(ScheduleListInitial()) {
    on<FetchSchedules>(_onFetchSchedules);
  }

  Future<void> _onFetchSchedules(
    FetchSchedules event,
    Emitter<ScheduleListState> emit,
  ) async {
    emit(ScheduleListLoading());
    try {
      final schedules = await getSchedulesUseCase();
      emit(ScheduleListLoaded(schedules));
    } catch (e) {
      emit(ScheduleListError(e.toString()));
    }
  }
}
