import 'package:frontend/domain/entity/user/user_entity.dart';
import 'package:frontend/domain/repository/user_repository.dart';

class CreateUserUseCase {
  final UserRepository _repository;

  CreateUserUseCase(this._repository);

  Future<UserEntity> call({
    required String name,
    required String email,
    required String password,
    required String role,
    String? phoneNumber,
  }) async {
    // In actual implementation, you might want to create a CreateUserModel 
    // or just pass a map. Since we use UserRepository, we need to add this method.
    return await _repository.createUser(
      name: name,
      email: email,
      password: password,
      role: role,
      phoneNumber: phoneNumber,
    );
  }
}
