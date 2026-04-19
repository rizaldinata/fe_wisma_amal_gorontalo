import '../../repository/finance_repository.dart';

class VerifyPaymentUseCase {
  final FinanceRepository repository;

  VerifyPaymentUseCase(this.repository);

  Future<bool> call(int paymentId, bool isApproved, {String? adminNotes}) async {
    return await repository.verifyPayment(paymentId, isApproved, adminNotes);
  }
}