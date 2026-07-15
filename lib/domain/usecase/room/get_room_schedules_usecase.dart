import 'package:frontend/domain/entity/room/room_schedule_entity.dart';
import 'package:frontend/domain/repository/room_repository.dart';

class GetRoomSchedulesUseCase {
  final RoomRepository repository;

  GetRoomSchedulesUseCase(this.repository);

  Future<List<RoomScheduleEntity>> call() async {
    return await repository.getRoomSchedules();
  }
}
