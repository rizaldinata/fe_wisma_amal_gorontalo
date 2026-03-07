import 'package:frontend/domain/repository/auth_repository.dart';
import 'package:frontend/domain/usecase/usecase.dart';

class LogoutUseCase implements UseCase<bool, NoParams> {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  @override
  Future<bool> call(NoParams params) async {
    return await repository.logout();
  }
}
