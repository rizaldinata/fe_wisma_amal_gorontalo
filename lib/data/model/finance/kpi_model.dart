import '../../../domain/entity/finance/kpi_entity.dart';

class KpiModel extends KpiEntity {
  KpiModel({
    required super.totalRevenue,
    required super.revenueMonthlyRents,
    required super.revenueDailyRents,
    required super.pendingPaymentsCount,
    required super.dueInvoicesCount,
    required super.dueInvoicesTotal,
  });

  factory KpiModel.fromJson(Map<String, dynamic> json) {
    return KpiModel(
      totalRevenue: json['total_revenue_this_month'] != null
          ? double.tryParse(json['total_revenue_this_month'].toString()) ?? 0.0
          : 0.0,
      revenueMonthlyRents: json['revenue_monthly_rents'] != null
          ? double.tryParse(json['revenue_monthly_rents'].toString()) ?? 0.0
          : 0.0,
      revenueDailyRents: json['revenue_daily_rents'] != null
          ? double.tryParse(json['revenue_daily_rents'].toString()) ?? 0.0
          : 0.0,

      pendingPaymentsCount: json['pending_verification_count'] ?? 0,

      dueInvoicesCount: json['overdue_invoices_count'] ??
          json['totoal_unpaid_invoices'] ??
          json['total_unpaid_invoices'] ??
          0,

      dueInvoicesTotal: json['total_unpaid_invoices_amount'] != null
          ? double.tryParse(json['total_unpaid_invoices_amount'].toString()) ?? 0.0
          : (json['due_invoices_total'] != null
              ? double.tryParse(json['due_invoices_total'].toString()) ?? 0.0
              : 0.0),
    );
  }
}
