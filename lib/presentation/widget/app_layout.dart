import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/constant/route_constant.dart';
import 'package:frontend/core/constant/style_constant.dart';
import 'package:frontend/presentation/widget/core/sidebar.dart';

@RoutePage()
class AppLayoutPage extends StatelessWidget {
  const AppLayoutPage({super.key});

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
                  // context.router.replace(DashboardRoute());
                },
                label: RouteConstant.dashboardName,
                icon: Icons.dashboard,
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
          Expanded(child: Placeholder()),
        ],
      ),
    );
  }
}
