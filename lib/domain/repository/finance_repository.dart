import 'dart:typed_data';
import 'package:frontend/domain/entity/finance/kpi_entity.dart';
import 'package:frontend/domain/entity/finance/revenue_entity.dart';
import '../entity/finance/fine_eligible_user_entity.dart';
import '../entity/finance/fine_entity.dart';
import '../entity/finance/invoice_entity.dart';
import '../entity/finance/payment_entity.dart';
import '../entity/finance/expense_entity.dart';
import '../entity/finance/member_finance_summary_entity.dart';
import '../entity/setting/midtrans_method_entity.dart';
import '../entity/finance/midtrans_monitoring_entity.dart';

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
  Future<InvoiceEntity> getMemberInvoiceById(int id);
  Future<List<PaymentEntity>> getMemberPayments();
  Future<PaymentEntity> payInvoice(
    int invoiceId,
    String paymentMethod, {
    Uint8List? paymentProofBytes,
    String? paymentProofName,
    String? preferredPaymentType,
  });
  Future<InvoiceEntity> initiatePerpanjangManual(int leaseId, int durationMonths);
  Future<PaymentEntity> extendLease(
    int leaseId,
    int durationMonths,
    String paymentMethod, {
    Uint8List? paymentProofBytes,
    String? paymentProofName,
    String? preferredPaymentType,
  });
  Future<String> getInvoicePrintLink(int invoiceId);
  Future<List<MidtransMethodEntity>> getAvailablePaymentMethods();
  Future<MidtransMonitoringEntity> getMidtransMonitoring();

  // Fine (Denda)
  Future<List<FineEntity>> getMyFines({String? status});
  Future<PaymentEntity> payFines(
    List<int> fineIds,
    String paymentMethod, {
    Uint8List? paymentProofBytes,
    String? paymentProofName,
    String? preferredPaymentType,
  });
  Future<List<FineEntity>> getAllFines({String? status, int? tenantUserId});
  Future<FineEntity> createFine({required int tenantUserId, required double amount, required String reason});
  Future<FineEntity> waiveFine(int fineId, String waiveReason);
  Future<FineEntity> cancelFine(int fineId);
  Future<List<FineEligibleUserEntity>> getFineEligibleUsers();
}
