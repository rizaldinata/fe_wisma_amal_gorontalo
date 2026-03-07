import 'package:frontend/domain/entity/permission_entity.dart';
import 'package:frontend/domain/repository/permission_repository.dart';
import 'package:frontend/domain/usecase/usecase.dart';

class CreatePermissionUseCase implements UseCase<PermissionEntity, PermissionEntity> {
  final PermissionRepository repository;

  CreatePermissionUseCase(this.repository);

  @override
  Future<PermissionEntity> call(PermissionEntity params) async {
    return await repository.createPermission(params);
  }
}
