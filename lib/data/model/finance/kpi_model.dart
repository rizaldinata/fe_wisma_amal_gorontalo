import '../../../domain/entity/finance/kpi_entity.dart';

class KpiModel extends KpiEntity {
  KpiModel({
    required super.totalRevenue,
    required super.revenueMonthlyRents,
    required super.revenueDailyRents,
    required super.totalExpense,
    required super.netProfit,
    required super.pendingPaymentsCount,
    required super.dueInvoicesCount,
    required super.dueInvoicesTotal,
  });

  factory KpiModel.fromJson(Map<String, dynamic> json) {
    final totalRevenue = json['total_revenue_this_month'] != null
        ? double.tryParse(json['total_revenue_this_month'].toString()) ?? 0.0
        : 0.0;
    final totalExpense = json['total_expense'] != null
        ? double.tryParse(json['total_expense'].toString()) ?? 0.0
        : 0.0;
    final netProfit = json['net_profit'] != null
        ? double.tryParse(json['net_profit'].toString()) ?? 0.0
        : totalRevenue - totalExpense;

    return KpiModel(
      totalRevenue: totalRevenue,
      revenueMonthlyRents: json['revenue_monthly_rents'] != null
          ? double.tryParse(json['revenue_monthly_rents'].toString()) ?? 0.0
          : 0.0,
      revenueDailyRents: json['revenue_daily_rents'] != null
          ? double.tryParse(json['revenue_daily_rents'].toString()) ?? 0.0
          : 0.0,
      totalExpense: totalExpense,
      netProfit: netProfit,

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
