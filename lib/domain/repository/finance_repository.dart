import 'dart:typed_data';
import 'package:frontend/domain/entity/finance/kpi_entity.dart';
import 'package:frontend/domain/entity/finance/revenue_entity.dart';
import '../entity/finance/invoice_entity.dart';
import '../entity/finance/payment_entity.dart';
import '../entity/finance/expense_entity.dart';
import '../entity/finance/member_finance_summary_entity.dart';

abstract class FinanceRepository {
  Future<List<InvoiceEntity>> getDueInvoices();
  Future<List<InvoiceEntity>> getInvoices();
  Future<List<PaymentEntity>> getPendingPayments();
  Future<List<PaymentEntity>> getAllPayments();
  Future<KpiEntity> getKpiSummary({int? month, int? year});
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

  // Member Finance
  Future<MemberFinanceSummaryEntity> getMemberFinanceSummary();
  Future<List<InvoiceEntity>> getMemberInvoices();
  Future<List<PaymentEntity>> getMemberPayments();
  Future<PaymentEntity> payInvoice(
    int invoiceId,
    String paymentMethod, {
    Uint8List? paymentProofBytes,
    String? paymentProofName,
  });
  Future<void> extendLease(int leaseId, int durationMonths);
  Future<String> getInvoicePrintLink(int invoiceId);
}
