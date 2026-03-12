import '../../../domain/entity/finance/invoice_entity.dart';

class InvoiceModel extends InvoiceEntity {
  InvoiceModel({
    required super.id,
    required super.leaseId,
    required super.invoiceNumber,
    required super.amount,
    required super.status,
    required super.dueDate,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      id: json['id'] ?? 0,
      leaseId: json['lease_id'] ?? 0,
      invoiceNumber: json['invoice_number'] ?? '',
      amount: json['amount'] != null
          ? double.parse(json['amount'].toString())
          : 0.0,
      status: json['status'] ?? 'unpaid',
      dueDate: DateTime.parse(
        json['due_date'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}
