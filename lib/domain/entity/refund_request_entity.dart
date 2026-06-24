import 'package:equatable/equatable.dart';

class RefundRequestEntity extends Equatable {
  final int id;
  final String status; // pending | processed | rejected
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

  const RefundRequestEntity({
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

  String get tenantName => payment['tenant_name']?.toString() ?? '-';
  String get invoiceNumber => payment['invoice_number']?.toString() ?? '-';
  String get roomNumber => schedule['room']?.toString() ?? '-';
  String get startDate => schedule['start_date']?.toString() ?? '-';

  @override
  List<Object?> get props => [
        id,
        status,
        isRefundEligible,
        bankName,
        accountNumber,
        accountHolderName,
        refundAmount,
        adminFee,
        proofUrl,
        adminNotes,
        processedAt,
        schedule,
        payment,
        createdAt,
        updatedAt,
      ];
}
