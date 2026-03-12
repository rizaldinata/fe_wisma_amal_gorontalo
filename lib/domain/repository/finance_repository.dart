import '../entity/finance/invoice_entity.dart';
import '../entity/finance/payment_entity.dart';

abstract class FinanceRepository {
  Future<List<InvoiceEntity>> getDueInvoices();
  Future<List<PaymentEntity>> getPendingPayments();
}
