class FixedExpenseEntryEntity {
  final int id;
  final String jenis;
  final String jenisLabel;
  final int bulan;
  final int tahun;
  final double amount;
  final bool isFilled;
  final String? notes;

  FixedExpenseEntryEntity({
    required this.id,
    required this.jenis,
    required this.jenisLabel,
    required this.bulan,
    required this.tahun,
    required this.amount,
    required this.isFilled,
    this.notes,
  });
}
