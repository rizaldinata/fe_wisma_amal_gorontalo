import '../../../domain/entity/finance/fine_eligible_user_entity.dart';

class FineEligibleUserModel {
  final int id;
  final String name;
  final String email;
  final String? phoneNumber;
  final String role;
  final String? activeRoomNumber;
  final String? activeRoomTitle;
  final String? scheduleEndDate;

  const FineEligibleUserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    required this.role,
    this.activeRoomNumber,
    this.activeRoomTitle,
    this.scheduleEndDate,
  });

  factory FineEligibleUserModel.fromJson(Map<String, dynamic> json) {
    return FineEligibleUserModel(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      phoneNumber: json['phone_number'] as String?,
      role: json['role'] as String,
      activeRoomNumber: json['active_room_number'] as String?,
      activeRoomTitle: json['active_room_title'] as String?,
      scheduleEndDate: json['schedule_end_date'] as String?,
    );
  }

  FineEligibleUserEntity toEntity() => FineEligibleUserEntity(
    id: id,
    name: name,
    email: email,
    phoneNumber: phoneNumber,
    role: role,
    activeRoomNumber: activeRoomNumber,
    activeRoomTitle: activeRoomTitle,
    scheduleEndDate: scheduleEndDate,
  );
}
