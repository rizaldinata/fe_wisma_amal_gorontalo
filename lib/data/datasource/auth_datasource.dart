import 'package:frontend/core/constant/storage_constant.dart';
import 'package:frontend/core/services/network/dio_client.dart';
import 'package:frontend/core/services/storage/shared_prefrence.dart';
import 'package:frontend/data/model/user_model.dart';

class AuthDatasource {
  AuthDatasource({required this.dioClient, required this.storage});

  final DioClient dioClient;
  final SharedPrefsStorage storage;
  
  Future<UserModel> login(String username, String password) async {
    // Implementasi login menggunakan dioClient
    final response = await dioClient.post('/login', data: {
      'email': username,
      'password': password,
    });

    var userdata = UserModel.fromJson(response.data['user']);



    if (response.statusCode == 200) {
      String? token;
      if (response.data is Map<String, dynamic>) {
        token =  response.data['token'] as String?;
      }
      
      if (token != null) {
        var trimmed = token.split('|').last;
        await storage.saveToken(trimmed);
      } else {
        throw Exception('Token not found in login response');
      }
      return userdata;
    } else {
      throw Exception('Failed to login: ${response.statusCode}');
    }
  }

  Future<void> logout() async {
    await storage.clearToken();
  }

  Future<bool> isLoggedIn() async {
    final token = await storage.getToken();
    return token != null;
  }
}