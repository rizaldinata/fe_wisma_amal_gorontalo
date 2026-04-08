class KpiEntity {
  final double totalRevenue;
  final int pendingPaymentsCount;
  final int dueInvoicesCount;
  final double dueInvoicesTotal;

  KpiEntity({
    required this.totalRevenue,
    required this.pendingPaymentsCount,
    required this.dueInvoicesCount,
    required this.dueInvoicesTotal,
  });
}
