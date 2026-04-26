import 'package:equatable/equatable.dart';
import 'package:frontend/domain/entity/schedule_entity.dart';

abstract class ScheduleDetailState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ScheduleDetailInitial extends ScheduleDetailState {}

class ScheduleDetailLoading extends ScheduleDetailState {}

class ScheduleDetailLoaded extends ScheduleDetailState {
  final ScheduleEntity schedule;
  ScheduleDetailLoaded(this.schedule);

  @override
  List<Object?> get props => [schedule];
}

class ScheduleDetailError extends ScheduleDetailState {
  final String message;
  ScheduleDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
