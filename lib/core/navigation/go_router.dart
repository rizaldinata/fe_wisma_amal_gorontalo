import 'package:flutter/material.dart';
import 'package:frontend/core/constant/route_constant.dart';
import 'package:frontend/presentation/pages/login/login_page.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  final GoRouter router = GoRouter(
    initialLocation: RouteConstant.login,
    routes: <RouteBase>[
      GoRoute(path: RouteConstant.login, builder: (context, state) => LoginPage()),
    ],
  );
}
