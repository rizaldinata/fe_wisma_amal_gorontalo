import 'dart:typed_data';
import 'package:frontend/domain/entity/finance/kpi_entity.dart';
import 'package:frontend/domain/entity/finance/revenue_entity.dart';
import '../../domain/entity/finance/invoice_entity.dart';
import '../../domain/entity/finance/payment_entity.dart';
import '../../domain/entity/finance/expense_entity.dart';
import '../../domain/entity/finance/member_finance_summary_entity.dart';
import '../../domain/repository/finance_repository.dart';
import '../datasource/finance_datasource.dart';
import '../model/finance/expense_model.dart';

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
  Future<List<InvoiceEntity>> getInvoices() async {
    try {
      final models = await remoteDatasource.getInvoices();
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

  @override
  Future<List<PaymentEntity>> getAllPayments() async {
    try {
      final models = await remoteDatasource.getAllPayments();
      return models;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<KpiEntity> getKpiSummary({int? month, int? year}) async {
    return await remoteDatasource.getKpiSummary(month: month, year: year);
  }

  @override
  Future<List<RevenueEntity>> getRevenueChart() async {
    return await remoteDatasource.getRevenueChart();
  }

  @override
  Future<List<ExpenseEntity>> getExpenses() async {
    return await remoteDatasource.getExpenses();
  }

  @override
  Future<ExpenseEntity> createExpense(ExpenseEntity expense) async {
    final model = ExpenseModel(
      id: expense.id,
      title: expense.title,
      amount: expense.amount,
      date: expense.date,
      category: expense.category,
      notes: expense.notes,
    );
    return await remoteDatasource.createExpense(model);
  }

  @override
  Future<ExpenseEntity> updateExpense(ExpenseEntity expense) async {
    final model = ExpenseModel(
      id: expense.id,
      title: expense.title,
      amount: expense.amount,
      date: expense.date,
      category: expense.category,
      notes: expense.notes,
    );
    return await remoteDatasource.updateExpense(model);
  }

  @override
  Future<void> deleteExpense(int id) async {
    return await remoteDatasource.deleteExpense(id);
  }

  @override
  Future<bool> verifyPayment(int paymentId, bool isApproved, String? adminNotes) async {
    try {
      await remoteDatasource.verifyPayment(paymentId, isApproved, adminNotes);
      return true;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> refundPayment(int paymentId, String reason) async {
    try {
      await remoteDatasource.refundPayment(paymentId, reason);
      return true;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<MemberFinanceSummaryEntity> getMemberFinanceSummary() async {
    return await remoteDatasource.getMemberFinanceSummary();
  }

  @override
  Future<List<InvoiceEntity>> getMemberInvoices() async {
    return await remoteDatasource.getMemberInvoices();
  }

  @override
  Future<InvoiceEntity> getMemberInvoiceById(int id) async {
    return await remoteDatasource.getMemberInvoiceById(id);
  }

  @override
  Future<List<PaymentEntity>> getMemberPayments() async {
    return await remoteDatasource.getMemberPayments();
  }

  @override
  Future<PaymentEntity> payInvoice(
    int invoiceId,
    String paymentMethod, {
    Uint8List? paymentProofBytes,
    String? paymentProofName,
    String? preferredPaymentType,
  }) async {
    return await remoteDatasource.payInvoice(
      invoiceId,
      paymentMethod,
      paymentProofBytes: paymentProofBytes,
      paymentProofName: paymentProofName,
      preferredPaymentType: preferredPaymentType,
    );
  }

  @override
  Future<PaymentEntity> extendLease(
    int leaseId,
    int durationMonths,
    String paymentMethod, {
    Uint8List? paymentProofBytes,
    String? paymentProofName,
    String? preferredPaymentType,
  }) async {
    return await remoteDatasource.extendLease(
      leaseId,
      durationMonths,
      paymentMethod,
      paymentProofBytes: paymentProofBytes,
      paymentProofName: paymentProofName,
      preferredPaymentType: preferredPaymentType,
    );
  }

  @override
  Future<String> getInvoicePrintLink(int invoiceId) async {
    return await remoteDatasource.getInvoicePrintLink(invoiceId);
  }
}
