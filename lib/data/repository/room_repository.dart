import 'package:frontend/data/datasource/room_datasource.dart';
import 'package:frontend/data/model/room/room_model.dart';
import 'package:frontend/domain/entity/room_entity.dart';

class RoomRepository {
  final RoomDatasource datasource;

  RoomRepository({required this.datasource});

  Future<List<RoomEntity>> getRooms() async {
    try {
      final response = await datasource.getRooms();
      return response.data.map((e) => e.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<RoomEntity> createRoom(RoomEntity room) async {
    try {
      final response = await datasource.createRoom(RoomModel.fromDomain(room));
      return response.data.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  Future<RoomEntity> getRoomById(int id) async {
    try {
      final response = await datasource.getRoomById(id);
      return response.data.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  Future<RoomEntity> updateRoom(int id, RoomEntity room) async {
    try {
      final response = await datasource.updateRoom(
        id,
        RoomModel.fromDomain(room),
      );
      return response.data.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deleteRoom(int id) async {
    return await datasource.deleteRoom(id);
  }
}
