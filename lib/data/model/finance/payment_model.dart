import '../../../domain/entity/finance/payment_entity.dart';

class PaymentModel extends PaymentEntity {
  PaymentModel({
    required super.id,
    required super.invoiceId,
    required super.paymentMethod,
    super.paymentProofUrl,
    super.transactionId,
    required super.status,
    super.adminNotes,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] ?? 0,
      invoiceId: json['invoice_id'] ?? 0,
      paymentMethod: json['payment_method'] ?? '',
      paymentProofUrl: json['payment_proof_url'] ?? json['payment_proof_path'],
      transactionId: json['transaction_id'],
      status: json['status'] ?? 'pending',
      adminNotes: json['admin_notes'],
    );
  }
}
