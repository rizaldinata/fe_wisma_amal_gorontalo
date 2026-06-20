import '../../../domain/entity/finance/fixed_expense_status_entity.dart';

class FixedExpenseStatusModel extends FixedExpenseStatusEntity {
  FixedExpenseStatusModel({
    required super.bulan,
    required super.tahun,
    required super.semuaTerisi,
    required super.belumDiisi,
    required super.detail,
  });

  factory FixedExpenseStatusModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> rawDetail = {};
    if (json['detail'] is Map) {
      (json['detail'] as Map).forEach((key, value) {
        rawDetail[key.toString()] = value;
      });
    }

    final detail = rawDetail.map((key, value) {
      final v = value is Map ? value : {};
      return MapEntry(
        key,
        FixedExpenseJenisStatusEntity(
          filled: v['filled'] == true,
          entryId: v['entry_id'] as int?,
          amount: (v['amount'] as num?)?.toDouble(),
          notes: v['notes'] as String?,
        ),
      );
    });

    final rawBelum = json['belum_diisi'] is List ? json['belum_diisi'] as List : [];

    return FixedExpenseStatusModel(
      bulan: json['bulan'] ?? 0,
      tahun: json['tahun'] ?? 0,
      semuaTerisi: json['semua_terisi'] == true,
      belumDiisi: rawBelum.map((e) => e.toString()).toList(),
      detail: detail,
    );
  }
}
