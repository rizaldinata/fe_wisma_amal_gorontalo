import 'package:frontend/domain/entity/role/role_entity.dart';
import 'package:frontend/domain/entity/permission_entity.dart';
import 'package:frontend/domain/repository/role_repository.dart';

class GetAllRolesUseCase {
  final RoleRepository _repository;
  GetAllRolesUseCase(this._repository);
  Future<List<RoleEntity>> call() => _repository.getRoles();
}

class GetAllPermissionsUseCase {
  final RoleRepository _repository;
  GetAllPermissionsUseCase(this._repository);
  Future<List<PermissionEntity>> call() => _repository.getPermissions();
}

class CreateRoleUseCase {
  final RoleRepository _repository;
  CreateRoleUseCase(this._repository);
  Future<RoleEntity> call({required String name, String? description, required List<String> permissions}) => 
      _repository.createRole(name: name, description: description, permissions: permissions);
}

class UpdateRoleUseCase {
  final RoleRepository _repository;
  UpdateRoleUseCase(this._repository);
  Future<RoleEntity> call({required int id, required String name, String? description, required List<String> permissions}) => 
      _repository.updateRole(id: id, name: name, description: description, permissions: permissions);
}

class DeleteRoleUseCase {
  final RoleRepository _repository;
  DeleteRoleUseCase(this._repository);
  Future<void> call(int id) => _repository.deleteRole(id);
}
