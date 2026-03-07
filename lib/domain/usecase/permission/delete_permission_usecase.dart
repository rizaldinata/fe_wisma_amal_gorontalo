import 'package:frontend/domain/repository/permission_repository.dart';
import 'package:frontend/domain/usecase/usecase.dart';

class DeletePermissionUseCase implements UseCase<bool, int> {
  final PermissionRepository repository;

  DeletePermissionUseCase(this.repository);

  @override
  Future<bool> call(int params) async {
    return await repository.deletePermission(params);
  }
}
