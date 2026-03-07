import 'package:frontend/domain/entity/room_entity.dart';
import 'package:frontend/domain/repository/room_repository.dart';
import 'package:frontend/domain/usecase/usecase.dart';

class GetRoomByIdUseCase implements UseCase<RoomEntity, int> {
  final RoomRepository repository;

  GetRoomByIdUseCase(this.repository);

  @override
  Future<RoomEntity> call(int params) async {
    return await repository.getRoomById(params);
  }
}
