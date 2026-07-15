import 'package:frontend/domain/entity/user/user_entity.dart';
import 'package:frontend/domain/repository/user_repository.dart';

class UpdateUserUseCase {
  final UserRepository _repository;

  UpdateUserUseCase(this._repository);

  Future<UserEntity> call(int id, {String? name, String? email, String? role}) async {
    return await _repository.updateUser(id, name: name, email: email, role: role);
  }
}
