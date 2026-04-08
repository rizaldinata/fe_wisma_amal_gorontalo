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
  const SubmitFormRoomEvent({required this.roomData, required this.formMode});

  final RoomEntity roomData;
  final FormMode formMode;

  @override
  List<Object> get props => [roomData, formMode];
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
  const RemoveRoomImageEvent({required this.file});

  final ImageFile file;

  @override
  List<Object> get props => [file];
}

final class AddFacilityEvent extends FormRoomEvent {
  const AddFacilityEvent({required this.facility});

  final String facility;

  @override
  List<Object> get props => [facility];
}

final class RemoveFacilityEvent extends FormRoomEvent {
  const RemoveFacilityEvent({required this.index});

  final int index;

  @override
  List<Object> get props => [index];
}

final class UploadRoomImagesEvent extends FormRoomEvent {
  const UploadRoomImagesEvent();
}
