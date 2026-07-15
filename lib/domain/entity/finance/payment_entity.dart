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
  final int midtransFee;
  final String? feeBearer;
  final double grossAmount;
  final String paymentDate;
  final String? snapToken;
  final Map<String, dynamic>? paymentData;
  final String? residentName;
  final String? roomNumber;
  final String? updatedAt;
  final String? invoiceType; // 'sewa' | 'dp' | 'pelunasan' | 'extension' | 'fine'

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
    this.midtransFee = 0,
    this.feeBearer,
    double? grossAmount,
    required this.paymentDate,
    this.snapToken,
    this.paymentData,
    this.residentName,
    this.roomNumber,
    this.updatedAt,
    this.invoiceType,
  }) : grossAmount = grossAmount ?? amount;
}