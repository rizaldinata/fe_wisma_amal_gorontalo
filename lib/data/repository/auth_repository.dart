import 'package:frontend/core/constant/storage_constant.dart';
import 'package:frontend/core/services/storage/shared_prefrence.dart';
import 'package:frontend/data/datasource/auth_datasource.dart';
import 'package:frontend/domain/entity/user_entity.dart';

class AuthRepository {
  AuthDatasource datasource;
  final SharedPrefsStorage storage;
  AuthRepository({required this.datasource, required this.storage});

  Future<UserEntity> register(request) async {
    try {
      final response = await datasource.register(request);
      final token = response.data.token.split('|').last;
      await storage.saveToken(token);
      UserEntity userEntity = response.data.toEntity();
      if (response.status) {
        await _saveUserInfo(userEntity);
      }
      return userEntity;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserEntity> login(request) async {
    try {
      final response = await datasource.login(request);
      final token = response.data.token.split('|').last;
      await storage.saveToken(token);
      UserEntity userEntity = response.data.toEntity();
      if (response.status) {
        await _saveUserInfo(userEntity);
      }
      return userEntity;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> logout() async {
    final result = await datasource.logout();
    if (result) {
      await storage.clear();
    }
    return result;
  }

  Future<void> _saveUserInfo(UserEntity user) async {
    await storage.setString(StorageConstant.email, user.email);
    await storage.setString(StorageConstant.userName, user.name);
    await storage.setInt(StorageConstant.userId, user.id ?? 0);
    await storage.setList(StorageConstant.roleActive, user.roles);
    // await storage.setPermissions(user.permissions.toSet());
  }

  bool isLoggedIn() {
    final token = storage.getToken();
    return token != null;
  }
}
