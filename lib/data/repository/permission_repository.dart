import 'package:frontend/data/datasource/permission_datasource.dart';
import 'package:frontend/data/model/auth/permission_model.dart';
import 'package:frontend/domain/entity/permission_entity.dart';

class PermissionRepository {
  final PermissionDatasource datasource;

  PermissionRepository({required this.datasource});

  Future<List<PermissionEntity>> getPermissions() async {
    try {
      final response = await datasource.getPermissions();
      return response.data.map((e) => e.toEntity()).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<PermissionEntity> createPermission(PermissionEntity permission) async {
    try {
      final response = await datasource.createPermission(
        PermissionModel.fromEntity(permission),
      );
      return response.data.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  Future<PermissionEntity> updatePermission(PermissionEntity permission) async {
    try {
      final response = await datasource.updatePermission(
        permission.id,
        PermissionModel.fromEntity(permission),
      );
      return response.data.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deletePermission(int id) async {
    return await datasource.deletePermission(id);
  }
}
