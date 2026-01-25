import 'package:auto_route/auto_route.dart';
import 'package:frontend/core/constant/route_constant.dart';
import 'package:frontend/core/navigation/auto_route.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(
      page: AppLayoutRoute.page,
      path: RouteConstant.rootPath,
      // guards: [AuthGuard(serviceLocator.get<AuthRepository>())],
      children: [
        AutoRoute(
          path: RouteConstant.dashboardName,
          page: DashboardRoute.page,
          initial: true,
        ),
        AutoRoute(path: RouteConstant.roomName, page: RoomRoute.page),
        AutoRoute(
          path: RouteConstant.detailRoomName,
          page: RoomDetailRoute.page,
        ),
        AutoRoute(path: RouteConstant.addRoomName, page: AddRoomRoute.page),
        AutoRoute(path: RouteConstant.editRoomName, page: UpdateRoomRoute.page),
      ],
    ),
    // AutoRoute(page: LandingRoute.page, initial: true),
    AutoRoute(path: RouteConstant.loginName, page: LoginRoute.page),
    AutoRoute(path: RouteConstant.registerName, page: RegisterRoute.page),
  ];
}
