import 'package:frontend/domain/entity/permission_entity.dart';

abstract class PermissionRepository {
  Future<List<PermissionEntity>> getPermissions();
  Future<PermissionEntity> createPermission(PermissionEntity permission);
  Future<PermissionEntity> updatePermission(PermissionEntity permission);
  Future<bool> deletePermission(int id);
}
