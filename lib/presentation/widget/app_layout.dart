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
          final isGuest = !state.isLoggedIn;

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
                      hasAccess: true,
                    ),
                  if (context.can(PermissionKeys.viewRole))
                    SidebarItem(
                      label: 'Peran',
                      icon: Icons.security,
                      page: RolePlaceholderRoute(),
                      hasAccess: true,
                    ),

                  // manajemen penghuni (Admin)
                  if (context.can(PermissionKeys.accessResidentManagement))
                    SidebarItem(
                      label: 'Manajemen Penghuni',
                      icon: Icons.admin_panel_settings,
                      hasAccess: true,
                      children: [
                        SidebarItem(
                          label: 'Daftar Penghuni',
                          icon: Icons.people,
                          page: const ResidentRoute(),
                        ),
                      ],
                    ),

                  // Area Penghuni (Khusus Resident)
                  if (context.can(PermissionKeys.accessResidentArea))
                    SidebarItem(
                      label: 'Area Penghuni',
                      icon: Icons.home_work_outlined,
                      hasAccess: true,
                      children: [
                        SidebarItem(
                          label: 'Profil Saya',
                          icon: Icons.person_pin_outlined,
                          page: const CompleteProfileRoute(), // Untuk saat ini arahkan ke sini untuk melihat/edit data
                        ),
                        if (context.can(PermissionKeys.createMaintenance))
                          SidebarItem(
                            label: 'Lapor Kerusakan',
                            icon: Icons.report_problem_outlined,
                            page: const MaintenanceCreateReportRoute(),
                          ),
                        if (context.can(PermissionKeys.viewMaintenance))
                          SidebarItem(
                            label: 'Jadwal Pemeliharaan',
                            icon: Icons.calendar_today_outlined,
                            page: const MaintananceRoute(),
                          ),
                        if (context.can(PermissionKeys.viewMaintenance))
                          SidebarItem(
                            label: 'Status Laporan',
                            icon: Icons.track_changes_outlined,
                            page: const MaintenanceReportListRoute(),
                          ),
                      ],
                    ),
                  if (context.can(PermissionKeys.viewRooms) ||
                      context.can(PermissionKeys.viewLease) ||
                      isGuest)
                    SidebarItem(
                      label: 'Kamar & Reservasi',
                      icon: Icons.room,
                      hasAccess: true,
                      children: [
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
                        SidebarItem(
                          label: 'Daftar Tagihan',
                          icon: Icons.description_outlined,
                          page: const InvoiceListRoute(),
                        ),
                        SidebarItem(
                          label: 'Verifikasi Pembayaran',
                          icon: Icons.check_circle_outline,
                          page: const PaymentVerificationRoute(),
                        ),
                      ],
                    ),

                  if (context.can(PermissionKeys.accessInventory) ||
                      context.can(PermissionKeys.accessMaintenance))
                    SidebarItem(
                      label: 'Inventaris & Pemiliharaan',
                      icon: Icons.inventory,
                      hasAccess: true,
                      children: [
                        if (context.can(PermissionKeys.viewInventory))
                          SidebarItem(
                            label: 'Inventaris',
                            icon: Icons.inventory,
                            page: const InventoryRoute(),
                          ),
                        if (context.can(PermissionKeys.accessMaintenance))
                          SidebarItem(
                            label: 'Pemeliharaan',
                            icon: Icons.build,
                            page: const MaintananceRoute(),
                          ),
                        if (context.can(PermissionKeys.viewDamageReport))
                          SidebarItem(
                            label: 'Laporan Kerusakan',
                            icon: Icons.report_problem_outlined,
                            page: const MaintenanceReportListRoute(),
                          ),
                      ],
                    ),

                  // profil completion
                  if (context.can(PermissionKeys.completeResidentProfile) &&
                      !context.can(PermissionKeys.accessResidentArea))
                    SidebarItem(
                      label: 'Lengkapi Profil',
                      icon: Icons.assignment_ind_outlined,
                      page: const CompleteProfileRoute(),
                    ),

                  // pengaturan
                  if (context.can(PermissionKeys.settingManagementAccess))
                    SidebarItem(
                      label: 'Pengaturan',
                      icon: Icons.settings,
                      page: const SettingRoute(),
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
