import 'package:frontend/domain/entity/finance/kpi_entity.dart';
import 'package:frontend/domain/entity/finance/revenue_entity.dart';
import '../entity/finance/invoice_entity.dart';
import '../entity/finance/payment_entity.dart';

abstract class FinanceRepository {
  Future<List<InvoiceEntity>> getDueInvoices();
  Future<List<PaymentEntity>> getPendingPayments();
  Future<KpiEntity> getKpiSummary();
  Future<List<RevenueEntity>> getRevenueChart();
}
