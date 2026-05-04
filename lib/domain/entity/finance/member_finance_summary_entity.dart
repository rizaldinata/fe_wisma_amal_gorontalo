class MemberFinanceSummaryEntity {
  final String residentName;
  final ActiveLeaseEntity? activeLease;
  final double totalUnpaid;
  final int unpaidCount;

  MemberFinanceSummaryEntity({
    required this.residentName,
    this.activeLease,
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
