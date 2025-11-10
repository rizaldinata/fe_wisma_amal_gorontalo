import 'package:dio/dio.dart';
import 'package:frontend/core/constant/endpoint_constant.dart';
import 'package:frontend/core/constant/storage_constant.dart';
import 'package:frontend/core/services/network/dio_client.dart';
import 'package:frontend/core/services/network/exception.dart';
import 'package:frontend/core/services/storage/shared_prefrence.dart';
import 'package:frontend/data/model/auth/auth_response.dart';
import 'package:frontend/data/model/auth/login_request.dart';
import 'package:frontend/data/model/auth/register_request.dart';
import 'package:frontend/data/model/auth/user_model.dart';

class AuthDatasource {
  AuthDatasource({required this.dioClient, required this.storage});

  final DioClient dioClient;
  final SharedPrefsStorage storage;

  Future<UserModel?> register(RegisterRequestModel request) async {
    try {
      final response = await dioClient.post(
      EndpointConstant.registerEndpoint,
      data: request.toJson(),
    );

    // var data = AuthResponse.fromJson(response.data['data']);


    //   // save token
    //   if (data.token.isNotEmpty) {
    //     var trimmed = data.token.split('|').last;
    //     await storage.saveToken(trimmed);
    //   } else {
    //     throw Exception('Token not found in login response');
    //   }
    //   if (data.user != null) {
    //     await storage.setPermissions(data.user?.permissions?.toSet() ?? {});
    //     await storage.set(StorageConstant.userName, data.user?.name ?? '');
    //     await storage.set(StorageConstant.email, data.user?.email ?? '');
    //     await storage.setInt(StorageConstant.userId, data.user?.id ?? 0);
    //     await storage.setList(
    //       StorageConstant.roleActive,
    //       data.user?.roles ?? [],
    //     );
    //   }

    //   return data.user;
    } catch (e) {
      // Gunakan AppException.fromDioError untuk handle semua error Dio
      rethrow;
    }
  }

  Future<UserModel?> login(LoginRequestModel request) async {
    try {
      // Implementasi login menggunakan dioClient
      final response = await dioClient.post(
        EndpointConstant.loginEndpoint,
        data: request.toJson(),
      );

      var data = AuthResponse.fromJson(response.data['data']);

      // save token
      if (data.token.isNotEmpty) {
        var trimmed = data.token.split('|').last;
        await storage.saveToken(trimmed);
      } else {
        throw Exception('Token not found in login response');
      }
      if (data.user != null) {
        await storage.setPermissions(data.user?.permissions?.toSet() ?? {});
        await storage.set(StorageConstant.userName, data.user?.name ?? '');
        await storage.set(StorageConstant.email, data.user?.email ?? '');
        await storage.setInt(StorageConstant.userId, data.user?.id ?? 0);
        await storage.setList(
          StorageConstant.roleActive,
          data.user?.roles ?? [],
        );
      }

      return data.user;
    } catch (e) {
      // Gunakan AppException.fromDioError untuk handle semua error Dio
      rethrow;
    }
  }

  Future<void> logout() async {
    await storage.clearToken();
  }

  Future<bool> isLoggedIn() async {
    final token = storage.getToken();
    return token != null;
  }
}
