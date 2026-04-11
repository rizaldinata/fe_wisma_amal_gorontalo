import 'package:equatable/equatable.dart';
import 'package:frontend/domain/entity/schedule_entity.dart';

abstract class ScheduleListState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ScheduleListInitial extends ScheduleListState {}

class ScheduleListLoading extends ScheduleListState {}

class ScheduleListLoaded extends ScheduleListState {
  final List<ScheduleEntity> schedules;
  ScheduleListLoaded(this.schedules);

  @override
  List<Object?> get props => [schedules];
}

class ScheduleListError extends ScheduleListState {
  final String message;
  ScheduleListError(this.message);

  @override
  List<Object?> get props => [message];
}
