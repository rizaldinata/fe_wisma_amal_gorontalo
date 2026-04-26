class PaymentEntity {
  final int id;
  final int invoiceId;
  final String paymentMethod;
  final String? paymentProofUrl;
  final String? transactionId;
  final String status;
  final String? adminNotes;
  final double amount;
  final String paymentDate;

  PaymentEntity({
    required this.id,
    required this.invoiceId,
    required this.paymentMethod,
    this.paymentProofUrl,
    this.transactionId,
    required this.status,
    this.adminNotes,
    required this.amount,
    required this.paymentDate,
  });
}