class InvoiceEntity {
  final int id;
  final int leaseId;
  final String invoiceNumber;
  final double amount;
  final String status;
  final DateTime dueDate;
  final String? residentName;
  final String? roomNumber;
  final DateTime? createdAt;

  InvoiceEntity({
    required this.id,
    required this.leaseId,
    required this.invoiceNumber,
    required this.amount,
    required this.status,
    required this.dueDate,
    this.residentName,
    this.roomNumber,
    this.createdAt,
  });
}
