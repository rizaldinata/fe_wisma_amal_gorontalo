import 'package:frontend/core/constant/endpoint_constant.dart';
import 'package:frontend/core/services/network/dio_client.dart';
import 'package:frontend/data/model/base_response_model.dart';
import 'package:frontend/data/model/room/room_model.dart';

class RoomDatasource {
  final DioClient dioClient;

  RoomDatasource({required this.dioClient});

  // GET ALL ROOMS
  Future<BaseResponseModel<List<RoomModel>>> getRooms() async {
    try {
      final response = await dioClient.get(EndpointConstant.roomsEndpoint);

      return BaseResponseModel<List<RoomModel>>.fromJson(response.data, (json) {
        // Parsing aman: pastikan json adalah List sebelum di-map
        if (json is List) {
          return json.map((e) => RoomModel.fromJson(e)).toList();
        }
        return [];
      });
    } catch (e) {
      rethrow;
    }
  }

  // CREATE ROOM
  Future<BaseResponseModel<RoomModel>> createRoom(
    RoomModel data,
  ) async {
    try {
      final response = await dioClient.post(
        EndpointConstant.roomsEndpoint,
        data: data.toJson(),
      );
      return BaseResponseModel<RoomModel>.fromJson(
        response.data,
        (json) => RoomModel.fromJson(json),
      );
    } catch (e) {
      rethrow;
    }
  }

  // UPDATE ROOM
  Future<BaseResponseModel<RoomModel>> updateRoom(
    int id,
    RoomModel data,
  ) async {
    try {
      final response = await dioClient.put(
        '${EndpointConstant.roomsEndpoint}/$id',
        data: data.toJson(),
      );
      return BaseResponseModel<RoomModel>.fromJson(
        response.data,
        (json) => RoomModel.fromJson(json),
      );
    } catch (e) {
      rethrow;
    }
  }

  // DELETE ROOM
  Future<bool> deleteRoom(int id) async {
    try {
      final response = await dioClient.delete(
        '${EndpointConstant.roomsEndpoint}/$id',
      );
      return response.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }
}
