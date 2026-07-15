import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:frontend/core/services/network/dio_client.dart';
import 'package:frontend/data/model/refund_request_model.dart';

class RefundRequestDatasource {
  final DioClient dioClient;

  RefundRequestDatasource({required this.dioClient});

  Future<List<RefundRequestModel>> getRefundRequests({String? status}) async {
    final queryParams = <String, dynamic>{};
    if (status != null) queryParams['status'] = status;

    final response = await dioClient.get(
      '/finance/refund-requests',
      queryParams: queryParams,
    );

    final data = response.data['data'] as List? ?? [];
    return data
        .map((json) => RefundRequestModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<RefundRequestModel> prosesRefund({
    required int id,
    PlatformFile? proof,
    double adminFee = 0,
    String adminNotes = '',
  }) async {
    final formData = FormData.fromMap({
      'admin_fee': adminFee,
      'admin_notes': adminNotes,
    });

    if (proof != null) {
      formData.files.add(
        MapEntry(
          'proof',
          kIsWeb
              ? MultipartFile.fromBytes(proof.bytes!, filename: proof.name)
              : await MultipartFile.fromFile(proof.path!, filename: proof.name),
        ),
      );
    }

    final response = await dioClient.post(
      '/finance/refund-requests/$id/proses',
      data: formData,
    );

    return RefundRequestModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  Future<RefundRequestModel> tolakRefund({
    required int id,
    required String adminNotes,
  }) async {
    final response = await dioClient.post(
      '/finance/refund-requests/$id/tolak',
      data: {'admin_notes': adminNotes},
    );

    return RefundRequestModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }
}
