part of 'detail_room_bloc.dart';

sealed class DetailRoomEvent extends Equatable {
  const DetailRoomEvent();

  @override
  List<Object> get props => [];
}

final class LoadDetailRoomEvent extends DetailRoomEvent {
  final int roomId;

  const LoadDetailRoomEvent(this.roomId);

  @override
  List<Object> get props => [roomId];
}

final class UpdateRoomEvent extends DetailRoomEvent {
  final RoomEntity room;

  const UpdateRoomEvent(this.room);

  @override
  List<Object> get props => [room];
}

final class DeleteRoomEvent extends DetailRoomEvent {
  final int roomId;

  const DeleteRoomEvent(this.roomId);

  @override
  List<Object> get props => [roomId];
}
