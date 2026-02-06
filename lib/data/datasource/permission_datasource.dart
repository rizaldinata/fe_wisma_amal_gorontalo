import 'package:frontend/core/constant/endpoint_constant.dart';
import 'package:frontend/core/services/network/dio_client.dart';
import 'package:frontend/data/model/auth/permission_model.dart';
import 'package:frontend/data/model/base_response_model.dart';

class PermissionDatasource {
  final DioClient dioClient;

  PermissionDatasource({required this.dioClient});

  Future<BaseResponseModel<List<PermissionModel>>> getPermissions() async {
    try {
      final response = await dioClient.get(
        EndpointConstant.adminPermissionEndpoint,
      );
      return BaseResponseModel<List<PermissionModel>>.fromJson(
        response.data,
        (json) =>
            (json as List).map((e) => PermissionModel.fromJson(e)).toList(),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<BaseResponseModel<PermissionModel>> createPermission(
    PermissionModel data,
  ) async {
    try {
      final response = await dioClient.post(
        EndpointConstant.adminPermissionEndpoint,
        data: data.toJson(),
      );
      return BaseResponseModel<PermissionModel>.fromJson(
        response.data,
        (json) => PermissionModel.fromJson(json),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<BaseResponseModel<PermissionModel>> updatePermission(
    int id,
    PermissionModel data,
  ) async {
    try {
      final response = await dioClient.put(
        '${EndpointConstant.adminPermissionEndpoint}/$id',
        data: data.toJson(),
      );
      return BaseResponseModel<PermissionModel>.fromJson(
        response.data,
        (json) => PermissionModel.fromJson(json),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deletePermission(int id) async {
    try {
      final response = await dioClient.delete(
        '${EndpointConstant.adminPermissionEndpoint}/$id',
      );
      return response.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }
}
