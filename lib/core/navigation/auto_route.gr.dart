// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i24;
import 'package:flutter/material.dart' as _i25;
import 'package:frontend/domain/entity/inventory_entity.dart' as _i26;
import 'package:frontend/domain/entity/schedule_entity.dart' as _i27;
import 'package:frontend/presentation/pages/auth/login_page.dart' as _i9;
import 'package:frontend/presentation/pages/auth/register_page.dart' as _i18;
import 'package:frontend/presentation/pages/dashboard/dashboard.dart' as _i3;
import 'package:frontend/presentation/pages/detail_room/room_detail.dart'
    as _i21;
import 'package:frontend/presentation/pages/finance/finance_dashboard_page.dart'
    as _i4;
import 'package:frontend/presentation/pages/inventory/inventory_form_page.dart'
    as _i6;
import 'package:frontend/presentation/pages/inventory/inventory_page.dart'
    as _i7;
import 'package:frontend/presentation/pages/landing/landing_page.dart' as _i8;
import 'package:frontend/presentation/pages/maintanance/maintanance_detail_page.dart'
    as _i10;
import 'package:frontend/presentation/pages/maintanance/maintanance_form_page.dart'
    as _i11;
import 'package:frontend/presentation/pages/maintanance/maintanance_page.dart'
    as _i12;
import 'package:frontend/presentation/pages/maintenance_report/maintenance_create_report_page.dart'
    as _i13;
import 'package:frontend/presentation/pages/maintenance_report/maintenance_report_detail_page.dart'
    as _i14;
import 'package:frontend/presentation/pages/maintenance_report/maintenance_report_list_page.dart'
    as _i15;
import 'package:frontend/presentation/pages/permission/permission_detail_page.dart'
    as _i16;
import 'package:frontend/presentation/pages/permission/permission_page.dart'
    as _i17;
import 'package:frontend/presentation/pages/placeholder/placeholder_page.dart'
    as _i5;
import 'package:frontend/presentation/pages/reservation_list/reservation_page.dart'
    as _i19;
import 'package:frontend/presentation/pages/room_form/form_room.dart' as _i1;
import 'package:frontend/presentation/pages/room_list/room_page.dart' as _i22;
import 'package:frontend/presentation/pages/room_schedule/room_schedule_page.dart'
    as _i23;
import 'package:frontend/presentation/resident/resident_page.dart' as _i20;
import 'package:frontend/presentation/widget/app_layout.dart' as _i2;

/// generated route for
/// [_i1.AddRoomPage]
class AddRoomRoute extends _i24.PageRouteInfo<void> {
  const AddRoomRoute({List<_i24.PageRouteInfo>? children})
    : super(AddRoomRoute.name, initialChildren: children);

  static const String name = 'AddRoomRoute';

  static _i24.PageInfo page = _i24.PageInfo(
    name,
    builder: (data) {
      return const _i1.AddRoomPage();
    },
  );
}

/// generated route for
/// [_i2.AppLayoutPage]
class AppLayoutRoute extends _i24.PageRouteInfo<void> {
  const AppLayoutRoute({List<_i24.PageRouteInfo>? children})
    : super(AppLayoutRoute.name, initialChildren: children);

  static const String name = 'AppLayoutRoute';

  static _i24.PageInfo page = _i24.PageInfo(
    name,
    builder: (data) {
      return const _i2.AppLayoutPage();
    },
  );
}

/// generated route for
/// [_i3.DashboardPage]
class DashboardRoute extends _i24.PageRouteInfo<void> {
  const DashboardRoute({List<_i24.PageRouteInfo>? children})
    : super(DashboardRoute.name, initialChildren: children);

  static const String name = 'DashboardRoute';

  static _i24.PageInfo page = _i24.PageInfo(
    name,
    builder: (data) {
      return const _i3.DashboardPage();
    },
  );
}

/// generated route for
/// [_i1.EditRoomPage]
class EditRoomRoute extends _i24.PageRouteInfo<EditRoomRouteArgs> {
  EditRoomRoute({
    _i25.Key? key,
    required int roomId,
    List<_i24.PageRouteInfo>? children,
  }) : super(
         EditRoomRoute.name,
         args: EditRoomRouteArgs(key: key, roomId: roomId),
         rawPathParams: {'id': roomId},
         initialChildren: children,
       );

  static const String name = 'EditRoomRoute';

  static _i24.PageInfo page = _i24.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<EditRoomRouteArgs>(
        orElse: () => EditRoomRouteArgs(roomId: pathParams.getInt('id')),
      );
      return _i1.EditRoomPage(key: args.key, roomId: args.roomId);
    },
  );
}

class EditRoomRouteArgs {
  const EditRoomRouteArgs({this.key, required this.roomId});

  final _i25.Key? key;

  final int roomId;

  @override
  String toString() {
    return 'EditRoomRouteArgs{key: $key, roomId: $roomId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! EditRoomRouteArgs) return false;
    return key == other.key && roomId == other.roomId;
  }

  @override
  int get hashCode => key.hashCode ^ roomId.hashCode;
}

/// generated route for
/// [_i4.FinanceDashboardPage]
class FinanceDashboardRoute extends _i24.PageRouteInfo<void> {
  const FinanceDashboardRoute({List<_i24.PageRouteInfo>? children})
    : super(FinanceDashboardRoute.name, initialChildren: children);

  static const String name = 'FinanceDashboardRoute';

  static _i24.PageInfo page = _i24.PageInfo(
    name,
    builder: (data) {
      return const _i4.FinanceDashboardPage();
    },
  );
}

/// generated route for
/// [_i5.FinancePlaceholderPage]
class FinancePlaceholderRoute extends _i24.PageRouteInfo<void> {
  const FinancePlaceholderRoute({List<_i24.PageRouteInfo>? children})
    : super(FinancePlaceholderRoute.name, initialChildren: children);

  static const String name = 'FinancePlaceholderRoute';

  static _i24.PageInfo page = _i24.PageInfo(
    name,
    builder: (data) {
      return const _i5.FinancePlaceholderPage();
    },
  );
}

/// generated route for
/// [_i5.InventoryAndMaintenancePlaceholderPage]
class InventoryAndMaintenancePlaceholderRoute extends _i24.PageRouteInfo<void> {
  const InventoryAndMaintenancePlaceholderRoute({
    List<_i24.PageRouteInfo>? children,
  }) : super(
         InventoryAndMaintenancePlaceholderRoute.name,
         initialChildren: children,
       );

  static const String name = 'InventoryAndMaintenancePlaceholderRoute';

  static _i24.PageInfo page = _i24.PageInfo(
    name,
    builder: (data) {
      return const _i5.InventoryAndMaintenancePlaceholderPage();
    },
  );
}

/// generated route for
/// [_i6.InventoryFormPage]
class InventoryFormRoute extends _i24.PageRouteInfo<InventoryFormRouteArgs> {
  InventoryFormRoute({
    _i25.Key? key,
    _i26.InventoryEntity? inventoryData,
    List<_i24.PageRouteInfo>? children,
  }) : super(
         InventoryFormRoute.name,
         args: InventoryFormRouteArgs(key: key, inventoryData: inventoryData),
         initialChildren: children,
       );

  static const String name = 'InventoryFormRoute';

  static _i24.PageInfo page = _i24.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<InventoryFormRouteArgs>(
        orElse: () => const InventoryFormRouteArgs(),
      );
      return _i6.InventoryFormPage(
        key: args.key,
        inventoryData: args.inventoryData,
      );
    },
  );
}

class InventoryFormRouteArgs {
  const InventoryFormRouteArgs({this.key, this.inventoryData});

  final _i25.Key? key;

  final _i26.InventoryEntity? inventoryData;

  @override
  String toString() {
    return 'InventoryFormRouteArgs{key: $key, inventoryData: $inventoryData}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! InventoryFormRouteArgs) return false;
    return key == other.key && inventoryData == other.inventoryData;
  }

  @override
  int get hashCode => key.hashCode ^ inventoryData.hashCode;
}

/// generated route for
/// [_i7.InventoryPage]
class InventoryRoute extends _i24.PageRouteInfo<void> {
  const InventoryRoute({List<_i24.PageRouteInfo>? children})
    : super(InventoryRoute.name, initialChildren: children);

  static const String name = 'InventoryRoute';

  static _i24.PageInfo page = _i24.PageInfo(
    name,
    builder: (data) {
      return const _i7.InventoryPage();
    },
  );
}

/// generated route for
/// [_i8.LandingPage]
class LandingRoute extends _i24.PageRouteInfo<void> {
  const LandingRoute({List<_i24.PageRouteInfo>? children})
    : super(LandingRoute.name, initialChildren: children);

  static const String name = 'LandingRoute';

  static _i24.PageInfo page = _i24.PageInfo(
    name,
    builder: (data) {
      return const _i8.LandingPage();
    },
  );
}

/// generated route for
/// [_i9.LoginPage]
class LoginRoute extends _i24.PageRouteInfo<LoginRouteArgs> {
  LoginRoute({
    _i25.Key? key,
    String? reason,
    List<_i24.PageRouteInfo>? children,
  }) : super(
         LoginRoute.name,
         args: LoginRouteArgs(key: key, reason: reason),
         rawQueryParams: {'reason': reason},
         initialChildren: children,
       );

  static const String name = 'LoginRoute';

  static _i24.PageInfo page = _i24.PageInfo(
    name,
    builder: (data) {
      final queryParams = data.queryParams;
      final args = data.argsAs<LoginRouteArgs>(
        orElse: () => LoginRouteArgs(reason: queryParams.optString('reason')),
      );
      return _i9.LoginPage(key: args.key, reason: args.reason);
    },
  );
}

class LoginRouteArgs {
  const LoginRouteArgs({this.key, this.reason});

  final _i25.Key? key;

  final String? reason;

  @override
  String toString() {
    return 'LoginRouteArgs{key: $key, reason: $reason}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! LoginRouteArgs) return false;
    return key == other.key && reason == other.reason;
  }

  @override
  int get hashCode => key.hashCode ^ reason.hashCode;
}

/// generated route for
/// [_i10.MaintananceDetailPage]
class MaintananceDetailRoute
    extends _i24.PageRouteInfo<MaintananceDetailRouteArgs> {
  MaintananceDetailRoute({
    _i25.Key? key,
    required _i27.ScheduleEntity schedule,
    List<_i24.PageRouteInfo>? children,
  }) : super(
         MaintananceDetailRoute.name,
         args: MaintananceDetailRouteArgs(key: key, schedule: schedule),
         initialChildren: children,
       );

  static const String name = 'MaintananceDetailRoute';

  static _i24.PageInfo page = _i24.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<MaintananceDetailRouteArgs>();
      return _i10.MaintananceDetailPage(key: args.key, schedule: args.schedule);
    },
  );
}

class MaintananceDetailRouteArgs {
  const MaintananceDetailRouteArgs({this.key, required this.schedule});

  final _i25.Key? key;

  final _i27.ScheduleEntity schedule;

  @override
  String toString() {
    return 'MaintananceDetailRouteArgs{key: $key, schedule: $schedule}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! MaintananceDetailRouteArgs) return false;
    return key == other.key && schedule == other.schedule;
  }

  @override
  int get hashCode => key.hashCode ^ schedule.hashCode;
}

/// generated route for
/// [_i11.MaintananceFormPage]
class MaintananceFormRoute
    extends _i24.PageRouteInfo<MaintananceFormRouteArgs> {
  MaintananceFormRoute({
    _i25.Key? key,
    _i27.ScheduleEntity? scheduleData,
    List<_i24.PageRouteInfo>? children,
  }) : super(
         MaintananceFormRoute.name,
         args: MaintananceFormRouteArgs(key: key, scheduleData: scheduleData),
         initialChildren: children,
       );

  static const String name = 'MaintananceFormRoute';

  static _i24.PageInfo page = _i24.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<MaintananceFormRouteArgs>(
        orElse: () => const MaintananceFormRouteArgs(),
      );
      return _i11.MaintananceFormPage(
        key: args.key,
        scheduleData: args.scheduleData,
      );
    },
  );
}

class MaintananceFormRouteArgs {
  const MaintananceFormRouteArgs({this.key, this.scheduleData});

  final _i25.Key? key;

  final _i27.ScheduleEntity? scheduleData;

  @override
  String toString() {
    return 'MaintananceFormRouteArgs{key: $key, scheduleData: $scheduleData}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! MaintananceFormRouteArgs) return false;
    return key == other.key && scheduleData == other.scheduleData;
  }

  @override
  int get hashCode => key.hashCode ^ scheduleData.hashCode;
}

/// generated route for
/// [_i12.MaintanancePage]
class MaintananceRoute extends _i24.PageRouteInfo<void> {
  const MaintananceRoute({List<_i24.PageRouteInfo>? children})
    : super(MaintananceRoute.name, initialChildren: children);

  static const String name = 'MaintananceRoute';

  static _i24.PageInfo page = _i24.PageInfo(
    name,
    builder: (data) {
      return const _i12.MaintanancePage();
    },
  );
}

/// generated route for
/// [_i13.MaintenanceCreateReportPage]
class MaintenanceCreateReportRoute extends _i24.PageRouteInfo<void> {
  const MaintenanceCreateReportRoute({List<_i24.PageRouteInfo>? children})
    : super(MaintenanceCreateReportRoute.name, initialChildren: children);

  static const String name = 'MaintenanceCreateReportRoute';

  static _i24.PageInfo page = _i24.PageInfo(
    name,
    builder: (data) {
      return const _i13.MaintenanceCreateReportPage();
    },
  );
}

/// generated route for
/// [_i14.MaintenanceReportDetailPage]
class MaintenanceReportDetailRoute
    extends _i24.PageRouteInfo<MaintenanceReportDetailRouteArgs> {
  MaintenanceReportDetailRoute({
    _i25.Key? key,
    required int id,
    List<_i24.PageRouteInfo>? children,
  }) : super(
         MaintenanceReportDetailRoute.name,
         args: MaintenanceReportDetailRouteArgs(key: key, id: id),
         rawPathParams: {'id': id},
         initialChildren: children,
       );

  static const String name = 'MaintenanceReportDetailRoute';

  static _i24.PageInfo page = _i24.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<MaintenanceReportDetailRouteArgs>(
        orElse: () =>
            MaintenanceReportDetailRouteArgs(id: pathParams.getInt('id')),
      );
      return _i14.MaintenanceReportDetailPage(key: args.key, id: args.id);
    },
  );
}

class MaintenanceReportDetailRouteArgs {
  const MaintenanceReportDetailRouteArgs({this.key, required this.id});

  final _i25.Key? key;

  final int id;

  @override
  String toString() {
    return 'MaintenanceReportDetailRouteArgs{key: $key, id: $id}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! MaintenanceReportDetailRouteArgs) return false;
    return key == other.key && id == other.id;
  }

  @override
  int get hashCode => key.hashCode ^ id.hashCode;
}

/// generated route for
/// [_i15.MaintenanceReportListPage]
class MaintenanceReportListRoute extends _i24.PageRouteInfo<void> {
  const MaintenanceReportListRoute({List<_i24.PageRouteInfo>? children})
    : super(MaintenanceReportListRoute.name, initialChildren: children);

  static const String name = 'MaintenanceReportListRoute';

  static _i24.PageInfo page = _i24.PageInfo(
    name,
    builder: (data) {
      return const _i15.MaintenanceReportListPage();
    },
  );
}

/// generated route for
/// [_i16.PermissionDetailPage]
class PermissionDetailRoute
    extends _i24.PageRouteInfo<PermissionDetailRouteArgs> {
  PermissionDetailRoute({
    _i25.Key? key,
    required int id,
    List<_i24.PageRouteInfo>? children,
  }) : super(
         PermissionDetailRoute.name,
         args: PermissionDetailRouteArgs(key: key, id: id),
         rawPathParams: {'id': id},
         initialChildren: children,
       );

  static const String name = 'PermissionDetailRoute';

  static _i24.PageInfo page = _i24.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<PermissionDetailRouteArgs>(
        orElse: () => PermissionDetailRouteArgs(id: pathParams.getInt('id')),
      );
      return _i16.PermissionDetailPage(key: args.key, id: args.id);
    },
  );
}

class PermissionDetailRouteArgs {
  const PermissionDetailRouteArgs({this.key, required this.id});

  final _i25.Key? key;

  final int id;

  @override
  String toString() {
    return 'PermissionDetailRouteArgs{key: $key, id: $id}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PermissionDetailRouteArgs) return false;
    return key == other.key && id == other.id;
  }

  @override
  int get hashCode => key.hashCode ^ id.hashCode;
}

/// generated route for
/// [_i17.PermissionPage]
class PermissionRoute extends _i24.PageRouteInfo<void> {
  const PermissionRoute({List<_i24.PageRouteInfo>? children})
    : super(PermissionRoute.name, initialChildren: children);

  static const String name = 'PermissionRoute';

  static _i24.PageInfo page = _i24.PageInfo(
    name,
    builder: (data) {
      return const _i17.PermissionPage();
    },
  );
}

/// generated route for
/// [_i5.PermissionPlaceholderPage]
class PermissionPlaceholderRoute extends _i24.PageRouteInfo<void> {
  const PermissionPlaceholderRoute({List<_i24.PageRouteInfo>? children})
    : super(PermissionPlaceholderRoute.name, initialChildren: children);

  static const String name = 'PermissionPlaceholderRoute';

  static _i24.PageInfo page = _i24.PageInfo(
    name,
    builder: (data) {
      return const _i5.PermissionPlaceholderPage();
    },
  );
}

/// generated route for
/// [_i18.RegisterPage]
class RegisterRoute extends _i24.PageRouteInfo<RegisterRouteArgs> {
  RegisterRoute({_i25.Key? key, List<_i24.PageRouteInfo>? children})
    : super(
        RegisterRoute.name,
        args: RegisterRouteArgs(key: key),
        initialChildren: children,
      );

  static const String name = 'RegisterRoute';

  static _i24.PageInfo page = _i24.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<RegisterRouteArgs>(
        orElse: () => const RegisterRouteArgs(),
      );
      return _i18.RegisterPage(key: args.key);
    },
  );
}

class RegisterRouteArgs {
  const RegisterRouteArgs({this.key});

  final _i25.Key? key;

  @override
  String toString() {
    return 'RegisterRouteArgs{key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! RegisterRouteArgs) return false;
    return key == other.key;
  }

  @override
  int get hashCode => key.hashCode;
}

/// generated route for
/// [_i19.ReservationPage]
class ReservationRoute extends _i24.PageRouteInfo<void> {
  const ReservationRoute({List<_i24.PageRouteInfo>? children})
    : super(ReservationRoute.name, initialChildren: children);

  static const String name = 'ReservationRoute';

  static _i24.PageInfo page = _i24.PageInfo(
    name,
    builder: (data) {
      return const _i19.ReservationPage();
    },
  );
}

/// generated route for
/// [_i20.ResidentPage]
class ResidentRoute extends _i24.PageRouteInfo<void> {
  const ResidentRoute({List<_i24.PageRouteInfo>? children})
    : super(ResidentRoute.name, initialChildren: children);

  static const String name = 'ResidentRoute';

  static _i24.PageInfo page = _i24.PageInfo(
    name,
    builder: (data) {
      return const _i20.ResidentPage();
    },
  );
}

/// generated route for
/// [_i5.ResidentPlaceholderPage]
class ResidentPlaceholderRoute extends _i24.PageRouteInfo<void> {
  const ResidentPlaceholderRoute({List<_i24.PageRouteInfo>? children})
    : super(ResidentPlaceholderRoute.name, initialChildren: children);

  static const String name = 'ResidentPlaceholderRoute';

  static _i24.PageInfo page = _i24.PageInfo(
    name,
    builder: (data) {
      return const _i5.ResidentPlaceholderPage();
    },
  );
}

/// generated route for
/// [_i5.RolePlaceholderPage]
class RolePlaceholderRoute extends _i24.PageRouteInfo<void> {
  const RolePlaceholderRoute({List<_i24.PageRouteInfo>? children})
    : super(RolePlaceholderRoute.name, initialChildren: children);

  static const String name = 'RolePlaceholderRoute';

  static _i24.PageInfo page = _i24.PageInfo(
    name,
    builder: (data) {
      return const _i5.RolePlaceholderPage();
    },
  );
}

/// generated route for
/// [_i5.RoomAndReservationPlaceholderPage]
class RoomAndReservationPlaceholderRoute extends _i24.PageRouteInfo<void> {
  const RoomAndReservationPlaceholderRoute({List<_i24.PageRouteInfo>? children})
    : super(RoomAndReservationPlaceholderRoute.name, initialChildren: children);

  static const String name = 'RoomAndReservationPlaceholderRoute';

  static _i24.PageInfo page = _i24.PageInfo(
    name,
    builder: (data) {
      return const _i5.RoomAndReservationPlaceholderPage();
    },
  );
}

/// generated route for
/// [_i21.RoomDetailPage]
class RoomDetailRoute extends _i24.PageRouteInfo<RoomDetailRouteArgs> {
  RoomDetailRoute({
    _i25.Key? key,
    required int roomId,
    List<_i24.PageRouteInfo>? children,
  }) : super(
         RoomDetailRoute.name,
         args: RoomDetailRouteArgs(key: key, roomId: roomId),
         rawPathParams: {'id': roomId},
         initialChildren: children,
       );

  static const String name = 'RoomDetailRoute';

  static _i24.PageInfo page = _i24.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<RoomDetailRouteArgs>(
        orElse: () => RoomDetailRouteArgs(roomId: pathParams.getInt('id')),
      );
      return _i21.RoomDetailPage(key: args.key, roomId: args.roomId);
    },
  );
}

class RoomDetailRouteArgs {
  const RoomDetailRouteArgs({this.key, required this.roomId});

  final _i25.Key? key;

  final int roomId;

  @override
  String toString() {
    return 'RoomDetailRouteArgs{key: $key, roomId: $roomId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! RoomDetailRouteArgs) return false;
    return key == other.key && roomId == other.roomId;
  }

  @override
  int get hashCode => key.hashCode ^ roomId.hashCode;
}

/// generated route for
/// [_i22.RoomPage]
class RoomRoute extends _i24.PageRouteInfo<void> {
  const RoomRoute({List<_i24.PageRouteInfo>? children})
    : super(RoomRoute.name, initialChildren: children);

  static const String name = 'RoomRoute';

  static _i24.PageInfo page = _i24.PageInfo(
    name,
    builder: (data) {
      return const _i22.RoomPage();
    },
  );
}

/// generated route for
/// [_i23.RoomSchedulePage]
class RoomScheduleRoute extends _i24.PageRouteInfo<void> {
  const RoomScheduleRoute({List<_i24.PageRouteInfo>? children})
    : super(RoomScheduleRoute.name, initialChildren: children);

  static const String name = 'RoomScheduleRoute';

  static _i24.PageInfo page = _i24.PageInfo(
    name,
    builder: (data) {
      return const _i23.RoomSchedulePage();
    },
  );
}

/// generated route for
/// [_i5.SettingPlaceholderPage]
class SettingPlaceholderRoute extends _i24.PageRouteInfo<void> {
  const SettingPlaceholderRoute({List<_i24.PageRouteInfo>? children})
    : super(SettingPlaceholderRoute.name, initialChildren: children);

  static const String name = 'SettingPlaceholderRoute';

  static _i24.PageInfo page = _i24.PageInfo(
    name,
    builder: (data) {
      return const _i5.SettingPlaceholderPage();
    },
  );
}
