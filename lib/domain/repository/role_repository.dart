import 'package:frontend/domain/entity/role/role_entity.dart';
import 'package:frontend/domain/entity/permission_entity.dart';

abstract class RoleRepository {
  Future<List<RoleEntity>> getRoles();
  Future<List<PermissionEntity>> getPermissions();
  Future<RoleEntity> createRole({required String name, String? description, required List<String> permissions});
  Future<RoleEntity> updateRole({required int id, required String name, String? description, required List<String> permissions});
  Future<void> deleteRole(int id);
}
