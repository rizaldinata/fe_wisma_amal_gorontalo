class PaymentEntity {
  final int id;
  final int invoiceId;
  final String? invoiceNumber;
  final String paymentMethod;
  final String? paymentProofUrl;
  final String? transactionId;
  final String status;
  final String? adminNotes;
  final double amount;
  final String paymentDate;
  final String? snapToken;
  final String? residentName;
  final String? roomNumber;
  final String? updatedAt;

  PaymentEntity({
    required this.id,
    required this.invoiceId,
    this.invoiceNumber,
    required this.paymentMethod,
    this.paymentProofUrl,
    this.transactionId,
    required this.status,
    this.adminNotes,
    required this.amount,
    required this.paymentDate,
    this.snapToken,
    this.residentName,
    this.roomNumber,
    this.updatedAt,
  });
}