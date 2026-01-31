part of 'detail_room_bloc.dart';

class DetailRoomState extends Equatable {
  final FormzSubmissionStatus status;
  final FormzSubmissionStatus deleteStatus;
  final RoomEntity? room;
  final String? errorMessage;

  const DetailRoomState({
    this.status = FormzSubmissionStatus.initial,
    this.deleteStatus = FormzSubmissionStatus.initial,
    this.room,
    this.errorMessage,
  });

  copyWith({
    FormzSubmissionStatus? status,
    FormzSubmissionStatus? deleteStatus,
    RoomEntity? room,
    String? errorMessage,
  }) {
    return DetailRoomState(
      status: status ?? this.status,
      deleteStatus: deleteStatus ?? this.deleteStatus,
      room: room ?? this.room,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, deleteStatus, room, errorMessage];
}
