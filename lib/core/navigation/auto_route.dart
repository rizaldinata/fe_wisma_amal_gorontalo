import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:frontend/core/constant/route_constant.dart';
import 'package:frontend/core/navigation/auto_route.gr.dart';
import 'package:frontend/presentation/pages/permission/permission_page.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(
      page: AppLayoutRoute.page,
      path: RouteConstant.rootPath,
      // guards: [AuthGuard(serviceLocator.get<AuthRepository>())],
      children: [
        // dashboard
        AutoRoute(
          path: RouteConstant.dashboardName,
          page: DashboardRoute.page,
          initial: true,
        ),
        AutoRoute(
          path: RouteConstant.permissionName,
          page: PermissionRoute.page,
        ),
        AutoRoute(
          path: RouteConstant.roleName,
          page: RolePlaceholderRoute.page,
        ),

        // manajemen penghuni
        AutoRoute(
          path: RouteConstant.residentName,
          page: ResidentPlaceholderRoute.page,
        ),

        // manajemen kamar & reservasi
        AutoRoute(path: RouteConstant.roomName, page: RoomRoute.page),
        AutoRoute(
          path: RouteConstant.detailRoomName,
          page: RoomDetailRoute.page,
        ),
        AutoRoute(path: RouteConstant.addRoomName, page: AddRoomRoute.page),
        AutoRoute(path: RouteConstant.editRoomName, page: EditRoomRoute.page),
        AutoRoute(
          path: RouteConstant.roomAndReservationName,
          page: RoomAndReservationPlaceholderRoute.page,
        ),

        // manajemen keuangan
        AutoRoute(
          path: RouteConstant.financeName,
          page: FinancePlaceholderRoute.page,
        ),

        // manajemen inventaris & pemeliharaan
        AutoRoute(
          path: RouteConstant.inventoryAndMaintenanceName,
          page: InventoryAndMaintenancePlaceholderRoute.page,
        ),

        // pengaturan
        AutoRoute(
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
