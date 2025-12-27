import 'package:equatable/equatable.dart';
import 'package:frontend/domain/entity/room_entity.dart';

enum RoomStatus { initial, loading, success, failure }

class RoomState extends Equatable {
  final RoomStatus status;
  final List<RoomEntity> rooms;
  final String? errorMessage;
  final String? successMessage;

  const RoomState({
    this.status = RoomStatus.initial,
    this.rooms = const [],
    this.errorMessage,
    this.successMessage,
  });

  RoomState copyWith({
    RoomStatus? status,
    List<RoomEntity>? rooms,
    String? errorMessage,
    String? successMessage,
  }) {
    return RoomState(
      status: status ?? this.status,
      rooms: rooms ?? this.rooms,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [status, rooms, errorMessage, successMessage];
}
