import 'package:frontend/domain/entity/room_entity.dart';
import 'package:frontend/domain/repository/room_repository.dart';
import 'package:frontend/domain/usecase/usecase.dart';

class UpdateRoomUseCase implements UseCase<RoomEntity, RoomEntity> {
  final RoomRepository repository;

  UpdateRoomUseCase(this.repository);

  @override
  Future<RoomEntity> call(RoomEntity params) async {
    return await repository.updateRoom(params);
  }
}
