import 'package:dio/dio.dart';
import 'package:frontend/core/constant/endpoint_constant.dart';
import 'package:frontend/core/services/network/dio_client.dart';
import 'package:frontend/core/services/storage/shared_prefrence.dart';
import 'package:frontend/data/model/auth/auth_request_model.dart';
import 'package:frontend/data/model/auth/auth_response_model.dart';
import 'package:frontend/data/model/base_response_model.dart';

class AuthDatasource {
  AuthDatasource({required this.dioClient});

  final DioClient dioClient;

  Future<BaseResponseModel<AuthResponseModel>> register(
    AuthRequestModel request,
  ) async {
    try {
      final response = await dioClient.post(
        EndpointConstant.registerEndpoint,
        data: request.toJson(),
      );
      return BaseResponseModel<AuthResponseModel>.fromJson(
        response.data,
        (json) => AuthResponseModel.fromJson(json),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<BaseResponseModel<AuthResponseModel>> login(
    AuthRequestModel request,
  ) async {
    try {
      final response = await dioClient.post(
        EndpointConstant.loginEndpoint,
        data: request.toJson(),
      );
      final baseResponse = BaseResponseModel<AuthResponseModel>.fromJson(
        response.data,
        (json) => AuthResponseModel.fromJson(json),
      );
      return baseResponse;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<String>> getPermissions() async {
    try {
      final response = await dioClient.get(EndpointConstant.permissionEndpoint);
      final List<dynamic> data = response.data['data'];
      return data.map((e) => e.toString()).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> logout() async {
    try {
      var response = await dioClient.post(EndpointConstant.logoutEndpoint);
      return response.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }
}
