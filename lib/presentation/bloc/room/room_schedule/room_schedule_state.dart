import 'package:equatable/equatable.dart';
import 'package:frontend/domain/entity/room/room_schedule_entity.dart';

abstract class RoomScheduleState extends Equatable {
  const RoomScheduleState();

  @override
  List<Object?> get props => [];
}

class RoomScheduleInitial extends RoomScheduleState {}

class RoomScheduleLoading extends RoomScheduleState {}

class RoomScheduleLoaded extends RoomScheduleState {
  final List<RoomScheduleEntity> schedules;

  const RoomScheduleLoaded(this.schedules);

  @override
  List<Object?> get props => [schedules];
}

class RoomScheduleError extends RoomScheduleState {
  final String message;

  const RoomScheduleError(this.message);

  @override
  List<Object?> get props => [message];
}
