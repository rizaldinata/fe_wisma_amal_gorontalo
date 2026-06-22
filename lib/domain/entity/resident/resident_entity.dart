class ResidentResponse {
  final ResidentStats stats;
  final List<ResidentItem> residents;
  final ResidentPagination pagination;

  ResidentResponse({
    required this.stats,
    required this.residents,
    required this.pagination,
  });

  factory ResidentResponse.fromJson(Map<String, dynamic> json) {
    // Schedule API: {success: true, data: [...], meta: {...}, links: {...}}
    final schedulesList = json['data'] as List<dynamic>? ?? <dynamic>[];
    final metaMap = json['meta'] as Map<String, dynamic>? ?? <String, dynamic>{};

    final items = schedulesList.map((item) => ResidentItem.fromJson(item as Map<String, dynamic>)).toList();

    final statsMap = json['stats'] as Map<String, dynamic>?;

    return ResidentResponse(
      stats: statsMap != null ? ResidentStats.fromJson(statsMap) : ResidentStats(
        penghuniAktif: items.where((i) => i.status == 'active').length,
        kontrakPending: items.where((i) => i.isPending).length,
        kontrakBerakhir: 0,
        kamarTersedia: 0,
      ),
      residents: items,
      pagination: ResidentPagination.fromJson(metaMap),
    );
  }
}

class ResidentPagination {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  const ResidentPagination({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory ResidentPagination.fromJson(Map<String, dynamic> json) {
    return ResidentPagination(
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      perPage: json['per_page'] ?? 10,
      total: json['total'] ?? 0,
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
    final tenantJson = json['tenant'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final roomJson = json['room'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final status = json['status']?.toString() ?? '-';

    return ResidentItem(
      id: json['id'].toString(),
      nama: tenantJson['name']?.toString() ?? '-',
      kamar: roomJson['number']?.toString() ?? '-',
      kontak: tenantJson['phone']?.toString() ?? '-',
      detailBayar: '-',
      isBelumLunas: false,
      status: status,
      isPending: status == 'pending',
    );
  }
}