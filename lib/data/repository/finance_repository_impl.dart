import '../../domain/entity/finance/invoice_entity.dart';
import '../../domain/entity/finance/payment_entity.dart';
import '../../domain/repository/finance_repository.dart';
import '../datasource/finance_datasource.dart';

class FinanceRepositoryImpl implements FinanceRepository {
  final FinanceRemoteDatasource remoteDatasource;

  FinanceRepositoryImpl({required this.remoteDatasource});

  @override
  Future<List<InvoiceEntity>> getDueInvoices() async {
    try {
      final models = await remoteDatasource.getDueInvoices();
      return models;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<PaymentEntity>> getPendingPayments() async {
    try {
      final models = await remoteDatasource.getPendingPayments();
      return models;
    } catch (e) {
      rethrow;
    }
  }
}
