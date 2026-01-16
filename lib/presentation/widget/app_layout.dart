import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/constant/permission_key.dart';
import 'package:frontend/core/constant/route_constant.dart';
import 'package:frontend/core/constant/style_constant.dart';
import 'package:frontend/core/navigation/auto_route.gr.dart';
import 'package:frontend/presentation/bloc/auth/auth_bloc.dart';
import 'package:frontend/presentation/bloc/auth/auth_state.dart';
import 'package:frontend/presentation/widget/core/sidebar/sidebar.dart';

@RoutePage()
class AppLayoutPage extends StatefulWidget {
  const AppLayoutPage({super.key});

  @override
  State<AppLayoutPage> createState() => _AppLayoutPageState();
}

class _AppLayoutPageState extends State<AppLayoutPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StyleConstant.backgroundColor,
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          return Row(
            children: [
              CustomSidebar(
                activeRouteName: context.router.current.name,
                items: [
                  SidebarItem(
                    label: RouteConstant.dashboardName,
                    icon: Icons.dashboard,
                    routeName: DashboardRoute.name,
                    hasAccess: true,
                  ),
                  SidebarItem(
                    label: 'Rooms',
                    icon: Icons.storage,
                    hasAccess:
                        state.userInfo?.permissions?.can(
                          PermissionKeys.manageRooms,
                        ) ??
                        false,
                    children: [
                      SidebarItem(
                        label: RouteConstant.roomName,
                        icon: Icons.meeting_room,
                        routeName: RoomRoute.name,
                      ),
                    ],
                  ),
                  SidebarItem(label: 'Test 2', icon: Icons.abc, onTap: () {}),
                  SidebarItem(
                    label: 'Test 3',
                    icon: Icons.access_alarm,
                    onTap: () {},
                  ),
                ],
              ),
              // Expanded(child: AutoRouter()),
              Expanded(child: AutoRouter()),
            ],
          );
        },
      ),
    );
  }
}
