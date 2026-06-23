class ResidentResponse {
  final List<ResidentItem> residents;
  final PaginationEntity pagination;
  final ResidentStats stats;

  ResidentResponse({
    required this.residents,
    required this.pagination,
    required this.stats,
  });

  factory ResidentResponse.fromJson(Map<String, dynamic> json) {
    // Membaca key yang benar dari response backend: 'residents', 'pagination', 'stats'
    final residentsList = json['residents'] as List<dynamic>? ?? <dynamic>[];
    final paginationMap = json['pagination'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final statsMap = json['stats'] as Map<String, dynamic>?;

    final items = residentsList
        .map((item) => ResidentItem.fromJson(item as Map<String, dynamic>))
        .toList();

    return ResidentResponse(
      stats: statsMap != null 
          ? ResidentStats.fromJson(statsMap) 
          : ResidentStats(
              penghuniAktif: items.where((i) => i.status == 'Active').length,
              kontrakPending: items.where((i) => i.status == 'Pending').length,
              kamarTersedia: 0,
            ),
      residents: items,
      pagination: PaginationEntity.fromJson(paginationMap),
    );
  }
}

class ResidentItem {
  final String id;
  final String nama;
  final String kamar;
  final String kontak;
  final String detailBayar;
  final String status;

  ResidentItem({
    required this.id,
    required this.nama,
    required this.kamar,
    required this.kontak,
    required this.detailBayar,
    required this.status,
  });

  factory ResidentItem.fromJson(Map<String, dynamic> json) {
    return ResidentItem(
      id: json['id'].toString(),
      nama: json['nama'] ?? '-',
      kamar: json['kamar'] ?? '-',
      kontak: json['kontak'] ?? '-',
      detailBayar: json['detailBayar'] ?? 'Belum Lunas',
      status: json['status'] ?? 'Pending',
    );
  }
}

class ResidentStats {
  final int penghuniAktif;
  final int kontrakPending;
  final int kamarTersedia;

  ResidentStats({
    required this.penghuniAktif,
    required this.kontrakPending,
    required this.kamarTersedia,
  });

  factory ResidentStats.fromJson(Map<String, dynamic> json) {
    return ResidentStats(
      penghuniAktif: json['penghuniAktif'] ?? 0,
      kontrakPending: json['kontrakPending'] ?? 0,
      kamarTersedia: json['kamarTersedia'] ?? 0,
    );
  }
}

class PaginationEntity {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  PaginationEntity({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory PaginationEntity.fromJson(Map<String, dynamic> json) {
    return PaginationEntity(
      currentPage: json['currentPage'] ?? 1,
      lastPage: json['lastPage'] ?? 1,
      perPage: json['perPage'] ?? 10,
      total: json['total'] ?? 0,
    );
  }
}