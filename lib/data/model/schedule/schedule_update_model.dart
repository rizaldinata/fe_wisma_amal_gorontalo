import 'package:frontend/domain/entity/schedule_update_entity.dart';

class ScheduleUpdateModel extends ScheduleUpdateEntity {
  const ScheduleUpdateModel({
    required super.id,
    required super.scheduleId,
    required super.userName,
    super.status,
    required super.notes,
    required super.createdAt,
  });

  factory ScheduleUpdateModel.fromJson(Map<String, dynamic> json) {
    return ScheduleUpdateModel(
      id: json['id'],
      scheduleId: json['schedule_id'],
      userName: json['user_name'],
      status: json['status'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'schedule_id': scheduleId,
      'user_name': userName,
      'status': status,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
