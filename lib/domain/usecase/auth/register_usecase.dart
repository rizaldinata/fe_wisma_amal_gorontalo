import 'package:frontend/domain/entity/user_entity.dart';
import 'package:frontend/domain/repository/auth_repository.dart';
import 'package:frontend/domain/usecase/usecase.dart';

class RegisterUseCase implements UseCase<UserEntity, dynamic> {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  @override
  Future<UserEntity> call(dynamic params) async {
    return await repository.register(params);
  }
}
