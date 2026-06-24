import 'package:frontend/domain/entity/refund_request_entity.dart';
import 'package:frontend/domain/repository/refund_request_repository.dart';

class GetRefundRequestsUseCase {
  final RefundRequestRepository repository;

  GetRefundRequestsUseCase({required this.repository});

  Future<List<RefundRequestEntity>> execute({String? status}) async {
    return await repository.getRefundRequests(status: status);
  }
}
