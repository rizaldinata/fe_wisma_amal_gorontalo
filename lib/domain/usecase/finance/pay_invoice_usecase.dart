import 'dart:typed_data';
import '../../entity/finance/payment_entity.dart';
import '../../repository/finance_repository.dart';

class PayInvoiceUseCase {
  final FinanceRepository repository;

  PayInvoiceUseCase(this.repository);

  Future<PaymentEntity> execute(
    int invoiceId,
    String paymentMethod, {
    Uint8List? paymentProofBytes,
    String? paymentProofName,
  }) async {
    return await repository.payInvoice(
      invoiceId,
      paymentMethod,
      paymentProofBytes: paymentProofBytes,
      paymentProofName: paymentProofName,
    );
  }
}
