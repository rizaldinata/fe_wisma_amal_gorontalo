// import 'package:flutter/material.dart';
// import 'package:frontend/core/constant/route_constant.dart';
// import 'package:frontend/core/constant/style_constant.dart';
// import 'package:frontend/presentation/bloc/auth/auth_bloc.dart';
// import 'package:frontend/presentation/pages/auth/login_page.dart';
// import 'package:frontend/presentation/pages/auth/register_page.dart';
// import 'package:frontend/presentation/pages/dashboard/dashboard.dart';
// import 'package:frontend/presentation/widget/core/sidebar.dart';
// import 'package:go_router/go_router.dart';

// class AppRouter {
//   late final AuthBloc authBloc;

//   AppRouter({required this.authBloc});

//   late final GoRouter router = GoRouter(
//     initialLocation: RouteConstant.rootPath,
//     refreshListenable: authBloc.loginStatusNotifier,
//     redirect: (context, state) {
//       bool isLoggedIn = authBloc.state.isLoggedIn;

//       print(
//         'Router redirect - isLoggedIn: $isLoggedIn, path: ${state.path}, fullPath: ${state.fullPath}',
//       );
//       if (!isLoggedIn &&
//           (state.fullPath != RouteConstant.loginPath ||
//               state.fullPath != RouteConstant.registerPath)) {
//         print('Redirecting to login because not logged in');
//         if (state.fullPath == RouteConstant.loginPath ||
//             state.fullPath == RouteConstant.registerPath) {
//           return state.path;
//         }
//         return RouteConstant.loginPath;
//       }

//       if (isLoggedIn &&
//           (state.fullPath == RouteConstant.loginPath ||
//               state.fullPath == RouteConstant.registerPath ||
//               state.fullPath == RouteConstant.rootPath)) {
//         print('Redirecting to dashboard because logged in');
//         return RouteConstant.dashboardPath;
//       }

//       print('No redirect needed');
//       return null;
//     },
//     routes: <RouteBase>[
//       // ShellRoute untuk membuat layout dasar dengan sidebar kiri
//       ShellRoute(
//         builder: (context, state, child) {
//           return Scaffold(
//             backgroundColor: StyleConstant.backgroundColor,
//             body: Row(
//               children: [
//                 CustomSidebar(
//                   currentRoute: state.fullPath!,
//                   items: [
//                     SidebarItem(
//                       label: RouteConstant.dashboardName,
//                       icon: Icons.dashboard,
//                       route: RouteConstant.dashboardPath,
//                     ),
//                     SidebarItem(
//                       label: 'Test 2',
//                       icon: Icons.abc,
//                       route: '/test2',
//                     ),
//                     SidebarItem(
//                       label: 'Test 3',
//                       icon: Icons.access_alarm,
//                       route: '/test3',
//                     ),
//                   ],
//                 ),
//                 Expanded(child: child),
//               ],
//             ),
//           );
//         },
//         routes: [
//           GoRoute(
//             path: RouteConstant.rootPath,
//             redirect: (context, state) {
//               return RouteConstant.dashboardPath;
//             },
//           ),
//           GoRoute(
//             path: RouteConstant.dashboardPath,
//             name: RouteConstant.dashboardName,
//             builder: (context, state) => DashboardPage(),
//           ),

//           //route testing
//           GoRoute(
//             path: '/test2',
//             name: 'test2',
//             builder: (context, state) => Center(child: Text('Test 2 Page')),
//           ),
//           GoRoute(
//             path: '/test3',
//             name: 'test3',
//             builder: (context, state) => Center(child: Text('Test 3 Page')),
//           ),
//         ],
//       ),

//       // regular routes
//       GoRoute(
//         path: RouteConstant.loginPath,
//         name: RouteConstant.loginName,
//         builder: (context, state) => LoginPage(),
//       ),
//       GoRoute(
//         path: RouteConstant.registerPath,
//         name: RouteConstant.registerName,
//         builder: (context, state) => RegisterPage(),
//       ),
//     ],
//   );
// }
