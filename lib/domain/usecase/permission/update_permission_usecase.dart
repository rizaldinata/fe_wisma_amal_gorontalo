import 'package:frontend/domain/entity/permission_entity.dart';
import 'package:frontend/domain/repository/permission_repository.dart';
import 'package:frontend/domain/usecase/usecase.dart';

class UpdatePermissionUseCase implements UseCase<PermissionEntity, PermissionEntity> {
  final PermissionRepository repository;

  UpdatePermissionUseCase(this.repository);

  @override
  Future<PermissionEntity> call(PermissionEntity params) async {
    return await repository.updatePermission(params);
  }
}
