import 'package:frontend/domain/entity/room_entity.dart';
import 'package:frontend/domain/repository/room_repository.dart';
import 'package:frontend/domain/usecase/usecase.dart';

class GetRoomsUseCase implements UseCase<List<RoomEntity>, NoParams> {
  final RoomRepository repository;

  GetRoomsUseCase(this.repository);

  @override
  Future<List<RoomEntity>> call(NoParams params) async {
    return await repository.getRooms();
  }
}
