import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:frontend/core/constant/endpoint_constant.dart';
import 'package:frontend/core/services/network/dio_client.dart';
import 'package:frontend/data/model/base_response_model.dart';
import 'package:frontend/data/model/room/room_model.dart';
import 'package:file_picker/file_picker.dart';

class RoomDatasource {
  final DioClient dioClient;

  RoomDatasource({required this.dioClient});

  Future<BaseResponseModel<List<RoomModel>>> getRooms() async {
    try {
      final response = await dioClient.get(EndpointConstant.roomsEndpoint);

      return BaseResponseModel<List<RoomModel>>.fromJson(response.data, (json) {
        if (json is List) {
          return json.map((e) => RoomModel.fromJson(e)).toList();
        } else if (json is Map && json.containsKey('data')) {
          final data = json['data'];
          if (data is List) {
            return data.map((e) => RoomModel.fromJson(e)).toList();
          }
        }
        return [];
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<BaseResponseModel<RoomModel>> getRoomById(int id) async {
    try {
      final response = await dioClient.get(
        '${EndpointConstant.roomsEndpoint}/$id',
      );
      return BaseResponseModel<RoomModel>.fromJson(
        response.data,
        (json) => RoomModel.fromJson(json),
      );
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  // CREATE ROOM
  Future<BaseResponseModel<RoomModel>> createRoom(RoomModel data) async {
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
      debugPrint(e.toString());
      rethrow;
    }
  }

  // UPDATE ROOM
  Future<BaseResponseModel<RoomModel>> updateRoom(RoomModel data) async {
    try {
      final response = await dioClient.put(
        '${EndpointConstant.roomsEndpoint}/${data.id}',
        data: data.toJson(),
      );
      return BaseResponseModel<RoomModel>.fromJson(
        response.data,
        (json) => RoomModel.fromJson(json),
      );
    } catch (e) {
      debugPrint(e.toString());
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
      debugPrint(e.toString());
      rethrow;
    }
  }

  // DELETE ROOM IMAGE
  Future<bool> deleteRoomImage({
    required int roomId,
    required int imageId,
  }) async {
    try {
      final response = await dioClient.delete(
        EndpointConstant.deleteRoomImage(roomId: roomId, imageId: imageId),
      );
      if (response.statusCode == 200) {
        return response.data['status'] == true;
      } else {
        return false;
      }
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  // UPLOAD ROOM IMAGE
    Future<bool> uploadRoomImage({
    required int roomId,
    required List<PlatformFile> files,
  }) async {
    try {
      final formData = FormData();
      for (final file in files) {
        if (file.bytes == null) {
          debugPrint('File bytes for ${file.name} is null, skipping');
          continue;
        }
        formData.files.add(
          MapEntry(
            'images[]',
            MultipartFile.fromBytes(
              file.bytes!,
              filename: file.name,
              contentType: DioMediaType.parse('image/jpeg'),
            ),
          ),
        );
      }
      final response = await dioClient.post(
        EndpointConstant.uploadRoomImage(roomId: roomId),
        data: formData,
      );
      // Status 201 (Created) adalah standard Laravel/REST API 
      // untuk request POST yang berhasil membuat data baru.
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data['status'] == true;
      } else {
        return false;
      }
    } catch (e) {
      debugPrint('Upload error: $e');
      rethrow;
    }
  }}