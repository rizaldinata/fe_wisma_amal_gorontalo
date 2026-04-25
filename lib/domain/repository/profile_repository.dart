import 'package:frontend/domain/entity/user/user_entity.dart';

abstract class ProfileRepository {
  Future<UserEntity> getProfile();
  Future<UserEntity> updateProfile({required String name, required String email, String? phoneNumber});
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  });
}
