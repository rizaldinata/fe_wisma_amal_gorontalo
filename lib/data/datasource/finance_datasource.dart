import '../../core/services/network/dio_client.dart';
import '../model/finance/invoice_model.dart';
import '../model/finance/payment_model.dart';
import '../model/finance/kpi_model.dart';
import '../model/finance/revenue_model.dart';
import '../model/finance/expense_model.dart';
import '../model/base_response_model.dart';

abstract class FinanceRemoteDatasource {
  Future<List<InvoiceModel>> getDueInvoices();
  Future<List<InvoiceModel>> getInvoices();
  Future<List<PaymentModel>> getPendingPayments();
  Future<KpiModel> getKpiSummary();
  Future<List<RevenueModel>> getRevenueChart();

  Future<List<ExpenseModel>> getExpenses();
  Future<ExpenseModel> createExpense(ExpenseModel expense);
  Future<ExpenseModel> updateExpense(ExpenseModel expense);
  Future<void> deleteExpense(int id);
  Future<void> verifyPayment(int paymentId, bool isApproved, String? adminNotes);
  Future<void> refundPayment(int paymentId, String reason);
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
  Future<List<InvoiceModel>> getInvoices() async {
    try {
      final response = await _dioClient.get('/finance/invoices');
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
        List<dynamic> monthlyData = (data['datasets'] as List).length > 1
            ? data['datasets'][1]['data']
            : [];
        List<dynamic> dailyData = (data['datasets'] as List).length > 2
            ? data['datasets'][2]['data']
            : [];

        for (int i = 0; i < labels.length; i++) {
          result.add(
            RevenueModel(
              month: labels[i].toString(),
              total: double.tryParse(chartData[i].toString()) ?? 0.0,
              monthlyRentTotal: monthlyData.length > i
                  ? (double.tryParse(monthlyData[i].toString()) ?? 0.0)
                  : 0.0,
              dailyRentTotal: dailyData.length > i
                  ? (double.tryParse(dailyData[i].toString()) ?? 0.0)
                  : 0.0,
            ),
          );
        }
      }
      return result;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<ExpenseModel>> getExpenses() async {
    final response = await _dioClient.get('/finance/expenses');
    final List<dynamic> data = response.data['data'] ?? [];
    return data.map((json) => ExpenseModel.fromJson(json)).toList();
  }

  @override
  Future<ExpenseModel> createExpense(ExpenseModel expense) async {
    final response = await _dioClient.post(
      '/finance/expenses',
      data: expense.toJson(),
    );
    return ExpenseModel.fromJson(response.data['data']);
  }

  @override
  Future<ExpenseModel> updateExpense(ExpenseModel expense) async {
    final response = await _dioClient.put(
      '/finance/expenses/${expense.id}',
      data: expense.toJson(),
    );
    return ExpenseModel.fromJson(response.data['data']);
  }

  @override
  Future<void> deleteExpense(int id) async {
    await _dioClient.delete('/finance/expenses/$id');
  }

  @override
  Future<void> verifyPayment(int paymentId, bool isApproved, String? adminNotes) async {
    try {
      await _dioClient.post(
        '/finance/payments/$paymentId/verify',
        data: {
          'is_approved': isApproved,
          'admin_notes': adminNotes,
        },
      );
    } catch (e) {
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> refundPayment(int paymentId, String reason) async {
    try {
      await _dioClient.post(
        '/finance/payments/$paymentId/refund',
        data: {
          'reason': reason,
        },
      );
    } catch (e) {
      rethrow;
    }
  }
}
