import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:frontend/core/constant/route_constant.dart';
import 'package:frontend/core/dependency_injection/dependency_injection.dart';
import 'package:frontend/core/navigation/auth_guard.dart';
import 'package:frontend/core/navigation/auto_route.gr.dart';
import 'package:frontend/data/repository/auth_repository.dart';
import 'package:frontend/presentation/pages/permission/permission_page.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(
      page: AppLayoutRoute.page,
      path: RouteConstant.rootPath,
      children: [
        // dashboard
        AutoRoute(
          path: RouteConstant.dashboardName,
          page: DashboardRoute.page,
          guards: [AuthGuard(serviceLocator.get<AuthRepository>())],
        ),
        AutoRoute(
          path: RouteConstant.permissionName,
          page: PermissionRoute.page,
          guards: [AuthGuard(serviceLocator.get<AuthRepository>())],
        ),
        AutoRoute(
          path: '${RouteConstant.permissionName}/:id',
          page: PermissionDetailRoute.page,
          guards: [AuthGuard(serviceLocator.get<AuthRepository>())],
        ),
        AutoRoute(
          path: RouteConstant.roleName,
          page: RolePlaceholderRoute.page,
          guards: [AuthGuard(serviceLocator.get<AuthRepository>())],
        ),

        // manajemen penghuni
        AutoRoute(
          path: RouteConstant.residentName,
          page: ResidentPlaceholderRoute.page,
          guards: [AuthGuard(serviceLocator.get<AuthRepository>())],
        ),

        // manajemen kamar & reservasi
        AutoRoute(
          initial: true,
          path: RouteConstant.roomName,
          page: RoomRoute.page,
        ),
        AutoRoute(
          path: RouteConstant.detailRoomName,
          page: RoomDetailRoute.page,
        ),
        AutoRoute(
          guards: [AuthGuard(serviceLocator.get<AuthRepository>())],
          path: RouteConstant.addRoomName,
          page: AddRoomRoute.page,
        ),
        AutoRoute(
          guards: [AuthGuard(serviceLocator.get<AuthRepository>())],
          path: RouteConstant.editRoomName,
          page: EditRoomRoute.page,
        ),
        AutoRoute(
          guards: [AuthGuard(serviceLocator.get<AuthRepository>())],
          path: RouteConstant.roomAndReservationName,
          page: RoomAndReservationPlaceholderRoute.page,
        ),

        // manajemen keuangan
        AutoRoute(
          guards: [AuthGuard(serviceLocator.get<AuthRepository>())],
          path: RouteConstant.financeName,
          page: FinancePlaceholderRoute.page,
        ),

        // manajemen inventaris & pemeliharaan
        AutoRoute(
          guards: [AuthGuard(serviceLocator.get<AuthRepository>())],
          path: RouteConstant.inventoryAndMaintenanceName,
          page: InventoryAndMaintenancePlaceholderRoute.page,
        ),

        // pengaturan
        AutoRoute(
          guards: [AuthGuard(serviceLocator.get<AuthRepository>())],
          path: RouteConstant.settingName,
          page: SettingPlaceholderRoute.page,
        ),
      ],
    ),
    // AutoRoute(page: LandingRoute.page, initial: true),
    AutoRoute(path: RouteConstant.loginName, page: LoginRoute.page),
    AutoRoute(path: RouteConstant.registerName, page: RegisterRoute.page),
  ];
}
