import 'package:equatable/equatable.dart';

class RoomScheduleEntity extends Equatable {
  final int id;
  final String title;
  final String number;
  final String status;
  final List<LeaseScheduleEntity> schedules;

  const RoomScheduleEntity({
    required this.id,
    required this.title,
    required this.number,
    required this.status,
    required this.schedules,
  });

  @override
  List<Object?> get props => [id, title, number, status, schedules];
}

class LeaseScheduleEntity extends Equatable {
  final int id;
  final String startDate;
  final String endDate;
  final String status;
  final String? tenantName;

  const LeaseScheduleEntity({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.tenantName,
  });

  @override
  List<Object?> get props => [id, startDate, endDate, status, tenantName];
}
