import 'package:frontend/domain/entity/finance/kpi_entity.dart';
import 'package:frontend/domain/entity/finance/revenue_entity.dart';
import '../entity/finance/invoice_entity.dart';
import '../entity/finance/payment_entity.dart';
import '../entity/finance/expense_entity.dart';

abstract class FinanceRepository {
  Future<List<InvoiceEntity>> getDueInvoices();
  Future<List<InvoiceEntity>> getInvoices();
  Future<List<PaymentEntity>> getPendingPayments();
  Future<KpiEntity> getKpiSummary();
  Future<List<RevenueEntity>> getRevenueChart();

  // Expense
  Future<List<ExpenseEntity>> getExpenses();
  Future<ExpenseEntity> createExpense(ExpenseEntity expense);
  Future<ExpenseEntity> updateExpense(ExpenseEntity expense);
  Future<void> deleteExpense(int id);

  //verifikasi pembayaran
  Future<bool> verifyPayment(int paymentId, bool isApproved, String? adminNotes);

  //refund pembayaran
  Future<bool> refundPayment(int paymentId, String reason);
}
