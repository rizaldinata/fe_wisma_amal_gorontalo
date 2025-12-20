import 'package:auto_route/auto_route.dart';
import 'package:frontend/core/navigation/auto_route.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: AppLayoutRoute.page, initial: true),
    AutoRoute(page: LoginRoute.page),
    AutoRoute(page: RegisterRoute.page),
  ];
  // final authGuard = AuthGuard();

  // @override
  // List<AutoRoute> get routes => [
  //   AutoRoute(
  //     page: DashboardLayoutRoute.page,
  //     path: '/dashboard',
  //     guards: [authGuard],
  //     children: [
  //       AutoRoute(
  //         page: HomeRoute.page,
  //         path: 'home',
  //         initial: true,
  //       ),
  //       AutoRoute(
  //         page: UsersRoute.page,
  //         path: 'users',
  //       ),
  //       AutoRoute(
  //         page: SettingsRoute.page,
  //         path: 'settings',
  //       ),
  //     ],
  //   ),
  //   RedirectRoute(path: '/', redirectTo: '/dashboard'),
  // ];
}
