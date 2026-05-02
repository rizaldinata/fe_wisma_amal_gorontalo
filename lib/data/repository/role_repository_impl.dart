import 'package:frontend/data/datasource/role_datasource.dart';
import 'package:frontend/domain/entity/permission_entity.dart';
import 'package:frontend/domain/entity/role/role_entity.dart';
import 'package:frontend/domain/repository/role_repository.dart';

class RoleRepositoryImpl implements RoleRepository {
  final RoleDataSource _dataSource;

  RoleRepositoryImpl(this._dataSource);

  @override
  Future<List<RoleEntity>> getRoles() async {
    final response = await _dataSource.getRoles();
    return response.data ?? [];
  }

  @override
  Future<List<PermissionEntity>> getPermissions() async {
    final response = await _dataSource.getPermissions();
    return response.data ?? [];
  }

  @override
  Future<RoleEntity> createRole({
    required String name,
    String? description,
    required List<String> permissions,
  }) async {
    final response = await _dataSource.createRole(
      name: name,
      description: description,
      permissions: permissions,
    );
    return response.data!;
  }

  @override
  Future<RoleEntity> updateRole({
    required int id,
    required String name,
    String? description,
    required List<String> permissions,
  }) async {
    final response = await _dataSource.updateRole(
      id: id,
      name: name,
      description: description,
      permissions: permissions,
    );
    return response.data!;
  }

  @override
  Future<void> deleteRole(int id) async {
    await _dataSource.deleteRole(id);
  }
}
