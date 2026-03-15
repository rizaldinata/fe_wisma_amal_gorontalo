class InvoiceEntity {
  final int id;
  final int leaseId;
  final String invoiceNumber;
  final double amount;
  final String status;
  final DateTime dueDate;

  InvoiceEntity({
    required this.id,
    required this.leaseId,
    required this.invoiceNumber,
    required this.amount,
    required this.status,
    required this.dueDate,
  });
}
