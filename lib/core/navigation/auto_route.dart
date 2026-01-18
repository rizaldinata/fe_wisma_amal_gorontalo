import 'package:auto_route/auto_route.dart';
import 'package:frontend/core/constant/route_constant.dart';
import 'package:frontend/core/dependency_injection/dependency_injection.dart';
import 'package:frontend/core/navigation/auth_guard.dart';
import 'package:frontend/core/navigation/auto_route.gr.dart';
import 'package:frontend/data/repository/auth_repository.dart';

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
        AutoRoute(path: RouteConstant.formRoomName, page: FormRoomRoute.page),
      ],
    ),
    AutoRoute(page: LandingRoute.page, initial: true),
    AutoRoute(page: LoginRoute.page),
    AutoRoute(page: RegisterRoute.page),
  ];
}
