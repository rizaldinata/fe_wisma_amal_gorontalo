import 'package:flutter/material.dart';
import 'package:frontend/core/constant/route_constant.dart';
import 'package:frontend/presentation/pages/auth/login_page.dart';
import 'package:frontend/presentation/pages/auth/register_page.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  final GoRouter router = GoRouter(
    initialLocation: RouteConstant.login,
    routes: <RouteBase>[
      GoRoute(
        path: RouteConstant.login,
        builder: (context, state) => LoginPage(),
      ),
      GoRoute(
        path: RouteConstant.register,
        builder: (context, state) => RegisterPage(),
      ),
    ],
  );
}
