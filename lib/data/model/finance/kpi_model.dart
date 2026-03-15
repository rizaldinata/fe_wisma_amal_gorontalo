import '../../../domain/entity/finance/kpi_entity.dart';

class KpiModel extends KpiEntity {
  KpiModel({
    required super.totalRevenue,
    required super.pendingPaymentsCount,
    required super.dueInvoicesCount,
    required super.dueInvoicesTotal,
  });

  factory KpiModel.fromJson(Map<String, dynamic> json) {
    return KpiModel(
      totalRevenue: json['total_revenue_this_month'] != null
          ? double.tryParse(json['total_revenue_this_month'].toString()) ?? 0.0
          : 0.0,

      pendingPaymentsCount: json['pending_verification_count'] ?? 0,

      dueInvoicesCount:
          json['totoal_unpaid_invoices'] ?? json['total_unpaid_invoices'] ?? 0,

      dueInvoicesTotal: json['due_invoices_total'] != null
          ? double.tryParse(json['due_invoices_total'].toString()) ?? 0.0
          : 0.0,
    );
  }
}
