import 'package:flutter/material.dart';
import 'package:frontend/core/constant/route_constant.dart';
import 'package:frontend/core/constant/style_constant.dart';
import 'package:frontend/presentation/get/auth/auth_controller.dart';
import 'package:frontend/presentation/pages/auth/login_page.dart';
import 'package:frontend/presentation/pages/auth/register_page.dart';
import 'package:frontend/presentation/pages/dashboard/dashboard.dart';
import 'package:frontend/presentation/widget/sidebar.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  final GoRouter router = GoRouter(
    initialLocation: RouteConstant.rootPath,
    redirect: (context, state) {
      var controller = Get.find<AuthController>();
      bool isLoggedIn = controller.isLoggedIn.value;

      if (!isLoggedIn &&
          state.path != RouteConstant.loginPath &&
          state.path != RouteConstant.registerPath) {
        return '${RouteConstant.loginPath}?reason=unauthenticated';
      }
      return null;
    },
    routes: <RouteBase>[
      // ShellRoute untuk membuat layout dasar dengan sidebar kiri
      ShellRoute(
        builder: (context, state, child) {
          return Scaffold(
            backgroundColor: StyleConstant.backgroundColor,
            body: Row(
              children: [
                CustomSidebar(
                  currentRoute: state.fullPath!,
                  items: [
                    SidebarItem(
                      label: RouteConstant.dashboardName,
                      icon: Icons.dashboard,
                      route: RouteConstant.dashboardPath,
                    ),
                    SidebarItem(
                      label: 'Test 2',
                      icon: Icons.abc,
                      route: '/test2',
                    ),
                    SidebarItem(
                      label: 'Test 3',
                      icon: Icons.access_alarm,
                      route: '/test3',
                    ),
                  ],
                ),
                Expanded(child: child),
              ],
            ),
          );
        },
        routes: [
          GoRoute(
            path: RouteConstant.rootPath,
            redirect: (context, state) {
              return RouteConstant.dashboardPath;
            },
          ),
          GoRoute(
            path: RouteConstant.dashboardPath,
            name: RouteConstant.dashboardName,
            builder: (context, state) => DashboardPage(),
          ),

          //route testing
          GoRoute(
            path: '/test2',
            name: 'test2',
            builder: (context, state) => Center(child: Text('Test 2 Page')),
          ),
          GoRoute(
            path: '/test3',
            name: 'test3',
            builder: (context, state) => Center(child: Text('Test 3 Page')),
          ),
        ],
      ),

      // regular routes
      GoRoute(
        path: RouteConstant.loginPath,
        name: RouteConstant.loginName,
        builder: (context, state) => LoginPage(),
      ),
      GoRoute(
        path: RouteConstant.registerPath,
        name: RouteConstant.registerName,
        builder: (context, state) => RegisterPage(),
      ),
    ],
  );
}

int _getSelectedIndex(String location) {
  if (location.startsWith(RouteConstant.dashboardPath)) return 0;
  if (location.startsWith('/test2')) return 1;
  if (location.startsWith('/test3')) return 2;
  return 0;
}
