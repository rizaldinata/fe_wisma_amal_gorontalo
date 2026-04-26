import 'package:frontend/domain/entity/room/room_schedule_entity.dart';

class RoomScheduleModel extends RoomScheduleEntity {
  const RoomScheduleModel({
    required super.id,
    required super.title,
    required super.number,
    required super.status,
    required super.schedules,
  });

  factory RoomScheduleModel.fromJson(Map<String, dynamic> json) {
    return RoomScheduleModel(
      id: json['id'],
      title: json['title'],
      number: json['number'],
      status: json['status'],
      schedules: (json['schedules'] as List)
          .map((e) => LeaseScheduleModel.fromJson(e))
          .toList(),
    );
  }
}

class LeaseScheduleModel extends LeaseScheduleEntity {
  const LeaseScheduleModel({
    required super.id,
    required super.startDate,
    required super.endDate,
    required super.status,
    super.tenantName,
  });

  factory LeaseScheduleModel.fromJson(Map<String, dynamic> json) {
    // Nama tenant diambil dari resident -> user -> name jika ada
    String? name;
    if (json['resident'] != null && json['resident']['user'] != null) {
      name = json['resident']['user']['name'];
    }

    return LeaseScheduleModel(
      id: json['id'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      status: json['status'],
      tenantName: name,
    );
  }
}
