class GuestItem {
  final int id;
  final String name;
  final String checkInAt;
  final String checkOutAt;
  final String relationship;
  final String relationshipLabel;
  final String penghuni;
  final String kamar;

  const GuestItem({
    required this.id,
    required this.name,
    required this.checkInAt,
    required this.checkOutAt,
    required this.relationship,
    required this.relationshipLabel,
    required this.penghuni,
    required this.kamar,
  });

  factory GuestItem.fromJson(Map<String, dynamic> json) {
    return GuestItem(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '-',
      checkInAt: json['check_in_at'] as String? ?? '-',
      checkOutAt: json['check_out_at'] as String? ?? '-',
      relationship: json['relationship'] as String? ?? '-',
      relationshipLabel: json['relationship_label'] as String? ?? '-',
      penghuni: json['penghuni'] as String? ?? '-',
      kamar: json['kamar'] as String? ?? '-',
    );
  }
}

class GuestPagination {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  const GuestPagination({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory GuestPagination.fromJson(Map<String, dynamic> json) {
    return GuestPagination(
      currentPage: json['current_page'] as int? ?? 1,
      lastPage: json['last_page'] as int? ?? 1,
      perPage: json['per_page'] as int? ?? 10,
      total: json['total'] as int? ?? 0,
    );
  }
}

// ─── Entity untuk penghuni (resident) ────────────────────────────────────────

class MyGuestItem {
  final int id;
  final String name;
  final String checkInAt;
  final String checkOutAt;
  final String relationship;
  final String relationshipLabel;

  const MyGuestItem({
    required this.id,
    required this.name,
    required this.checkInAt,
    required this.checkOutAt,
    required this.relationship,
    required this.relationshipLabel,
  });

  factory MyGuestItem.fromJson(Map<String, dynamic> json) {
    return MyGuestItem(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '-',
      checkInAt: json['check_in_at'] as String? ?? '-',
      checkOutAt: json['check_out_at'] as String? ?? '-',
      relationship: json['relationship'] as String? ?? '-',
      relationshipLabel: json['relationship_label'] as String? ?? '-',
    );
  }
}

// ─── Entity untuk admin ───────────────────────────────────────────────────────

class GuestResponse {
  final List<GuestItem> guests;
  final GuestPagination pagination;

  const GuestResponse({
    required this.guests,
    required this.pagination,
  });

  factory GuestResponse.fromJson(Map<String, dynamic> json) {
    final outer = json['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final items = outer['data'] as List<dynamic>? ?? <dynamic>[];
    final meta = outer['meta'] as Map<String, dynamic>? ?? <String, dynamic>{};

    return GuestResponse(
      guests: items.map((e) => GuestItem.fromJson(e as Map<String, dynamic>)).toList(),
      pagination: GuestPagination.fromJson(meta),
    );
  }
}
