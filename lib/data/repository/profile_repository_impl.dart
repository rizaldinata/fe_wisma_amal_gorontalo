import 'package:frontend/data/datasource/profile_datasource.dart';
import 'package:frontend/domain/entity/user/user_entity.dart';
import 'package:frontend/domain/repository/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileDataSource _dataSource;

  ProfileRepositoryImpl(this._dataSource);

  @override
  Future<UserEntity> getProfile() async {
    return await _dataSource.getProfile();
  }

  @override
  Future<UserEntity> updateProfile({required String name, required String email, String? phoneNumber}) async {
    return await _dataSource.updateProfile({
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
    });
  }

  @override
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    return await _dataSource.changePassword(
      oldPassword: oldPassword,
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );
  }
}
