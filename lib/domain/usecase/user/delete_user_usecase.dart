import 'package:frontend/domain/repository/user_repository.dart';

class DeleteUserUseCase {
  final UserRepository _repository;

  DeleteUserUseCase(this._repository);

  Future<void> call(int id) async {
    return await _repository.deleteUser(id);
  }
}
