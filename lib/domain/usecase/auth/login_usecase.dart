import 'package:frontend/domain/entity/user_entity.dart';
import 'package:frontend/domain/repository/auth_repository.dart';
import 'package:frontend/domain/usecase/usecase.dart';

class LoginUseCase implements UseCase<UserEntity, dynamic> {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  @override
  Future<UserEntity> call(dynamic params) async {
    return await repository.login(params);
  }
}
