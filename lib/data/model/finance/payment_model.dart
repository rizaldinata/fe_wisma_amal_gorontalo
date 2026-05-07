import '../../../domain/entity/finance/payment_entity.dart';

class PaymentModel extends PaymentEntity {
  PaymentModel({
    required super.id,
    required super.invoiceId,
    super.invoiceNumber,
    required super.paymentMethod,
    super.paymentProofUrl,
    super.transactionId,
    required super.status,
    super.adminNotes,
    required super.amount,
    required super.paymentDate,
    super.snapToken,
    super.residentName,
    super.roomNumber,
    super.updatedAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] ?? 0,
      invoiceId: json['invoice_id'] ?? 0,
      invoiceNumber: json['invoice_number'] as String?,
      paymentMethod: json['payment_method'] ?? '',
      paymentProofUrl: json['payment_proof_url'] ?? json['payment_proof_path'],
      transactionId: json['transaction_id'],
      status: json['status'] ?? 'pending',
      adminNotes: json['admin_notes'],
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      paymentDate: json['payment_date'] ?? json['created_at'] ?? '',
      snapToken: json['snap_token'],
      residentName: json['resident_name'] as String?,
      roomNumber: json['room_number'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }
}