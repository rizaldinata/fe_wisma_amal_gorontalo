import 'package:frontend/domain/repository/finance_repository.dart';

class RefundPaymentUseCase {
  final FinanceRepository repository;

  RefundPaymentUseCase(this.repository);

  Future<bool> call(int paymentId, String reason) async {
    return await repository.refundPayment(paymentId, reason);
  }
}
