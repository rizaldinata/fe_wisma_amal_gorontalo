import '../../../domain/entity/finance/member_finance_summary_entity.dart';

class MemberFinanceSummaryModel extends MemberFinanceSummaryEntity {
  MemberFinanceSummaryModel({
    required super.residentName,
    super.activeLeases = const [],
    required super.totalUnpaid,
    required super.unpaidCount,
  });

  factory MemberFinanceSummaryModel.fromJson(Map<String, dynamic> json) {
    return MemberFinanceSummaryModel(
      residentName: json['resident_name'] ?? '',
      activeLeases: (json['active_leases'] as List<dynamic>? ?? [])
          .map((e) => ActiveLeaseModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalUnpaid: (json['total_unpaid'] ?? 0.0).toDouble(),
      unpaidCount: json['unpaid_count'] ?? 0,
    );
  }
}

class ActiveLeaseModel extends ActiveLeaseEntity {
  ActiveLeaseModel({
    required super.id,
    required super.roomNumber,
    required super.endDate,
    required super.rentalType,
  });

  factory ActiveLeaseModel.fromJson(Map<String, dynamic> json) {
    return ActiveLeaseModel(
      id: json['id'] ?? 0,
      roomNumber: json['room_number'] ?? '',
      endDate: DateTime.parse(json['end_date']),
      rentalType: json['rental_type'] ?? '',
    );
  }
}
