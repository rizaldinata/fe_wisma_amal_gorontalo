import 'package:equatable/equatable.dart';
import 'package:frontend/domain/entity/schedule_update_entity.dart';

class ScheduleEntity extends Equatable {
  final int? id;
  final String technicianName;
  final String location;
  final String type; // pembersihan | perawatan
  final String subtype; // rutin | deep_cleaning | darurat | perbaikan | maintenance
  final String status; // in_progress | done | cancelled
  final String? notes;
  final DateTime startTime;
  final DateTime? endTime;
  final List<ScheduleUpdateEntity> updates;

  const ScheduleEntity({
    this.id,
    required this.technicianName,
    required this.location,
    required this.type,
    required this.subtype,
    required this.status,
    this.notes,
    required this.startTime,
    this.endTime,
    this.updates = const [],
  });

  ScheduleEntity copyWith({
    int? id,
    String? technicianName,
    String? location,
    String? type,
    String? subtype,
    String? status,
    String? notes,
    DateTime? startTime,
    DateTime? endTime,
    List<ScheduleUpdateEntity>? updates,
  }) {
    return ScheduleEntity(
      id: id ?? this.id,
      technicianName: technicianName ?? this.technicianName,
      location: location ?? this.location,
      type: type ?? this.type,
      subtype: subtype ?? this.subtype,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      updates: updates ?? this.updates,
    );
  }

  @override
  List<Object?> get props => [
        id,
        technicianName,
        location,
        type,
        subtype,
        status,
        notes,
        startTime,
        endTime,
        updates,
      ];
}
