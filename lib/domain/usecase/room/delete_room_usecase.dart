import 'package:frontend/domain/repository/room_repository.dart';
import 'package:frontend/domain/usecase/usecase.dart';

class DeleteRoomUseCase implements UseCase<bool, int> {
  final RoomRepository repository;

  DeleteRoomUseCase(this.repository);

  @override
  Future<bool> call(int params) async {
    return await repository.deleteRoom(params);
  }
}
