import 'package:frontend/core/services/network/dio_client.dart';
import 'package:frontend/data/model/user/user_model.dart';

class UserDataSource {
  final DioClient _dioClient;

  UserDataSource(this._dioClient);

  Future<List<UserModel>> getUsers() async {
    try {
      final response = await _dioClient.get('/admin/users');
      final List data = response.data['data'];
      return data.map((json) => UserModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel> createUser(Map<String, dynamic> data) async {
    try {
      final response = await _dioClient.post('/admin/users', data: data);
      return UserModel.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel> updateUser(int id, Map<String, dynamic> data) async {
    try {
      final response = await _dioClient.put('/admin/users/$id', data: data);
      return UserModel.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteUser(int id) async {
    try {
      await _dioClient.delete('/admin/users/$id');
    } catch (e) {
      rethrow;
    }
  }
}
