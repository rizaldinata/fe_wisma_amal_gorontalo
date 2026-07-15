class InvoiceEntity {
  final int id;
  final int leaseId;
  final String invoiceNumber;
  final double amount;
  final String status;
  final DateTime dueDate;
  final DateTime? paymentExpiresAt;
  final String? periodStart;
  final String? periodEnd;
  final String? residentName;
  final String? roomNumber;
  final DateTime? createdAt;
  final String? type; // 'sewa' | 'dp' | 'pelunasan' | 'extension' | 'fine'

  InvoiceEntity({
    required this.id,
    required this.leaseId,
    required this.invoiceNumber,
    required this.amount,
    required this.status,
    required this.dueDate,
    this.paymentExpiresAt,
    this.periodStart,
    this.periodEnd,
    this.residentName,
    this.roomNumber,
    this.createdAt,
    this.type,
  });

  bool get isDp => type == 'dp';
  bool get isPelunasan => type == 'pelunasan';
}
