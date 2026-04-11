import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import '../model/maintenance_model.dart';
import '../../../core/services/network/dio_client.dart';
import '../../../core/services/network/exception.dart';

abstract class MaintenanceRemoteDataSource {
  Future<List<MaintenanceRequestModel>> getMyRequests();
  Future<List<MaintenanceRequestModel>> getAllRequests();
  Future<MaintenanceRequestModel> getReportById(int id);
  Future<MaintenanceRequestModel> createReport({
    required String title,
    required String description,
    int? roomId,
    List<PlatformFile>? images,
  });
  Future<MaintenanceTimelineModel> addUpdateReply({
    required int requestId,
    required String description,
    String? status,
    List<PlatformFile>? images,
  });
}

class MaintenanceRemoteDataSourceImpl implements MaintenanceRemoteDataSource {
  final DioClient dioClient;

  MaintenanceRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<List<MaintenanceRequestModel>> getMyRequests() async {
    final response = await dioClient.get('/v1/damage-reports/my-reports');
    final data = response.data['data'] as List;
    return data.map((json) => MaintenanceRequestModel.fromJson(json)).toList();
  }

  @override
  Future<List<MaintenanceRequestModel>> getAllRequests() async {
    final response = await dioClient.get('/v1/damage-reports/admin/');
    final data = response.data['data'] as List;
    return data.map((json) => MaintenanceRequestModel.fromJson(json)).toList();
  }

  @override
  Future<MaintenanceRequestModel> getReportById(int id) async {
    try {
      final response = await dioClient.get('/v1/damage-reports/$id');
      return MaintenanceRequestModel.fromJson(response.data['data']);
    } on AppException catch (e) {
      if (e.code == 403 || e.code == 404 || e.code == 401) {
        final adminResponse = await dioClient.get('/v1/damage-reports/admin/$id');
        return MaintenanceRequestModel.fromJson(adminResponse.data['data']);
      }
      rethrow;
    }
  }

  @override
  Future<MaintenanceRequestModel> createReport({
    required String title,
    required String description,
    int? roomId,
    List<PlatformFile>? images,
  }) async {
    final formData = FormData.fromMap({
      'title': title,
      'description': description,
      if (roomId != null) 'room_id': roomId,
    });

    if (images != null && images.isNotEmpty) {
      for (int i = 0; i < images.length; i++) {
        final file = images[i];
        formData.files.add(
          MapEntry(
            'images[$i]',
            kIsWeb 
              ? MultipartFile.fromBytes(file.bytes!, filename: file.name)
              : await MultipartFile.fromFile(file.path!, filename: file.name),
          ),
        );
      }
    }

    final response = await dioClient.post('/v1/damage-reports/', data: formData);
    return MaintenanceRequestModel.fromJson(response.data['data']);
  }

  @override
  Future<MaintenanceTimelineModel> addUpdateReply({
    required int requestId,
    required String description,
    String? status,
    List<PlatformFile>? images,
  }) async {
    final formData = FormData.fromMap({
      'description': description,
      if (status != null) 'status': status,
    });

    if (images != null && images.isNotEmpty) {
      for (int i = 0; i < images.length; i++) {
        final file = images[i];
        formData.files.add(
          MapEntry(
            'images[$i]',
            kIsWeb 
              ? MultipartFile.fromBytes(file.bytes!, filename: file.name)
              : await MultipartFile.fromFile(file.path!, filename: file.name),
          ),
        );
      }
    }

    final response = await dioClient.post('/v1/damage-reports/admin/$requestId/updates', data: formData);
    return MaintenanceTimelineModel.fromJson(response.data['data']);
  }
}
