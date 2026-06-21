class FineEntity {
  final int id;
  final int tenantUserId;
  final int? scheduleId;
  final String tenantName;
  final String? tenantPhone;
  final double amount;
  final String reason;
  final String status;
  final String? waiveReason;
  final DateTime? paidAt;
  final DateTime? createdAt;

  const FineEntity({
    required this.id,
    required this.tenantUserId,
    this.scheduleId,
    required this.tenantName,
    this.tenantPhone,
    required this.amount,
    required this.reason,
    required this.status,
    this.waiveReason,
    this.paidAt,
    this.createdAt,
  });

  bool get isUnpaid => status == 'unpaid';
  bool get isPaid => status == 'paid';
  bool get isWaived => status == 'waived';
  bool get isCancelled => status == 'cancelled';
}
