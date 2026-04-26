import 'package:frontend/domain/entity/user/user_entity.dart';
import 'package:frontend/domain/repository/profile_repository.dart';

class GetProfileUseCase {
  final ProfileRepository _repository;
  GetProfileUseCase(this._repository);
  Future<UserEntity> call() => _repository.getProfile();
}

class UpdateProfileUseCase {
  final ProfileRepository _repository;
  UpdateProfileUseCase(this._repository);
  Future<UserEntity> call({required String name, required String email, String? phoneNumber}) =>
      _repository.updateProfile(name: name, email: email, phoneNumber: phoneNumber);
}

class ChangePasswordUseCase {
  final ProfileRepository _repository;
  ChangePasswordUseCase(this._repository);
  Future<void> call({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) => _repository.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
}
