import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/constant/permission_key.dart';
import 'package:frontend/core/constant/route_constant.dart';
import 'package:frontend/core/constant/style_constant.dart';
import 'package:frontend/core/navigation/auto_route.gr.dart';
import 'package:frontend/main.dart';
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
  void initState() {
    super.initState();
    // context.read<AuthBloc>().add(CheckSessionEvent());
  }

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
                  // dashboard
                  if (context.can(PermissionKeys.viewDashboard))
                    SidebarItem(
                      label: RouteConstant.dashboardName,
                      icon: Icons.dashboard,
                      page: DashboardRoute(),
                      hasAccess: true,
                    ),

                  if (context.can(PermissionKeys.viewPermission))
                    SidebarItem(
                      label: 'Izin',
                      icon: Icons.check_circle_outline,
                      page: const PermissionRoute(),
                      hasAccess: context.can('access-permission-management'),
                    ),
                  SidebarItem(
                    label: 'Peran',
                    icon: Icons.security,
                    page: RolePlaceholderRoute(),
                    hasAccess: true,
                  ),

                  // manajemen penghuni
                  SidebarItem(
                    label: 'Penghuni',
                    icon: Icons.people,
                    hasAccess: true,
                    children: [
                      SidebarItem(
                        label: 'penghuni',
                        icon: Icons.person,
                        page: const ResidentRoute(),
                      ),
                    ],
                  ),
                  if (context.can(PermissionKeys.viewRooms) ||
                      context.can(PermissionKeys.viewLease))
                    SidebarItem(
                      label: 'Kamar & Reservasi',
                      icon: Icons.room,
                      hasAccess: true,
                      children: [
                        // if (context.can(PermissionKeys.viewRooms))
                        SidebarItem(
                          label: 'Kamar',
                          icon: Icons.meeting_room,
                          page: RoomRoute(),
                        ),
                        if (context.can(PermissionKeys.viewLease))
                          SidebarItem(
                            label: 'Reservasi',
                            icon: Icons.book_online,
                            page: const ReservationRoute(),
                          ),
                        SidebarItem(
                          label: 'Jadwal Kamar',
                          icon: Icons.calendar_month_outlined,
                          page: const RoomScheduleRoute(),
                        ),
                      ],
                    ),

                  // manajemen keuangan
                  if (context.can(PermissionKeys.financeDashboardView))
                    SidebarItem(
                      label: 'Keuangan',
                      icon: Icons.monetization_on,
                      hasAccess: true,
                      children: [
                        SidebarItem(
                          label: 'Dashboard',
                          icon: Icons.dashboard_outlined,
                          page: const FinanceDashboardRoute(),
                        ),
                        SidebarItem(
                          label: 'Pengeluaran',
                          icon: Icons.receipt_long,
                          page: const ExpenseListRoute(),
                        ),
                      ],
                    ),

                  SidebarItem(
                    label: 'Inventaris & Pemiliharaan',
                    icon: Icons.inventory,
                    hasAccess: true,
                    children: [
                      SidebarItem(
                        label: 'Inventaris',
                        icon: Icons.inventory,
                        page: const InventoryRoute(),
                      ),
                      SidebarItem(
                        label: 'Pemeliharaan',
                        icon: Icons.build,
                        page: const MaintananceRoute(),
                      ),
                      SidebarItem(
                        label: 'Laporan Kerusakan',
                        icon: Icons.report_problem_outlined,
                        page: const MaintenanceReportListRoute(),
                      ),
                    ],
                  ),

                  // pengaturan
                  SidebarItem(
                    label: 'Pengaturan',
                    icon: Icons.settings,
                    page: SettingPlaceholderRoute(),
                  ),
                ],
              ),
              Expanded(child: AutoRouter()),
            ],
          );
        },
      ),
    );
  }
}
