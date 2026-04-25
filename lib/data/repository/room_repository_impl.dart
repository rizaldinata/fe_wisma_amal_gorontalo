import 'package:file_picker/file_picker.dart';
import 'package:frontend/data/datasource/room_datasource.dart';
import 'package:frontend/data/model/room/room_model.dart';
import 'package:frontend/domain/entity/room/room_schedule_entity.dart';
import 'package:frontend/domain/entity/room_entity.dart';

import 'package:frontend/domain/repository/room_repository.dart';

class RoomRepositoryImpl implements RoomRepository {
  final RoomDatasource datasource;

  RoomRepositoryImpl({required this.datasource});

  @override
  Future<List<RoomEntity>> getRooms() async {
    try {
      final response = await datasource.getRooms();
      return response.data.map((e) => e.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<RoomScheduleEntity>> getRoomSchedules() async {
    try {
      final response = await datasource.getRoomSchedules();
      return response.data; // Model extends Entity so it's compatible
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<RoomEntity> createRoom(RoomEntity room) async {
    try {
      final response = await datasource.createRoom(RoomModel.fromDomain(room));
      return response.data.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<RoomEntity> getRoomById(int id) async {
    try {
      final response = await datasource.getRoomById(id);
      return response.data.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<RoomEntity> updateRoom(RoomEntity room) async {
    try {
      final response = await datasource.updateRoom(RoomModel.fromDomain(room));
      return response.data.toEntity();
    } catch (e) {
      print('error at room repository updateRoom: $e');
      rethrow;
    }
  }

  @override
  Future<bool> deleteRoom(int id) async {
    return await datasource.deleteRoom(id);
  }

  @override
  Future<bool> uploadRoomImage(int roomId, List<PlatformFile> files) async {
    return await datasource.uploadRoomImage(files: files, roomId: roomId);
  }

  @override
  Future<bool> deleteRoomImage(int roomId, int imageId) async {
    return await datasource.deleteRoomImage(roomId: roomId, imageId: imageId);
  }
}
