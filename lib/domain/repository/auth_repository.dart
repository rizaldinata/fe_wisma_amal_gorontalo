import 'package:frontend/domain/entity/user_entity.dart';

abstract class AuthRepository {
  Future<bool> checkSession();
  Future<void> getPermissions();
  Future<UserEntity> register(dynamic request);
  Future<UserEntity> login(dynamic request);
  Future<bool> logout();
  Future<bool> isLoggedIn();
}
