import 'package:equatable/equatable.dart';

class DashboardEntity extends Equatable {
  final int totalRooms;
  final int occupiedRooms;
  final int emptyRooms;
  final int totalResidents;
  final double monthlyIncome;
  final List<DashboardActivityEntity> recentActivities;
  final List<DashboardDamageReportEntity>? recentDamageReports;
  final List<DashboardMaintenanceScheduleEntity>? maintenanceSchedules;
  final DashboardInventorySummaryEntity? inventorySummary;
  final bool? isMaintenanceActive;
  final bool? isInventoryActive;

  const DashboardEntity({
    required this.totalRooms,
    required this.occupiedRooms,
    required this.emptyRooms,
    required this.totalResidents,
    required this.monthlyIncome,
    required this.recentActivities,
    this.recentDamageReports,
    this.maintenanceSchedules,
    this.inventorySummary,
    this.isMaintenanceActive,
    this.isInventoryActive,
  });

  @override
  List<Object?> get props => [
        totalRooms,
        occupiedRooms,
        emptyRooms,
        totalResidents,
        monthlyIncome,
        recentActivities,
        recentDamageReports,
        maintenanceSchedules,
        inventorySummary,
        isMaintenanceActive,
        isInventoryActive,
      ];
}

class DashboardDamageReportEntity extends Equatable {
  final int id;
  final String title;
  final String reporterName;
  final String status;
  final String? roomNumber;
  final DateTime reportedAt;

  const DashboardDamageReportEntity({
    required this.id,
    required this.title,
    required this.reporterName,
    required this.status,
    this.roomNumber,
    required this.reportedAt,
  });

  @override
  List<Object?> get props => [id, title, reporterName, status, roomNumber, reportedAt];
}

class DashboardMaintenanceScheduleEntity extends Equatable {
  final int id;
  final String technicianName;
  final String location;
  final String type;
  final String subtype;
  final String status;
  final DateTime startTime;
  final DateTime endTime;

  const DashboardMaintenanceScheduleEntity({
    required this.id,
    required this.technicianName,
    required this.location,
    required this.type,
    required this.subtype,
    required this.status,
    required this.startTime,
    required this.endTime,
  });

  @override
  List<Object?> get props => [id, technicianName, location, type, subtype, status, startTime, endTime];
}

class DashboardInventorySummaryEntity extends Equatable {
  final int totalItems;
  final int brokenItems;

  const DashboardInventorySummaryEntity({
    required this.totalItems,
    required this.brokenItems,
  });

  @override
  List<Object?> get props => [totalItems, brokenItems];
}

class DashboardActivityEntity extends Equatable {
  final int id;
  final String type;
  final double amount;
  final String status;
  final String? tenantName;
  final String? roomNumber;
  final DateTime createdAt;

  const DashboardActivityEntity({
    required this.id,
    required this.type,
    required this.amount,
    required this.status,
    this.tenantName,
    this.roomNumber,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        type,
        amount,
        status,
        tenantName,
        roomNumber,
        createdAt,
      ];
}

class ResidentDashboardEntity extends Equatable {
  final ResidentActiveRoomEntity? activeRoom;
  final List<ResidentBillEntity> recentBills;
  final List<ResidentDamageReportEntity>? recentDamageReports;
  final List<ResidentGuestEntity>? recentGuests;
  final List<DashboardMaintenanceScheduleEntity>? maintenanceSchedules;
  final bool? isMaintenanceActive;
  final bool? isGuestActive;

  const ResidentDashboardEntity({
    this.activeRoom,
    required this.recentBills,
    this.recentDamageReports,
    this.recentGuests,
    this.maintenanceSchedules,
    this.isMaintenanceActive,
    this.isGuestActive,
  });

  @override
  List<Object?> get props => [
        activeRoom,
        recentBills,
        recentDamageReports,
        recentGuests,
        maintenanceSchedules,
        isMaintenanceActive,
        isGuestActive,
      ];
}

class ResidentDamageReportEntity extends Equatable {
  final int id;
  final String title;
  final String status;
  final DateTime reportedAt;

  const ResidentDamageReportEntity({
    required this.id,
    required this.title,
    required this.status,
    required this.reportedAt,
  });

  @override
  List<Object?> get props => [id, title, status, reportedAt];
}

class ResidentGuestEntity extends Equatable {
  final int id;
  final String name;
  final String relationship;
  final DateTime checkInAt;
  final DateTime? checkOutAt;

  const ResidentGuestEntity({
    required this.id,
    required this.name,
    required this.relationship,
    required this.checkInAt,
    this.checkOutAt,
  });

  @override
  List<Object?> get props => [id, name, relationship, checkInAt, checkOutAt];
}

class ResidentActiveRoomEntity extends Equatable {
  final String roomNumber;
  final String status;

  const ResidentActiveRoomEntity({
    required this.roomNumber,
    required this.status,
  });

  @override
  List<Object?> get props => [roomNumber, status];
}

class ResidentBillEntity extends Equatable {
  final int id;
  final String title;
  final double amount;
  final String status;
  final DateTime createdAt;

  const ResidentBillEntity({
    required this.id,
    required this.title,
    required this.amount,
    required this.status,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, title, amount, status, createdAt];
}
