// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i5;
import 'package:flutter/material.dart' as _i6;
import 'package:frontend/presentation/pages/auth/login_page.dart' as _i3;
import 'package:frontend/presentation/pages/auth/register_page.dart' as _i4;
import 'package:frontend/presentation/pages/landing/landing_page.dart' as _i2;
import 'package:frontend/presentation/widget/app_layout.dart' as _i1;

/// generated route for
/// [_i1.AppLayoutPage]
class AppLayoutRoute extends _i5.PageRouteInfo<void> {
  const AppLayoutRoute({List<_i5.PageRouteInfo>? children})
    : super(AppLayoutRoute.name, initialChildren: children);

  static const String name = 'AppLayoutRoute';

  static _i5.PageInfo page = _i5.PageInfo(
    name,
    builder: (data) {
      return const _i1.AppLayoutPage();
    },
  );
}

/// generated route for
/// [_i2.LandingPage]
class LandingRoute extends _i5.PageRouteInfo<void> {
  const LandingRoute({List<_i5.PageRouteInfo>? children})
    : super(LandingRoute.name, initialChildren: children);

  static const String name = 'LandingRoute';

  static _i5.PageInfo page = _i5.PageInfo(
    name,
    builder: (data) {
      return const _i2.LandingPage();
    },
  );
}

/// generated route for
/// [_i3.LoginPage]
class LoginRoute extends _i5.PageRouteInfo<LoginRouteArgs> {
  LoginRoute({_i6.Key? key, String? reason, List<_i5.PageRouteInfo>? children})
    : super(
        LoginRoute.name,
        args: LoginRouteArgs(key: key, reason: reason),
        rawQueryParams: {'reason': reason},
        initialChildren: children,
      );

  static const String name = 'LoginRoute';

  static _i5.PageInfo page = _i5.PageInfo(
    name,
    builder: (data) {
      final queryParams = data.queryParams;
      final args = data.argsAs<LoginRouteArgs>(
        orElse: () => LoginRouteArgs(reason: queryParams.optString('reason')),
      );
      return _i3.LoginPage(key: args.key, reason: args.reason);
    },
  );
}

class LoginRouteArgs {
  const LoginRouteArgs({this.key, this.reason});

  final _i6.Key? key;

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
/// [_i4.RegisterPage]
class RegisterRoute extends _i5.PageRouteInfo<RegisterRouteArgs> {
  RegisterRoute({_i6.Key? key, List<_i5.PageRouteInfo>? children})
    : super(
        RegisterRoute.name,
        args: RegisterRouteArgs(key: key),
        initialChildren: children,
      );

  static const String name = 'RegisterRoute';

  static _i5.PageInfo page = _i5.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<RegisterRouteArgs>(
        orElse: () => const RegisterRouteArgs(),
      );
      return _i4.RegisterPage(key: args.key);
    },
  );
}

class RegisterRouteArgs {
  const RegisterRouteArgs({this.key});

  final _i6.Key? key;

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
