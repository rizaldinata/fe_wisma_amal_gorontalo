class ResidentResponse {
  final ResidentStats stats;
  final List<ResidentItem> residents;

  ResidentResponse({required this.stats, required this.residents});

  factory ResidentResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final statsJson = data['stats'] as Map<String, dynamic>? ?? <String, dynamic>{};

    final dynamic residentsPayload = data['residents'];
    final List<dynamic> residentsList =
        residentsPayload is Map<String, dynamic>
            ? (residentsPayload['data'] as List<dynamic>? ?? <dynamic>[])
            : (residentsPayload as List<dynamic>? ?? <dynamic>[]);

    return ResidentResponse(
      stats: ResidentStats.fromJson(statsJson),
      residents: residentsList
          .map((item) => ResidentItem.fromJson(item))
          .toList(),
    );
  }
}

class ResidentStats {
  final int penghuniAktif;
  final int kontrakPending;
  final int kontrakBerakhir;
  final int kamarTersedia;

  ResidentStats({
    required this.penghuniAktif,
    required this.kontrakPending,
    required this.kontrakBerakhir,
    required this.kamarTersedia,
  });

  factory ResidentStats.fromJson(Map<String, dynamic> json) {
    return ResidentStats(
      penghuniAktif: json['penghuni_aktif'] ?? 0,
      kontrakPending: json['kontrak_pending'] ?? 0,
      kontrakBerakhir: json['kontrak_akan_berakhir'] ?? 0,
      kamarTersedia: json['kamar_tersedia'] ?? 0,
    );
  }
}

class ResidentItem {
  final String id;
  final String nama;
  final String kamar;
  final String kontak;
  final String detailBayar;
  final bool isBelumLunas;
  final String status;
  final bool isPending;

  ResidentItem({
    required this.id, required this.nama, required this.kamar,
    required this.kontak, required this.detailBayar, required this.isBelumLunas,
    required this.status, required this.isPending,
  });

  factory ResidentItem.fromJson(Map<String, dynamic> json) {
    return ResidentItem(
      id: json['id'].toString(),
      nama: json['nama'] ?? '-',
      kamar: json['kamar'] ?? '-',
      kontak: json['kontak'] ?? '-',
      detailBayar: json['detail_bayar'] ?? '-',
      isBelumLunas: json['is_belum_lunas'] ?? false,
      status: json['status'] ?? '-',
      isPending: json['is_pending'] ?? false,
    );
  }
}