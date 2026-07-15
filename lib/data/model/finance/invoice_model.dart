import '../../../domain/entity/finance/invoice_entity.dart';

class InvoiceModel extends InvoiceEntity {
  InvoiceModel({
    required super.id,
    required super.leaseId,
    required super.invoiceNumber,
    required super.amount,
    required super.status,
    required super.dueDate,
    super.paymentExpiresAt,
    super.periodStart,
    super.periodEnd,
    super.residentName,
    super.roomNumber,
    super.createdAt,
    super.type,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    final lease = json['lease'] as Map<String, dynamic>?;
    return InvoiceModel(
      id: json['id'] ?? 0,
      leaseId: lease?['id'] ?? json['lease_id'] ?? 0,
      invoiceNumber: json['invoice_number'] ?? '',
      amount: json['amount'] != null
          ? double.parse(json['amount'].toString())
          : 0.0,
      status: json['status'] ?? 'unpaid',
      dueDate: DateTime.parse(
        json['due_date'] ?? DateTime.now().toIso8601String(),
      ),
      paymentExpiresAt: json['payment_expires_at'] != null
          ? DateTime.tryParse(json['payment_expires_at'].toString())
          : null,
      periodStart: json['period_start'] as String?,
      periodEnd: json['period_end'] as String?,
      residentName: lease?['resident_name'] as String?,
      roomNumber: lease?['room_number'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      type: json['type']?.toString(),
    );
  }
}
