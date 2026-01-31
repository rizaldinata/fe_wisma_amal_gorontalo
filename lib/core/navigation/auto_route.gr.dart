// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i9;
import 'package:flutter/material.dart' as _i10;
import 'package:frontend/presentation/pages/auth/login_page.dart' as _i5;
import 'package:frontend/presentation/pages/auth/register_page.dart' as _i6;
import 'package:frontend/presentation/pages/dashboard/dashboard.dart' as _i2;
import 'package:frontend/presentation/pages/detail_room/room_detail.dart'
    as _i7;
import 'package:frontend/presentation/pages/landing/landing_page.dart' as _i4;
import 'package:frontend/presentation/pages/room_form/form_room.dart' as _i3;
import 'package:frontend/presentation/pages/room_list/room_page.dart' as _i8;
import 'package:frontend/presentation/widget/app_layout.dart' as _i1;

/// generated route for
/// [_i1.AppLayoutPage]
class AppLayoutRoute extends _i9.PageRouteInfo<void> {
  const AppLayoutRoute({List<_i9.PageRouteInfo>? children})
    : super(AppLayoutRoute.name, initialChildren: children);

  static const String name = 'AppLayoutRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      return const _i1.AppLayoutPage();
    },
  );
}

/// generated route for
/// [_i2.DashboardPage]
class DashboardRoute extends _i9.PageRouteInfo<void> {
  const DashboardRoute({List<_i9.PageRouteInfo>? children})
    : super(DashboardRoute.name, initialChildren: children);

  static const String name = 'DashboardRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      return const _i2.DashboardPage();
    },
  );
}

/// generated route for
/// [_i3.FormRoomPage]
class FormRoomRoute extends _i9.PageRouteInfo<FormRoomRouteArgs> {
  FormRoomRoute({
    _i10.Key? key,
    int? roomId,
    required _i3.FormMode formMode,
    List<_i9.PageRouteInfo>? children,
  }) : super(
         FormRoomRoute.name,
         args: FormRoomRouteArgs(key: key, roomId: roomId, formMode: formMode),
         rawPathParams: {'id': roomId},
         initialChildren: children,
       );

  static const String name = 'FormRoomRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<FormRoomRouteArgs>();
      return _i3.FormRoomPage(
        key: args.key,
        roomId: args.roomId,
        formMode: args.formMode,
      );
    },
  );
}

class FormRoomRouteArgs {
  const FormRoomRouteArgs({this.key, this.roomId, required this.formMode});

  final _i10.Key? key;

  final int? roomId;

  final _i3.FormMode formMode;

  @override
  String toString() {
    return 'FormRoomRouteArgs{key: $key, roomId: $roomId, formMode: $formMode}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! FormRoomRouteArgs) return false;
    return key == other.key &&
        roomId == other.roomId &&
        formMode == other.formMode;
  }

  @override
  int get hashCode => key.hashCode ^ roomId.hashCode ^ formMode.hashCode;
}

/// generated route for
/// [_i4.LandingPage]
class LandingRoute extends _i9.PageRouteInfo<void> {
  const LandingRoute({List<_i9.PageRouteInfo>? children})
    : super(LandingRoute.name, initialChildren: children);

  static const String name = 'LandingRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      return const _i4.LandingPage();
    },
  );
}

/// generated route for
/// [_i5.LoginPage]
class LoginRoute extends _i9.PageRouteInfo<LoginRouteArgs> {
  LoginRoute({_i10.Key? key, String? reason, List<_i9.PageRouteInfo>? children})
    : super(
        LoginRoute.name,
        args: LoginRouteArgs(key: key, reason: reason),
        rawQueryParams: {'reason': reason},
        initialChildren: children,
      );

  static const String name = 'LoginRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      final queryParams = data.queryParams;
      final args = data.argsAs<LoginRouteArgs>(
        orElse: () => LoginRouteArgs(reason: queryParams.optString('reason')),
      );
      return _i5.LoginPage(key: args.key, reason: args.reason);
    },
  );
}

class LoginRouteArgs {
  const LoginRouteArgs({this.key, this.reason});

  final _i10.Key? key;

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
/// [_i6.RegisterPage]
class RegisterRoute extends _i9.PageRouteInfo<RegisterRouteArgs> {
  RegisterRoute({_i10.Key? key, List<_i9.PageRouteInfo>? children})
    : super(
        RegisterRoute.name,
        args: RegisterRouteArgs(key: key),
        initialChildren: children,
      );

  static const String name = 'RegisterRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<RegisterRouteArgs>(
        orElse: () => const RegisterRouteArgs(),
      );
      return _i6.RegisterPage(key: args.key);
    },
  );
}

class RegisterRouteArgs {
  const RegisterRouteArgs({this.key});

  final _i10.Key? key;

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

/// generated route for
/// [_i7.RoomDetailPage]
class RoomDetailRoute extends _i9.PageRouteInfo<RoomDetailRouteArgs> {
  RoomDetailRoute({
    _i10.Key? key,
    required int roomId,
    List<_i9.PageRouteInfo>? children,
  }) : super(
         RoomDetailRoute.name,
         args: RoomDetailRouteArgs(key: key, roomId: roomId),
         rawPathParams: {'id': roomId},
         initialChildren: children,
       );

  static const String name = 'RoomDetailRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<RoomDetailRouteArgs>(
        orElse: () => RoomDetailRouteArgs(roomId: pathParams.getInt('id')),
      );
      return _i7.RoomDetailPage(key: args.key, roomId: args.roomId);
    },
  );
}

class RoomDetailRouteArgs {
  const RoomDetailRouteArgs({this.key, required this.roomId});

  final _i10.Key? key;

  final int roomId;

  @override
  String toString() {
    return 'RoomDetailRouteArgs{key: $key, roomId: $roomId}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! RoomDetailRouteArgs) return false;
    return key == other.key && roomId == other.roomId;
  }

  @override
  int get hashCode => key.hashCode ^ roomId.hashCode;
}

/// generated route for
/// [_i8.RoomPage]
class RoomRoute extends _i9.PageRouteInfo<void> {
  const RoomRoute({List<_i9.PageRouteInfo>? children})
    : super(RoomRoute.name, initialChildren: children);

  static const String name = 'RoomRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      return const _i8.RoomPage();
    },
  );
}
