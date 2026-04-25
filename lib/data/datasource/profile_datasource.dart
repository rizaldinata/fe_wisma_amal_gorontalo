import 'package:frontend/core/services/network/dio_client.dart';
import 'package:frontend/data/model/user/user_model.dart';

class ProfileDataSource {
  final DioClient _dioClient;

  ProfileDataSource(this._dioClient);

  Future<UserModel> getProfile() async {
    try {
      final response = await _dioClient.get('/me');
      return UserModel.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _dioClient.put('/profile', data: data);
      return UserModel.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      await _dioClient.put('/change-password', data: {
        'old_password': oldPassword,
        'new_password': newPassword,
        'new_password_confirmation': confirmPassword,
      });
    } catch (e) {
      rethrow;
    }
  }
}
