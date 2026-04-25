import 'package:frontend/domain/entity/user/user_entity.dart';
import 'package:frontend/domain/repository/user_repository.dart';

class GetAllUsersUseCase {
  final UserRepository _repository;

  GetAllUsersUseCase(this._repository);

  Future<List<UserEntity>> call() async {
    return await _repository.getUsers();
  }
}
