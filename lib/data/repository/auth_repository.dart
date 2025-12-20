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
      await storage.saveToken(response.data.token);
      return response.data.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  Future<UserEntity> login(request) async {
    try {
      final response = await datasource.login(request);
      await storage.saveToken(response.data.token);
      return response.data.toEntity();
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

  bool isLoggedIn() {
    final token = storage.getToken();
    return token != null;
  }
}
