import 'package:equatable/equatable.dart';

abstract class RoomScheduleEvent extends Equatable {
  const RoomScheduleEvent();

  @override
  List<Object?> get props => [];
}

class FetchRoomSchedules extends RoomScheduleEvent {}
