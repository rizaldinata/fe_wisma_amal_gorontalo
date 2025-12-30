import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/constant/route_constant.dart';
import 'package:frontend/core/constant/style_constant.dart';
import 'package:frontend/core/navigation/auto_route.gr.dart';
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
      body: Row(
        children: [
          CustomSidebar(
            currentRoute: context.router.current.name,
            items: [
              SidebarItem(
                onTap: () {
                  setState(() {
                    context.router.replace(const DashboardRoute());
                  });
                },
                label: RouteConstant.dashboardName,
                icon: Icons.dashboard,
                routeName: DashboardRoute.name,
              ),
              SidebarItem(
                onTap: () {
                  setState(() {
                    context.router.replace(const RoomRoute());
                  });
                },
                label: RouteConstant.roomName,
                icon: Icons.meeting_room,
                routeName: RoomRoute.name,
              ),
              SidebarItem(onTap: () {}, label: 'Test 2', icon: Icons.abc),
              SidebarItem(
                onTap: () {},
                label: 'Test 3',
                icon: Icons.access_alarm,
              ),
            ],
          ),
          // Expanded(child: AutoRouter()),
          Expanded(child: AutoRouter()),
        ],
      ),
    );
  }
}
