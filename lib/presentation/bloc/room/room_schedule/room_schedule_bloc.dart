import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/domain/usecase/room/get_room_schedules_usecase.dart';
import 'room_schedule_event.dart';
import 'room_schedule_state.dart';

class RoomScheduleBloc extends Bloc<RoomScheduleEvent, RoomScheduleState> {
  final GetRoomSchedulesUseCase getRoomSchedulesUseCase;

  RoomScheduleBloc({required this.getRoomSchedulesUseCase}) : super(RoomScheduleInitial()) {
    on<FetchRoomSchedules>((event, emit) async {
      emit(RoomScheduleLoading());
      try {
        final schedules = await getRoomSchedulesUseCase();
        emit(RoomScheduleLoaded(schedules));
      } catch (e) {
        emit(RoomScheduleError(e.toString()));
      }
    });
  }
}
