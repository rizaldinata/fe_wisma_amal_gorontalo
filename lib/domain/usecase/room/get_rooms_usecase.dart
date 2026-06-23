import 'package:frontend/domain/entity/room_entity.dart';
import 'package:frontend/domain/repository/room_repository.dart';
import 'package:frontend/domain/usecase/usecase.dart';

class GetRoomsUseCase implements UseCase<List<RoomEntity>, bool?> {
  final RoomRepository repository;

  GetRoomsUseCase(this.repository);

  @override
  Future<List<RoomEntity>> call(bool? isHighlighted) async {
    return await repository.getRooms(isHighlighted: isHighlighted);
  }
}
