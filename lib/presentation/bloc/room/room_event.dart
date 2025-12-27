import 'package:equatable/equatable.dart';
import 'package:frontend/domain/entity/room_entity.dart';

abstract class RoomEvent extends Equatable {
  const RoomEvent();

  @override
  List<Object> get props => [];
}

class GetRoomsEvent extends RoomEvent {}

class AddRoomEvent extends RoomEvent {
  final RoomEntity room;
  const AddRoomEvent(this.room);
}

class UpdateRoomEvent extends RoomEvent {
  final int id;
  final RoomEntity room;
  const UpdateRoomEvent(this.id, this.room);
}

class DeleteRoomEvent extends RoomEvent {
  final int id;
  const DeleteRoomEvent(this.id);
}
