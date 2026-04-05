import 'package:equatable/equatable.dart';
import 'maintenance_status.dart';

class MaintenanceTimelineEntity extends Equatable {
  final int id;
  final String userName;
  final MaintenanceStatus? status;
  final String description;
  final List<String> images;
  final DateTime createdAt;

  const MaintenanceTimelineEntity({
    required this.id,
    required this.userName,
    this.status,
    required this.description,
    required this.images,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, userName, status, description, images, createdAt];
}

class MaintenanceRoomEntity extends Equatable {
  final int id;
  final String number;

  const MaintenanceRoomEntity({
    required this.id,
    required this.number,
  });

  @override
  List<Object?> get props => [id, number];
}

class MaintenanceRequestEntity extends Equatable {
  final int id;
  final String residentName;
  final MaintenanceRoomEntity? room;
  final String title;
  final String description;
  final MaintenanceStatus status;
  final DateTime? reportedAt;
  final List<String> images;
  final List<MaintenanceTimelineEntity> timeline;
  final DateTime createdAt;

  const MaintenanceRequestEntity({
    required this.id,
    required this.residentName,
    this.room,
    required this.title,
    required this.description,
    required this.status,
    this.reportedAt,
    required this.images,
    required this.timeline,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        residentName,
        room,
        title,
        description,
        status,
        reportedAt,
        images,
        timeline,
        createdAt,
      ];
}
