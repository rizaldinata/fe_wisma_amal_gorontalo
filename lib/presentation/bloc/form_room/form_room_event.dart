part of 'form_room_bloc.dart';

sealed class FormRoomEvent extends Equatable {
  const FormRoomEvent();

  @override
  List<Object?> get props => [];
}

final class LoadFormRoomEvent extends FormRoomEvent {
  const LoadFormRoomEvent({this.roomId});

  final int? roomId;

  @override
  List<Object?> get props => [roomId];
}

final class SubmitFormRoomEvent extends FormRoomEvent {
  const SubmitFormRoomEvent({required this.roomData});

  final RoomEntity roomData;

  @override
  List<Object> get props => [roomData];
}

final class AddFormRoomEvent extends FormRoomEvent {
  const AddFormRoomEvent({required this.roomData});

  final RoomEntity roomData;

  @override
  List<Object> get props => [roomData];
}

final class EditFormRoomEvent extends FormRoomEvent {
  const EditFormRoomEvent({required this.roomData});

  final RoomEntity roomData;

  @override
  List<Object> get props => [roomData];
}

final class PickRoomImagesEvent extends FormRoomEvent {}

final class RemoveRoomImageEvent extends FormRoomEvent {
  const RemoveRoomImageEvent({required this.index});

  final String index;

  @override
  List<Object> get props => [index];
}
