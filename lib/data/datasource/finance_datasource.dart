import '../../core/services/network/dio_client.dart';
import '../model/finance/invoice_model.dart';
import '../model/finance/payment_model.dart';
import '../model/finance/kpi_model.dart';
import '../model/finance/revenue_model.dart';

abstract class FinanceRemoteDatasource {
  Future<List<InvoiceModel>> getDueInvoices();
  Future<List<PaymentModel>> getPendingPayments();
  Future<KpiModel> getKpiSummary();
  Future<List<RevenueModel>> getRevenueChart();
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

  @override
  Future<KpiModel> getKpiSummary() async {
    try {
      final response = await _dioClient.get('/finance/dashboard/kpi-summary');
      final data = response.data['data'] ?? {};
      return KpiModel.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<RevenueModel>> getRevenueChart() async {
    try {
      final response = await _dioClient.get('/finance/dashboard/revenue-chart');
      final data = response.data['data'];

      List<RevenueModel> result = [];

      if (data != null &&
          data['labels'] != null &&
          data['datasets'] != null &&
          (data['datasets'] as List).isNotEmpty) {
        List<dynamic> labels = data['labels'];
        List<dynamic> chartData = data['datasets'][0]['data'];

        for (int i = 0; i < labels.length; i++) {
          result.add(
            RevenueModel(
              month: labels[i].toString(),
              total: double.tryParse(chartData[i].toString()) ?? 0.0,
            ),
          );
        }
      }
      return result;
    } catch (e) {
      rethrow;
    }
  }
}
