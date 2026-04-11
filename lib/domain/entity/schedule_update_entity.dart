import 'package:equatable/equatable.dart';

class ScheduleUpdateEntity extends Equatable {
  final int id;
  final int scheduleId;
  final String userName;
  final String? status;
  final String notes;
  final DateTime createdAt;

  const ScheduleUpdateEntity({
    required this.id,
    required this.scheduleId,
    required this.userName,
    this.status,
    required this.notes,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, scheduleId, userName, status, notes, createdAt];
}
