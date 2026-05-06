import '../../entity/finance/payment_entity.dart';
import '../../repository/finance_repository.dart';

class PayInvoiceUseCase {
  final FinanceRepository repository;

  PayInvoiceUseCase(this.repository);

  Future<PaymentEntity> execute(int invoiceId, String paymentMethod, {String? paymentProofPath}) async {
    return await repository.payInvoice(invoiceId, paymentMethod, paymentProofPath);
  }
}
