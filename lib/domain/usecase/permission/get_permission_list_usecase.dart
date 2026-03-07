import 'package:frontend/domain/entity/permission_entity.dart';
import 'package:frontend/domain/repository/permission_repository.dart';
import 'package:frontend/domain/usecase/usecase.dart';

class GetPermissionListUseCase implements UseCase<List<PermissionEntity>, NoParams> {
  final PermissionRepository repository;

  GetPermissionListUseCase(this.repository);

  @override
  Future<List<PermissionEntity>> call(NoParams params) async {
    return await repository.getPermissions();
  }
}
