class MidtransMonitoringEntity {
  final int totalTransaksi;
  final double totalSettlement;
  final int jumlahSettlement;
  final int jumlahPending;
  final double settlementBulanIni;
  final int bulan;
  final int tahun;

  MidtransMonitoringEntity({
    required this.totalTransaksi,
    required this.totalSettlement,
    required this.jumlahSettlement,
    required this.jumlahPending,
    required this.settlementBulanIni,
    required this.bulan,
    required this.tahun,
  });
}
