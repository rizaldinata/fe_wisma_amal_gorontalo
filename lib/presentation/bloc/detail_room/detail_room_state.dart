part of 'detail_room_bloc.dart';

class DetailRoomState extends Equatable {
  final FormzSubmissionStatus status;
  final RoomEntity? room;
  final String? errorMessage;

  const DetailRoomState({
    this.status = FormzSubmissionStatus.initial,
    this.room,
    this.errorMessage,
  });

  copyWith({
    FormzSubmissionStatus? status,
    RoomEntity? room,
    String? errorMessage,
  }) {
    return DetailRoomState(
      status: status ?? this.status,
      room: room ?? this.room,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, room, errorMessage];
}
