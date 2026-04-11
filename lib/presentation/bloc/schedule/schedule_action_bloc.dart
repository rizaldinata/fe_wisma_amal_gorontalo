import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/domain/usecase/schedule/schedule_usecases.dart';
import 'package:frontend/domain/usecase/schedule/add_schedule_update_usecase.dart';
import 'schedule_action_event.dart';
import 'schedule_action_state.dart';

class ScheduleActionBloc
    extends Bloc<ScheduleActionEvent, ScheduleActionState> {
  final CreateScheduleUseCase createScheduleUseCase;
  final UpdateScheduleUseCase updateScheduleUseCase;
  final DeleteScheduleUseCase deleteScheduleUseCase;
  final AddScheduleUpdateUseCase addScheduleUpdateUseCase;

  ScheduleActionBloc({
    required this.createScheduleUseCase,
    required this.updateScheduleUseCase,
    required this.deleteScheduleUseCase,
    required this.addScheduleUpdateUseCase,
  }) : super(ScheduleActionInitial()) {
    on<CreateSchedule>(_onCreate);
    on<UpdateSchedule>(_onUpdate);
    on<DeleteSchedule>(_onDelete);
    on<SubmitScheduleUpdate>(_onSubmitUpdate);
  }

  Future<void> _onCreate(
    CreateSchedule event,
    Emitter<ScheduleActionState> emit,
  ) async {
    emit(ScheduleActionSubmitting());
    try {
      final result = await createScheduleUseCase(event.data);
      emit(ScheduleActionSuccess(
        message: 'Jadwal berhasil ditambahkan',
        schedule: result,
      ));
    } catch (e) {
      emit(ScheduleActionFailure(e.toString()));
    }
  }

  Future<void> _onUpdate(
    UpdateSchedule event,
    Emitter<ScheduleActionState> emit,
  ) async {
    emit(ScheduleActionSubmitting());
    try {
      final result = await updateScheduleUseCase(event.id, event.data);
      emit(ScheduleActionSuccess(
        message: 'Jadwal berhasil diperbarui',
        schedule: result,
      ));
    } catch (e) {
      emit(ScheduleActionFailure(e.toString()));
    }
  }

  Future<void> _onDelete(
    DeleteSchedule event,
    Emitter<ScheduleActionState> emit,
  ) async {
    emit(ScheduleActionSubmitting());
    try {
      await deleteScheduleUseCase(event.id);
      emit(ScheduleActionSuccess(message: 'Jadwal berhasil dihapus'));
    } catch (e) {
      emit(ScheduleActionFailure(e.toString()));
    }
  }

  Future<void> _onSubmitUpdate(
    SubmitScheduleUpdate event,
    Emitter<ScheduleActionState> emit,
  ) async {
    emit(ScheduleActionSubmitting());
    try {
      await addScheduleUpdateUseCase(
        scheduleId: event.scheduleId,
        notes: event.notes,
        status: event.status,
      );
      emit(ScheduleActionSuccess(message: 'Update berhasil ditambahkan'));
    } catch (e) {
      emit(ScheduleActionFailure(e.toString()));
    }
  }
}
