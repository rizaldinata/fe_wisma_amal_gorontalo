import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/domain/usecase/schedule/schedule_usecases.dart';
import 'schedule_detail_event.dart';
import 'schedule_detail_state.dart';

class ScheduleDetailBloc extends Bloc<ScheduleDetailEvent, ScheduleDetailState> {
  final GetScheduleByIdUseCase getScheduleByIdUseCase;

  ScheduleDetailBloc({required this.getScheduleByIdUseCase})
      : super(ScheduleDetailInitial()) {
    on<FetchScheduleDetail>(_onFetchDetail);
  }

  Future<void> _onFetchDetail(
    FetchScheduleDetail event,
    Emitter<ScheduleDetailState> emit,
  ) async {
    emit(ScheduleDetailLoading());
    try {
      final schedule = await getScheduleByIdUseCase(event.id);
      emit(ScheduleDetailLoaded(schedule));
    } catch (e) {
      emit(ScheduleDetailError(e.toString()));
    }
  }
}
