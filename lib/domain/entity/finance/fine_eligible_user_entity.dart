class FineEligibleUserEntity {
  final int id;
  final String name;
  final String email;
  final String? phoneNumber;
  final String role;
  final String? activeRoomNumber;
  final String? activeRoomTitle;
  final String? scheduleEndDate;

  const FineEligibleUserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    required this.role,
    this.activeRoomNumber,
    this.activeRoomTitle,
    this.scheduleEndDate,
  });

  bool get isResident => role == 'resident';
  bool get hasActiveRoom => activeRoomNumber != null;

  String get roomLabel {
    if (activeRoomNumber == null) return '';
    final title = activeRoomTitle != null && activeRoomTitle!.isNotEmpty
        ? activeRoomTitle!
        : 'Kamar $activeRoomNumber';
    return '$title (No. $activeRoomNumber)';
  }
}
