import 'package:frontend/core/constant/storage_constant.dart';
import 'package:frontend/core/services/storage/secure_storage.dart';
import 'package:frontend/core/services/storage/shared_prefrence.dart';
import 'package:frontend/data/datasource/auth_datasource.dart';
import 'package:frontend/domain/entity/permission_entity.dart';
import 'package:frontend/domain/entity/user_entity.dart';

import 'package:frontend/domain/repository/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthDatasource datasource;
  final SharedPrefsStorage storage;
  final SecureStorageService secureStorage;
  AuthRepository({
    required this.datasource,
    required this.storage,
    required this.secureStorage,
  });

  @override
  Future<bool> checkSession() async {
    try {
      final result = await datasource.checkSession();
      return result;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> getPermissions() async {
    try {
      final response = await datasource.getPermissions();
      await _savePermissions(Permissions(response.data.toSet()));
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserEntity> register(request) async {
    try {
      final response = await datasource.register(request);
      final token = response.data.token.split('|').last;
      await secureStorage.set(StorageConstant.token, token);
      final permissions = await datasource.getPermissions();
      UserEntity userEntity = response.data.toEntity();
      userEntity.permissions = Permissions(permissions.data.toSet());
      if (response.status) {
        await _saveUserInfo(userEntity);
      }
      return userEntity;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserEntity> login(request) async {
    try {
      final response = await datasource.login(request);
      final token = response.data.token.split('|').last;
      await secureStorage.set(StorageConstant.token, token);
      final permissions = await datasource.getPermissions();
      UserEntity userEntity = response.data.toEntity();
      userEntity.permissions = Permissions(permissions.data.toSet());
      if (response.status) {
        await _saveUserInfo(userEntity);
      }
      return userEntity;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> logout() async {
    final result = await datasource.logout();
    if (result) {
      await storage.clear();
      await secureStorage.delete(StorageConstant.token);
    }
    return result;
  }

  Future<void> _savePermissions(Permissions permissions) async {
    // await storage.clear();
    await storage.setPermissions(permissions.raw);

    print('Permissions saved: ${permissions.raw}');
  }

  Future<void> _saveUserInfo(UserEntity user) async {
    // await storage.clear();
    await storage.setString(StorageConstant.email, user.email);
    await storage.setString(StorageConstant.userName, user.name);
    await storage.setInt(StorageConstant.userId, user.id ?? 0);
    await storage.setList(StorageConstant.roleActive, user.roles);
    if (user.permissions != null) {
      await storage.setPermissions(user.permissions!.raw);
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = await secureStorage.get(StorageConstant.token);
    return token != null;
  }
}
