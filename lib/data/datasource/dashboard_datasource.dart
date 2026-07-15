import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/constant/endpoint_constant.dart';
import 'package:frontend/core/services/network/dio_client.dart';
import 'package:frontend/data/model/base_response_model.dart';
import 'package:frontend/data/model/dashboard/dashboard_model.dart';

class DashboardDatasource {
  DashboardDatasource({required this.dioClient});

  final DioClient dioClient;

  Future<BaseResponseModel<DashboardModel>> getAdminDashboard() async {
    try {
      final response = await dioClient.get(
        EndpointConstant.adminDashboardEndpoint,
      );
      return BaseResponseModel<DashboardModel>.fromJson(
        response.data,
        (json) => DashboardModel.fromJson(json),
      );
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<BaseResponseModel<ResidentDashboardModel>> getResidentDashboard() async {
    try {
      final response = await dioClient.get(
        EndpointConstant.residentDashboardEndpoint,
      );
      return BaseResponseModel<ResidentDashboardModel>.fromJson(
        response.data,
        (json) => ResidentDashboardModel.fromJson(json),
      );
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }
}
