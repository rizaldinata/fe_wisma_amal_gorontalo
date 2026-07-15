import 'package:frontend/domain/entity/user/user_entity.dart';

abstract class UserRepository {
  Future<List<UserEntity>> getUsers();
  Future<UserEntity> createUser({
    required String name,
    required String email,
    required String password,
    required String role,
    String? phoneNumber,
  });
  Future<UserEntity> updateUser(int id, {String? name, String? email, String? role});
  Future<void> deleteUser(int id);
}
