import 'package:equatable/equatable.dart';
import 'package:frontend/domain/entity/schedule_entity.dart';

abstract class ScheduleActionState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ScheduleActionInitial extends ScheduleActionState {}

class ScheduleActionSubmitting extends ScheduleActionState {}

class ScheduleActionSuccess extends ScheduleActionState {
  final String message;
  final ScheduleEntity? schedule;
  ScheduleActionSuccess({required this.message, this.schedule});
  @override
  List<Object?> get props => [message, schedule];
}

class ScheduleActionFailure extends ScheduleActionState {
  final String message;
  ScheduleActionFailure(this.message);
  @override
  List<Object?> get props => [message];
}
