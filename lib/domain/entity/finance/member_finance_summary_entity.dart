class MemberFinanceSummaryEntity {
  final String residentName;
  final List<ActiveLeaseEntity> activeLeases;
  final double totalUnpaid;
  final int unpaidCount;

  MemberFinanceSummaryEntity({
    required this.residentName,
    this.activeLeases = const [],
    required this.totalUnpaid,
    required this.unpaidCount,
  });
}

class ActiveLeaseEntity {
  final int id;
  final String roomNumber;
  final DateTime endDate;
  final String rentalType;

  ActiveLeaseEntity({
    required this.id,
    required this.roomNumber,
    required this.endDate,
    required this.rentalType,
  });
}
