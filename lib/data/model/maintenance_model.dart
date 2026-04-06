import '../../domain/entity/maintenance_request_entity.dart';
import '../../domain/entity/maintenance_status.dart';

class MaintenanceTimelineModel {
  final int id;
  final String userName;
  final MaintenanceStatus? status;
  final String description;
  final List<String> images;
  final DateTime createdAt;

  MaintenanceTimelineModel({
    required this.id,
    required this.userName,
    this.status,
    required this.description,
    required this.images,
    required this.createdAt,
  });

  factory MaintenanceTimelineModel.fromJson(Map<String, dynamic> json) {
    return MaintenanceTimelineModel(
      id: json['id'],
      userName: json['user']?['name'] ?? 'System',
      status: json['status'] != null ? MaintenanceStatus.fromValue(json['status']) : null,
      description: json['description'],
      images: List<String>.from(json['images'] ?? []),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  MaintenanceTimelineEntity toEntity() {
    return MaintenanceTimelineEntity(
      id: id,
      userName: userName,
      status: status,
      description: description,
      images: images,
      createdAt: createdAt,
    );
  }
}

class MaintenanceRoomModel {
  final int id;
  final String number;

  MaintenanceRoomModel({
    required this.id,
    required this.number,
  });

  factory MaintenanceRoomModel.fromJson(Map<String, dynamic> json) {
    return MaintenanceRoomModel(
      id: json['id'],
      number: json['number'],
    );
  }

  MaintenanceRoomEntity toEntity() {
    return MaintenanceRoomEntity(
      id: id,
      number: number,
    );
  }
}

class MaintenanceRequestModel {
  final int id;
  final String residentName;
  final MaintenanceRoomModel? room;
  final String title;
  final String description;
  final MaintenanceStatus status;
  final DateTime? reportedAt;
  final List<String> images;
  final List<MaintenanceTimelineModel> timeline;
  final DateTime createdAt;

  MaintenanceRequestModel({
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

  factory MaintenanceRequestModel.fromJson(Map<String, dynamic> json) {
    return MaintenanceRequestModel(
      id: json['id'],
      residentName: json['resident']?['name'] ?? json['resident_name'] ?? 'Unknown',
      room: json['room'] != null ? MaintenanceRoomModel.fromJson(json['room']) : null,
      title: json['title'],
      description: json['description'],
      status: MaintenanceStatus.fromValue(json['status']),
      reportedAt: json['reported_at'] != null ? DateTime.parse(json['reported_at']) : null,
      images: List<String>.from(json['images'] ?? []),
      timeline: json['timeline'] != null 
          ? (json['timeline'] as List).map((i) => MaintenanceTimelineModel.fromJson(i)).toList()
          : [],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  MaintenanceRequestEntity toEntity() {
    return MaintenanceRequestEntity(
      id: id,
      residentName: residentName,
      room: room?.toEntity(),
      title: title,
      description: description,
      status: status,
      reportedAt: reportedAt,
      images: images,
      timeline: timeline.map((e) => e.toEntity()).toList(),
      createdAt: createdAt,
    );
  }
}
