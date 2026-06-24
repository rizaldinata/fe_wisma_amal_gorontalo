import 'package:file_picker/file_picker.dart';
import 'package:frontend/data/datasource/refund_request_datasource.dart';
import 'package:frontend/domain/entity/refund_request_entity.dart';
import 'package:frontend/domain/repository/refund_request_repository.dart';

class RefundRequestRepositoryImpl implements RefundRequestRepository {
  final RefundRequestDatasource datasource;

  RefundRequestRepositoryImpl({required this.datasource});

  @override
  Future<List<RefundRequestEntity>> getRefundRequests({String? status}) async {
    final models = await datasource.getRefundRequests(status: status);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<RefundRequestEntity> prosesRefund({
    required int id,
    String? proofPath,
    double adminFee = 0,
    String adminNotes = '',
  }) async {
    // proofPath tidak digunakan di impl ini; proof file dihandle di bloc
    final model = await datasource.prosesRefund(
      id: id,
      proof: null,
      adminFee: adminFee,
      adminNotes: adminNotes,
    );
    return model.toEntity();
  }

  Future<RefundRequestEntity> prosesRefundWithFile({
    required int id,
    PlatformFile? proof,
    double adminFee = 0,
    String adminNotes = '',
  }) async {
    final model = await datasource.prosesRefund(
      id: id,
      proof: proof,
      adminFee: adminFee,
      adminNotes: adminNotes,
    );
    return model.toEntity();
  }

  @override
  Future<RefundRequestEntity> tolakRefund({
    required int id,
    required String adminNotes,
  }) async {
    final model = await datasource.tolakRefund(id: id, adminNotes: adminNotes);
    return model.toEntity();
  }
}
