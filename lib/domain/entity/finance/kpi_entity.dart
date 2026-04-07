class KpiEntity {
  final double totalRevenue;
  final double revenueMonthlyRents;
  final double revenueDailyRents;
  final int pendingPaymentsCount;
  final int dueInvoicesCount;
  final double dueInvoicesTotal;

  KpiEntity({
    required this.totalRevenue,
    required this.revenueMonthlyRents,
    required this.revenueDailyRents,
    required this.pendingPaymentsCount,
    required this.dueInvoicesCount,
    required this.dueInvoicesTotal,
  });
}
