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
    // Schedule API: {success: true, data: [...], meta: {...}, links: {...}}
    final schedulesList = json['data'] as List<dynamic>? ?? <dynamic>[];
    final metaMap =
        json['meta'] as Map<String, dynamic>? ?? <String, dynamic>{};

    final scheduleItems = schedulesList
        .map((item) => ResidentItem.fromJson(item as Map<String, dynamic>))
        .toList();

    // Membaca key yang benar dari response backend: 'residents', 'pagination', 'stats'
    final residentsList = json['residents'] as List<dynamic>? ?? <dynamic>[];
    final paginationMap = json['pagination'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final statsMap = json['stats'] as Map<String, dynamic>?;

    final residentItems = residentsList
        .map((item) => ResidentItem.fromJson(item as Map<String, dynamic>))
        .toList();

    final finalItems = residentItems.isNotEmpty ? residentItems : scheduleItems;

    return ResidentResponse(
      stats: statsMap != null 
          ? ResidentStats.fromJson(statsMap) 
          : ResidentStats(
              penghuniAktif: finalItems.where((i) => i.status.toLowerCase() == 'active').length,
              kontrakPending: finalItems.where((i) => i.status.toLowerCase() == 'pending').length,
              kamarTersedia: 0,
            ),
      residents: finalItems,
      pagination: PaginationEntity.fromJson(paginationMap.isNotEmpty ? paginationMap : metaMap),
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
    final tenant = json['tenant'] as Map<String, dynamic>?;
    final room = json['room'] as Map<String, dynamic>?;

    return ResidentItem(
      id: json['id']?.toString() ?? '',
      nama: tenant?['name'] ?? '-',
      kamar: room?['number'] ?? '-',
      kontak: tenant?['phone'] ?? '-',
      detailBayar: json['payment_status'] ?? 'Belum Lunas',
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
      penghuniAktif: json['penghuni_aktif'] ?? 0,
      kontrakPending: json['kontrak_pending'] ?? 0,
      kamarTersedia: json['kamar_tersedia'] ?? 0,
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
