import 'package:frontend/data/datasource/user_datasource.dart';
import 'package:frontend/domain/entity/user/user_entity.dart';
import 'package:frontend/domain/repository/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final UserDataSource _dataSource;

  UserRepositoryImpl(this._dataSource);

  @override
  Future<List<UserEntity>> getUsers() async {
    return await _dataSource.getUsers();
  }

  @override
  Future<UserEntity> createUser({
    required String name,
    required String email,
    required String password,
    required String role,
    String? phoneNumber,
  }) async {
    return await _dataSource.createUser({
      'name': name,
      'email': email,
      'password': password,
      'role': role,
      'phone_number': phoneNumber,
    });
  }

  @override
  Future<UserEntity> updateUser(int id, {String? name, String? email, String? role}) async {
    final Map<String, dynamic> data = {};
    if (name != null) data['name'] = name;
    if (email != null) data['email'] = email;
    if (role != null) data['role'] = role;
    
    return await _dataSource.updateUser(id, data);
  }

  @override
  Future<void> deleteUser(int id) async {
    return await _dataSource.deleteUser(id);
  }
}
