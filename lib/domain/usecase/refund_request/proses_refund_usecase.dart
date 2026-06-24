import 'package:frontend/domain/entity/refund_request_entity.dart';
import 'package:frontend/domain/repository/refund_request_repository.dart';

class ProsesRefundUseCase {
  final RefundRequestRepository repository;

  ProsesRefundUseCase({required this.repository});

  Future<RefundRequestEntity> execute({
    required int id,
    String? proofPath,
    double adminFee = 0,
    String adminNotes = '',
  }) async {
    return await repository.prosesRefund(
      id: id,
      proofPath: proofPath,
      adminFee: adminFee,
      adminNotes: adminNotes,
    );
  }
}
