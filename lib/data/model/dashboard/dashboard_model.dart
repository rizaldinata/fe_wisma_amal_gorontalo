import 'package:frontend/domain/entities/dashboard_entity.dart';

class DashboardModel extends DashboardEntity {
  const DashboardModel({
    required super.totalRooms,
    required super.occupiedRooms,
    required super.emptyRooms,
    required super.totalResidents,
    required super.monthlyIncome,
    required super.recentActivities,
    super.recentDamageReports,
    super.maintenanceSchedules,
    super.inventorySummary,
    super.isMaintenanceActive,
    super.isInventoryActive,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      totalRooms: json['total_rooms'] ?? 0,
      occupiedRooms: json['occupied_rooms'] ?? 0,
      emptyRooms: json['empty_rooms'] ?? 0,
      totalResidents: json['total_residents'] ?? 0,
      monthlyIncome: double.tryParse(json['monthly_income']?.toString() ?? '0') ?? 0.0,
      recentActivities: (json['recent_activities'] as List<dynamic>?)
              ?.map((e) => DashboardActivityModel.fromJson(e))
              .toList() ??
          [],
      recentDamageReports: (json['recent_damage_reports'] as List<dynamic>?)
              ?.map((e) => DashboardDamageReportModel.fromJson(e))
              .toList(),
      maintenanceSchedules: (json['maintenance_schedules'] as List<dynamic>?)
              ?.map((e) => DashboardMaintenanceScheduleModel.fromJson(e))
              .toList(),
      inventorySummary: json['inventory_summary'] != null
              ? DashboardInventorySummaryModel.fromJson(json['inventory_summary'])
              : null,
      isMaintenanceActive: json['is_maintenance_active'],
      isInventoryActive: json['is_inventory_active'],
    );
  }
}

class DashboardActivityModel extends DashboardActivityEntity {
  const DashboardActivityModel({
    required super.id,
    required super.type,
    required super.amount,
    required super.status,
    super.tenantName,
    super.roomNumber,
    required super.createdAt,
  });

  factory DashboardActivityModel.fromJson(Map<String, dynamic> json) {
    return DashboardActivityModel(
      id: json['id'] ?? 0,
      type: json['type'] ?? '',
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      status: json['status'] ?? '',
      tenantName: json['tenant_name'],
      roomNumber: json['room_number'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
    );
  }
}

class DashboardDamageReportModel extends DashboardDamageReportEntity {
  const DashboardDamageReportModel({
    required super.id,
    required super.title,
    required super.reporterName,
    required super.status,
    super.roomNumber,
    required super.reportedAt,
  });

  factory DashboardDamageReportModel.fromJson(Map<String, dynamic> json) {
    return DashboardDamageReportModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      reporterName: json['reporter_name'] ?? '',
      status: json['status'] ?? '',
      roomNumber: json['room_number'],
      reportedAt: json['reported_at'] != null ? DateTime.parse(json['reported_at']) : DateTime.now(),
    );
  }
}

class DashboardMaintenanceScheduleModel extends DashboardMaintenanceScheduleEntity {
  const DashboardMaintenanceScheduleModel({
    required super.id,
    required super.technicianName,
    required super.location,
    required super.type,
    required super.subtype,
    required super.status,
    required super.startTime,
    required super.endTime,
  });

  factory DashboardMaintenanceScheduleModel.fromJson(Map<String, dynamic> json) {
    return DashboardMaintenanceScheduleModel(
      id: json['id'] ?? 0,
      technicianName: json['technician_name'] ?? '',
      location: json['location'] ?? '',
      type: json['type'] ?? '',
      subtype: json['subtype'] ?? '',
      status: json['status'] ?? '',
      startTime: json['start_time'] != null ? DateTime.parse(json['start_time']) : DateTime.now(),
      endTime: json['end_time'] != null ? DateTime.parse(json['end_time']) : DateTime.now(),
    );
  }
}

class DashboardInventorySummaryModel extends DashboardInventorySummaryEntity {
  const DashboardInventorySummaryModel({
    required super.totalItems,
    required super.brokenItems,
  });

  factory DashboardInventorySummaryModel.fromJson(Map<String, dynamic> json) {
    return DashboardInventorySummaryModel(
      totalItems: json['total_items'] ?? 0,
      brokenItems: json['broken_items'] ?? 0,
    );
  }
}

class ResidentDashboardModel extends ResidentDashboardEntity {
  const ResidentDashboardModel({
    super.activeRoom,
    required super.recentBills,
    super.recentDamageReports,
    super.recentGuests,
    super.maintenanceSchedules,
    super.isMaintenanceActive,
    super.isGuestActive,
  });

  factory ResidentDashboardModel.fromJson(Map<String, dynamic> json) {
    return ResidentDashboardModel(
      activeRoom: json['active_room'] != null
          ? ResidentActiveRoomModel.fromJson(json['active_room'])
          : null,
      recentBills: (json['recent_bills'] as List<dynamic>?)
              ?.map((e) => ResidentBillModel.fromJson(e))
              .toList() ??
          [],
      recentDamageReports: (json['recent_damage_reports'] as List<dynamic>?)
              ?.map((e) => ResidentDamageReportModel.fromJson(e))
              .toList(),
      recentGuests: (json['recent_guests'] as List<dynamic>?)
              ?.map((e) => ResidentGuestModel.fromJson(e))
              .toList(),
      maintenanceSchedules: (json['maintenance_schedules'] as List<dynamic>?)
              ?.map((e) => DashboardMaintenanceScheduleModel.fromJson(e))
              .toList(),
      isMaintenanceActive: json['is_maintenance_active'],
      isGuestActive: json['is_guest_active'],
    );
  }
}

class ResidentActiveRoomModel extends ResidentActiveRoomEntity {
  const ResidentActiveRoomModel({
    required super.roomNumber,
    required super.status,
  });

  factory ResidentActiveRoomModel.fromJson(Map<String, dynamic> json) {
    return ResidentActiveRoomModel(
      roomNumber: json['room_number'] ?? '',
      status: json['status'] ?? '',
    );
  }
}

class ResidentBillModel extends ResidentBillEntity {
  const ResidentBillModel({
    required super.id,
    required super.title,
    required super.amount,
    required super.status,
    required super.createdAt,
  });

  factory ResidentBillModel.fromJson(Map<String, dynamic> json) {
    return ResidentBillModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      status: json['status'] ?? '',
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
    );
  }
}

class ResidentDamageReportModel extends ResidentDamageReportEntity {
  const ResidentDamageReportModel({
    required super.id,
    required super.title,
    required super.status,
    required super.reportedAt,
  });

  factory ResidentDamageReportModel.fromJson(Map<String, dynamic> json) {
    return ResidentDamageReportModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      status: json['status'] ?? '',
      reportedAt: json['reported_at'] != null ? DateTime.parse(json['reported_at']) : DateTime.now(),
    );
  }
}

class ResidentGuestModel extends ResidentGuestEntity {
  const ResidentGuestModel({
    required super.id,
    required super.name,
    required super.relationship,
    required super.checkInAt,
    super.checkOutAt,
  });

  factory ResidentGuestModel.fromJson(Map<String, dynamic> json) {
    return ResidentGuestModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      relationship: json['relationship'] ?? '',
      checkInAt: json['check_in_at'] != null ? DateTime.parse(json['check_in_at']) : DateTime.now(),
      checkOutAt: json['check_out_at'] != null ? DateTime.parse(json['check_out_at']) : null,
    );
  }
}
