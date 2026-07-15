import 'package:frontend/domain/entity/refund_request_entity.dart';

class RefundRequestModel {
  final int id;
  final String status;
  final bool isRefundEligible;
  final String bankName;
  final String accountNumber;
  final String accountHolderName;
  final double refundAmount;
  final double? adminFee;
  final String? proofUrl;
  final String? adminNotes;
  final String? processedAt;
  final Map<String, dynamic> schedule;
  final Map<String, dynamic> payment;
  final String createdAt;
  final String? updatedAt;

  const RefundRequestModel({
    required this.id,
    required this.status,
    required this.isRefundEligible,
    required this.bankName,
    required this.accountNumber,
    required this.accountHolderName,
    required this.refundAmount,
    this.adminFee,
    this.proofUrl,
    this.adminNotes,
    this.processedAt,
    required this.schedule,
    required this.payment,
    required this.createdAt,
    this.updatedAt,
  });

  factory RefundRequestModel.fromJson(Map<String, dynamic> json) {
    return RefundRequestModel(
      id: json['id'] as int,
      status: json['status']?.toString() ?? 'pending',
      isRefundEligible: json['is_refund_eligible'] as bool? ?? false,
      bankName: json['bank_name']?.toString() ?? '',
      accountNumber: json['account_number']?.toString() ?? '',
      accountHolderName: json['account_holder_name']?.toString() ?? '',
      refundAmount: (json['refund_amount'] as num?)?.toDouble() ?? 0,
      adminFee: (json['admin_fee'] as num?)?.toDouble(),
      proofUrl: json['proof_url']?.toString(),
      adminNotes: json['admin_notes']?.toString(),
      processedAt: json['processed_at']?.toString(),
      schedule: json['schedule'] as Map<String, dynamic>? ?? {},
      payment: json['payment'] as Map<String, dynamic>? ?? {},
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString(),
    );
  }

  RefundRequestEntity toEntity() {
    return RefundRequestEntity(
      id: id,
      status: status,
      isRefundEligible: isRefundEligible,
      bankName: bankName,
      accountNumber: accountNumber,
      accountHolderName: accountHolderName,
      refundAmount: refundAmount,
      adminFee: adminFee,
      proofUrl: proofUrl,
      adminNotes: adminNotes,
      processedAt: processedAt,
      schedule: schedule,
      payment: payment,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
