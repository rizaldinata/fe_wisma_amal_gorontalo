import 'package:frontend/domain/entity/refund_request_entity.dart';

abstract class RefundRequestRepository {
  Future<List<RefundRequestEntity>> getRefundRequests({String? status});

  Future<RefundRequestEntity> prosesRefund({
    required int id,
    String? proofPath,
    double adminFee,
    String adminNotes,
  });

  Future<RefundRequestEntity> tolakRefund({
    required int id,
    required String adminNotes,
  });
}
