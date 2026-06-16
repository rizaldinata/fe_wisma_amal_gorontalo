import 'package:frontend/domain/entity/guest/guest_bill_entity.dart';

class GuestItem {
  final int id;
  final String name;
  final String checkInAt;
  final String checkOutAt;
  final String relationship;
  final String relationshipLabel;
  final String? stayCompletedNotifiedAt;
  final String penghuni;
  final String kamar;

  const GuestItem({
    required this.id,
    required this.name,
    required this.checkInAt,
    required this.checkOutAt,
    required this.relationship,
    required this.relationshipLabel,
    this.stayCompletedNotifiedAt,
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
      stayCompletedNotifiedAt: json['stay_completed_notified_at'] as String?,
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
  final String? stayCompletedNotifiedAt;
  final int totalDays;
  final int billableDays;
  final double chargeAmount;
  final GuestBillItem? bill;

  const MyGuestItem({
    required this.id,
    required this.name,
    required this.checkInAt,
    required this.checkOutAt,
    required this.relationship,
    required this.relationshipLabel,
    this.stayCompletedNotifiedAt,
    this.totalDays = 0,
    this.billableDays = 0,
    this.chargeAmount = 0.0,
    this.bill,
  });

  factory MyGuestItem.fromJson(Map<String, dynamic> json) {
    final billJson = json['bill'] as Map<String, dynamic>?;
    return MyGuestItem(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '-',
      checkInAt: json['check_in_at'] as String? ?? '-',
      checkOutAt: json['check_out_at'] as String? ?? '-',
      relationship: json['relationship'] as String? ?? '-',
      relationshipLabel: json['relationship_label'] as String? ?? '-',
      stayCompletedNotifiedAt: json['stay_completed_notified_at'] as String?,
      totalDays: json['total_days'] as int? ?? 0,
      billableDays: json['billable_days'] as int? ?? 0,
      chargeAmount: (json['charge_amount'] as num?)?.toDouble() ?? 0.0,
      bill: billJson != null ? GuestBillItem.fromJson(billJson) : null,
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
    final data = json['data'];
    List<dynamic> items = <dynamic>[];
    Map<String, dynamic> meta = <String, dynamic>{};

    if (data is List<dynamic>) {
      items = data;
    } else if (data is Map<String, dynamic>) {
      if (data['data'] is List<dynamic>) {
        items = data['data'] as List<dynamic>;
      } else if (data['guests'] is List<dynamic>) {
        items = data['guests'] as List<dynamic>;
      } else if (data['items'] is List<dynamic>) {
        items = data['items'] as List<dynamic>;
      }

      if (data['meta'] is Map<String, dynamic>) {
        meta = Map<String, dynamic>.from(data['meta'] as Map);
      } else if (data['pagination'] is Map<String, dynamic>) {
        meta = Map<String, dynamic>.from(data['pagination'] as Map);
      } else if (data.containsKey('current_page')) {
        meta = data;
      }
    }

    return GuestResponse(
      guests: items
          .map((e) => GuestItem.fromJson(
              e is Map<String, dynamic> ? e : <String, dynamic>{}))
          .toList(),
      pagination: GuestPagination.fromJson(meta),
    );
  }
}
