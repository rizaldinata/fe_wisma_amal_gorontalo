import 'dart:typed_data';
import '../../entity/finance/payment_entity.dart';
import '../../repository/finance_repository.dart';

class ExtendLeaseUseCase {
  final FinanceRepository repository;

  ExtendLeaseUseCase(this.repository);

  Future<PaymentEntity> execute(
    int leaseId,
    int durationMonths,
    String paymentMethod, {
    Uint8List? paymentProofBytes,
    String? paymentProofName,
    String? preferredPaymentType,
  }) async {
    return await repository.extendLease(
      leaseId,
      durationMonths,
      paymentMethod,
      paymentProofBytes: paymentProofBytes,
      paymentProofName: paymentProofName,
      preferredPaymentType: preferredPaymentType,
    );
  }
}
