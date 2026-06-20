import '../../../domain/entity/finance/fixed_expense_entry_entity.dart';

class FixedExpenseEntryModel extends FixedExpenseEntryEntity {
  FixedExpenseEntryModel({
    required super.id,
    required super.jenis,
    required super.jenisLabel,
    required super.bulan,
    required super.tahun,
    required super.amount,
    required super.isFilled,
    super.notes,
  });

  factory FixedExpenseEntryModel.fromJson(Map<String, dynamic> json) {
    return FixedExpenseEntryModel(
      id: json['id'] ?? 0,
      jenis: json['jenis'] ?? '',
      jenisLabel: json['jenis_label'] ?? json['jenis'] ?? '',
      bulan: json['bulan'] ?? 0,
      tahun: json['tahun'] ?? 0,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      isFilled: json['is_filled'] == true,
      notes: json['notes'],
    );
  }
}
