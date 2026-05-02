import 'package:frontend/core/constant/endpoint_constant.dart';
import 'package:frontend/core/services/network/dio_client.dart';
import 'package:frontend/data/model/auth/permission_model.dart';
import 'package:frontend/data/model/auth/role_model.dart';
import 'package:frontend/data/model/base_response_model.dart';

class RoleDataSource {
  final DioClient _dioClient;

  RoleDataSource(this._dioClient);

  Future<BaseResponseModel<List<RoleModel>>> getRoles() async {
    try {
      final response = await _dioClient.get(EndpointConstant.adminRolesEndpoint);
      return BaseResponseModel<List<RoleModel>>.fromJson(
        response.data,
        (json) => (json as List).map((e) => RoleModel.fromJson(e)).toList(),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<BaseResponseModel<List<PermissionModel>>> getPermissions() async {
    try {
      final response = await _dioClient.get(EndpointConstant.adminPermissionEndpoint);
      return BaseResponseModel<List<PermissionModel>>.fromJson(
        response.data,
        (json) => (json as List).map((e) => PermissionModel.fromJson(e)).toList(),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<BaseResponseModel<RoleModel>> createRole({
    required String name,
    String? description,
    required List<String> permissions,
  }) async {
    try {
      final response = await _dioClient.post(
        EndpointConstant.adminRolesEndpoint,
        data: {
          'name': name,
          'description': description,
          'permissions': permissions,
        },
      );
      return BaseResponseModel<RoleModel>.fromJson(
        response.data,
        (json) => RoleModel.fromJson(json),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<BaseResponseModel<RoleModel>> updateRole({
    required int id,
    required String name,
    String? description,
    required List<String> permissions,
  }) async {
    try {
      final response = await _dioClient.put(
        '${EndpointConstant.adminRolesEndpoint}/$id',
        data: {
          'name': name,
          'description': description,
          'permissions': permissions,
        },
      );
      return BaseResponseModel<RoleModel>.fromJson(
        response.data,
        (json) => RoleModel.fromJson(json),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deleteRole(int id) async {
    try {
      final response = await _dioClient.delete(
        '${EndpointConstant.adminRolesEndpoint}/$id',
      );
      return response.data['status'] == true;
    } catch (e) {
      rethrow;
    }
  }
}
