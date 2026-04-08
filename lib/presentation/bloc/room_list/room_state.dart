import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:frontend/domain/entity/room_entity.dart';

class RoomState extends Equatable {
  final FormzSubmissionStatus status;
  final List<RoomEntity> rooms;
  List<RoomEntity> get availableRooms =>
      rooms.where((room) => room.status == RoomStatusEnum.available).toList();
  List<RoomEntity> get occupiedRooms =>
      rooms.where((room) => room.status == RoomStatusEnum.occupied).toList();
  List<RoomEntity> get maintenanceRooms =>
      rooms.where((room) => room.status == RoomStatusEnum.maintenance).toList();

  final String? errorMessage;
  final String? successMessage;
  final RoomEntity? selectedRoom;

  const RoomState({
    this.status = FormzSubmissionStatus.initial,
    this.rooms = const [],
    this.errorMessage,
    this.successMessage,
    this.selectedRoom,
  });

  RoomState copyWith({
    FormzSubmissionStatus? status,
    List<RoomEntity>? rooms,
    RoomEntity? selectedRoom,
    String? errorMessage,
    String? successMessage,
  }) {
    return RoomState(
      status: status ?? this.status,
      rooms: rooms ?? this.rooms,
      errorMessage: errorMessage,
      successMessage: successMessage,
      selectedRoom: selectedRoom ?? this.selectedRoom,
    );
  }

  @override
  List<Object?> get props => [status, rooms, errorMessage, successMessage];
}
