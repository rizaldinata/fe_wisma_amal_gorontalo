import 'package:frontend/domain/entity/refund_request_entity.dart';
import 'package:frontend/domain/repository/refund_request_repository.dart';

class TolakRefundUseCase {
  final RefundRequestRepository repository;

  TolakRefundUseCase({required this.repository});

  Future<RefundRequestEntity> execute({
    required int id,
    required String adminNotes,
  }) async {
    return await repository.tolakRefund(
      id: id,
      adminNotes: adminNotes,
    );
  }
}
