class FixedExpenseJenisStatusEntity {
  final bool filled;
  final int? entryId;
  final double? amount;
  final String? notes;

  FixedExpenseJenisStatusEntity({
    required this.filled,
    this.entryId,
    this.amount,
    this.notes,
  });
}

class FixedExpenseStatusEntity {
  final int bulan;
  final int tahun;
  final bool semuaTerisi;
  final List<String> belumDiisi;
  final Map<String, FixedExpenseJenisStatusEntity> detail;

  FixedExpenseStatusEntity({
    required this.bulan,
    required this.tahun,
    required this.semuaTerisi,
    required this.belumDiisi,
    required this.detail,
  });
}
