import '../../../domain/entity/finance/midtrans_monitoring_entity.dart';

class MidtransMonitoringModel extends MidtransMonitoringEntity {
  MidtransMonitoringModel({
    required super.totalTransaksi,
    required super.totalSettlement,
    required super.jumlahSettlement,
    required super.jumlahPending,
    required super.settlementBulanIni,
    required super.bulan,
    required super.tahun,
  });

  factory MidtransMonitoringModel.fromJson(Map<String, dynamic> json) {
    return MidtransMonitoringModel(
      totalTransaksi: (json['total_transaksi'] as num?)?.toInt() ?? 0,
      totalSettlement: (json['total_settlement'] as num?)?.toDouble() ?? 0.0,
      jumlahSettlement: (json['jumlah_settlement'] as num?)?.toInt() ?? 0,
      jumlahPending: (json['jumlah_pending'] as num?)?.toInt() ?? 0,
      settlementBulanIni: (json['settlement_bulan_ini'] as num?)?.toDouble() ?? 0.0,
      bulan: (json['bulan'] as num?)?.toInt() ?? 0,
      tahun: (json['tahun'] as num?)?.toInt() ?? 0,
    );
  }
}
