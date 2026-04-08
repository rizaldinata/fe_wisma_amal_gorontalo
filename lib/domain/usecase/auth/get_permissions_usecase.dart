import 'package:frontend/domain/repository/auth_repository.dart';
import 'package:frontend/domain/usecase/usecase.dart';

class GetPermissionsUseCase implements UseCase<void, NoParams> {
  final AuthRepository repository;

  GetPermissionsUseCase(this.repository);

  @override
  Future<void> call(NoParams params) async {
    return await repository.getPermissions();
  }
}
