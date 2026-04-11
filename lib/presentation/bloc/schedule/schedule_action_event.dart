import 'package:equatable/equatable.dart';
import 'package:frontend/domain/entity/schedule_entity.dart';

abstract class ScheduleActionEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CreateSchedule extends ScheduleActionEvent {
  final ScheduleEntity data;
  CreateSchedule(this.data);
  @override
  List<Object?> get props => [data];
}

class UpdateSchedule extends ScheduleActionEvent {
  final int id;
  final ScheduleEntity data;
  UpdateSchedule(this.id, this.data);
  @override
  List<Object?> get props => [id, data];
}

class DeleteSchedule extends ScheduleActionEvent {
  final int id;
  DeleteSchedule(this.id);
  @override
  List<Object?> get props => [id];
}

class SubmitScheduleUpdate extends ScheduleActionEvent {
  final int scheduleId;
  final String notes;
  final String? status;

  SubmitScheduleUpdate({
    required this.scheduleId,
    required this.notes,
    this.status,
  });

  @override
  List<Object?> get props => [scheduleId, notes, status];
}
