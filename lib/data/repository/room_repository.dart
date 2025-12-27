import 'package:frontend/data/datasource/room_datasource.dart';
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
      final data = {
        'number': room.number,
        'type': room.type,
        'price': room.price,
        'status': room.status,
        'description': room.description,
      };
      final response = await datasource.createRoom(data);
      return response.data.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  Future<RoomEntity> updateRoom(int id, RoomEntity room) async {
    try {
      final data = {
        'number': room.number,
        'type': room.type,
        'price': room.price,
        'status': room.status,
        'description': room.description,
      };
      final response = await datasource.updateRoom(id, data);
      return response.data.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deleteRoom(int id) async {
    return await datasource.deleteRoom(id);
  }
}
