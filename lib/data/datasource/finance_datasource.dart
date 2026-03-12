import '../../core/services/network/dio_client.dart';
import '../model/finance/invoice_model.dart';
import '../model/finance/payment_model.dart';

abstract class FinanceRemoteDatasource {
  Future<List<InvoiceModel>> getDueInvoices();
  Future<List<PaymentModel>> getPendingPayments();
}

class FinanceRemoteDatasourceImpl implements FinanceRemoteDatasource {
  final DioClient _dioClient;

  FinanceRemoteDatasourceImpl(this._dioClient);

  @override
  Future<List<InvoiceModel>> getDueInvoices() async {
    try {
      final response = await _dioClient.get('/finance/dashboard/due-invoices');
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => InvoiceModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<PaymentModel>> getPendingPayments() async {
    try {
      final response = await _dioClient.get(
        '/finance/dashboard/pending-payments',
      );
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => PaymentModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }
}
