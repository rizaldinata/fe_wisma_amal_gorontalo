import 'package:frontend/domain/repository/auth_repository.dart';
import 'package:frontend/domain/usecase/usecase.dart';

class CheckSessionUseCase implements UseCase<bool, NoParams> {
  final AuthRepository repository;

  CheckSessionUseCase(this.repository);

  @override
  Future<bool> call(NoParams params) async {
    return await repository.checkSession();
  }
}
