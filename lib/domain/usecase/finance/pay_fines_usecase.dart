import 'dart:typed_data';
import '../../entity/finance/payment_entity.dart';
import '../../repository/finance_repository.dart';

class PayFinesUseCase {
  final FinanceRepository repository;
  PayFinesUseCase(this.repository);

  Future<PaymentEntity> execute(
    List<int> fineIds,
    String paymentMethod, {
    Uint8List? paymentProofBytes,
    String? paymentProofName,
    String? preferredPaymentType,
  }) async {
    return await repository.payFines(
      fineIds,
      paymentMethod,
      paymentProofBytes: paymentProofBytes,
      paymentProofName: paymentProofName,
      preferredPaymentType: preferredPaymentType,
    );
  }
}
