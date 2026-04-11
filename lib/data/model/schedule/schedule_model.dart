import 'package:frontend/data/model/schedule/schedule_update_model.dart';
import 'package:frontend/domain/entity/schedule_entity.dart';

class ScheduleModel extends ScheduleEntity {
  const ScheduleModel({
    super.id,
    required super.technicianName,
    required super.location,
    required super.type,
    required super.subtype,
    required super.status,
    super.notes,
    required super.startTime,
    super.endTime,
    super.updates,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      id: json['id'] as int?,
      technicianName: json['technician_name'] as String? ?? '',
      location: json['location'] as String? ?? '',
      type: json['type'] as String? ?? 'pembersihan',
      subtype: json['subtype'] as String? ?? 'rutin',
      status: json['status'] as String? ?? 'in_progress',
      notes: json['notes'] as String?,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: json['end_time'] != null
          ? DateTime.parse(json['end_time'] as String)
          : null,
      updates: (json['updates'] as List?)
              ?.map((e) => ScheduleUpdateModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'technician_name': technicianName,
      'location': location,
      'type': type,
      'subtype': subtype,
      'status': status,
      if (notes != null) 'notes': notes,
      'start_time': startTime.toIso8601String(),
      if (endTime != null) 'end_time': endTime!.toIso8601String(),
    };
  }

  factory ScheduleModel.fromEntity(ScheduleEntity entity) {
    return ScheduleModel(
      id: entity.id,
      technicianName: entity.technicianName,
      location: entity.location,
      type: entity.type,
      subtype: entity.subtype,
      status: entity.status,
      notes: entity.notes,
      startTime: entity.startTime,
      endTime: entity.endTime,
      updates: entity.updates,
    );
  }
}
