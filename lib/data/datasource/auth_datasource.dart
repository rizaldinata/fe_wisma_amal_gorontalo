import 'package:frontend/core/services/network/dio_client.dart';
import 'package:frontend/core/services/storage/shared_prefrence.dart';

class AuthDatasource {
  AuthDatasource({required this.dioClient, required this.storage});

  final DioClient dioClient;
  final SharedPrefsStorage storage;
  
  Future<void> login(String username, String password) async {
    // Implementasi login menggunakan dioClient
    final response = await dioClient.post('/login', data: {
      'email': username,
      'password': password,
    });

    print('Login response: ${response.data}');

    if (response.statusCode == 200) {
      // Periksa struktur response yang benar
      String? token;
      if (response.data is Map<String, dynamic>) {
        // if (response.data.containsKey('data') && response.data['data'].containsKey('token')) {
        //   token = response.data['data']['token'];
        // } else if (response.data.containsKey('token')) {
        //   token = response.data['token'];
        // } else if (response.data.containsKey('access_token')) {
        //   token = response.data['access_token'];
        // }
        token =  response.data['token'];
      }
      
      if (token != null) {
        await storage.saveToken(token);
        print('Token saved successfully: $token');
      } else {
        print('Token not found in response: ${response.data}');
        throw Exception('Token not found in login response');
      }
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