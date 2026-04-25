import 'package:file_picker/file_picker.dart';
import 'package:frontend/domain/entity/room/room_schedule_entity.dart';
import 'package:frontend/domain/entity/room_entity.dart';

abstract class RoomRepository {
  Future<List<RoomEntity>> getRooms();
  Future<List<RoomScheduleEntity>> getRoomSchedules();
  Future<RoomEntity> createRoom(RoomEntity room);
  Future<RoomEntity> getRoomById(int id);
  Future<RoomEntity> updateRoom(RoomEntity room);
  Future<bool> deleteRoom(int id);
  Future<bool> uploadRoomImage(int roomId, List<PlatformFile> files);
  Future<bool> deleteRoomImage(int roomId, int imageId);
}
