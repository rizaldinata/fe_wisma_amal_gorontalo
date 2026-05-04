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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StyleConstant.backgroundColor,
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final isGuest = !state.isLoggedIn;
          final roles = state.userInfo?.roles ?? [];
          final isMember = roles.contains('member');
          final isResident = roles.contains('resident');

          return Row(
            children: [
              CustomSidebar(
                activeRouteName: context.router.current.name,
                items: [
                  // ─── Dashboard ─────────────────────────────────────
                  if (context.can(PermissionKeys.viewDashboard))
                    SidebarItem(
                      label: RouteConstant.dashboardName,
                      icon: Icons.dashboard,
                      page: DashboardRoute(),
                      hasAccess: true,
                    ),

                  // ─── System Auth (Permission & Role) ───────────────
                  if (context.can(PermissionKeys.viewPermission) ||
                      context.can(PermissionKeys.viewRole))
                    SidebarItem(
                      label: 'Autentikasi Sistem',
                      icon: Icons.security,
                      hasAccess: true,
                      children: [
                        if (context.can(PermissionKeys.viewPermission))
                          SidebarItem(
                            label: 'Izin',
                            icon: Icons.check_circle_outline,
                            page: const PermissionRoute(),
                          ),
                        if (context.can(PermissionKeys.viewRole))
                          SidebarItem(
                            label: 'Peran',
                            icon: Icons.security,
                            page: RoleManagementRoute(),
                          ),
                      ],
                    ),

                  // ─── User Management ───────────────────────────────
                  if (context.can(PermissionKeys.viewUser))
                    SidebarItem(
                      label: 'Manajemen Akun',
                      icon: Icons.manage_accounts,
                      page: const UserManagementRoute(),
                      hasAccess: true,
                    ),

                  // ─── Manajemen Penghuni (Admin) ────────────────────
                  if (context.can(PermissionKeys.viewResident))
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
                        SidebarItem(
                          label: 'Kontrak Sewa',
                          icon: Icons.description,
                          page: const ContractResidentRoute(),
                        ),
                        SidebarItem(
                          label: 'Daftar Tamu',
                          icon: Icons.groups,
                          page: const GuestListRoute(),
                        ),
                      ],
                    ),

                  // ─── Area Penghuni (Khusus Resident/Member) ────────
                  if (isResident || isMember)
                    SidebarItem(
                      label: 'Area Penghuni',
                      icon: Icons.home_work_outlined,
                      hasAccess: true,
                      children: [
                        SidebarItem(
                          label: 'Keuangan Saya',
                          icon: Icons.account_balance_wallet_outlined,
                          page: const MemberFinanceRoute(),
                        ),
                        SidebarItem(
                          label: 'Profil Saya',
                          icon: Icons.person_pin_outlined,
                          page: const ProfileRoute(),
                        ),
                        SidebarItem(
                          label: 'Lapor Kerusakan',
                          icon: Icons.report_problem_outlined,
                          page: const MaintenanceCreateReportRoute(),
                        ),
                        SidebarItem(
                          label: 'Status Laporan',
                          icon: Icons.track_changes_outlined,
                          page: const MaintenanceReportListRoute(),
                        ),
                        SidebarItem(
                          label: 'Jadwal Pemeliharaan',
                          icon: Icons.calendar_today_outlined,
                          page: const MaintananceRoute(),
                        ),
                      ],
                    ),

                  // ─── Kamar & Reservasi ─────────────────────────────
                  if (context.can(PermissionKeys.viewRooms) || isGuest)
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
                        SidebarItem(
                          label: 'Jadwal Kamar',
                          icon: Icons.calendar_month_outlined,
                          page: const RoomScheduleRoute(),
                        ),
                        if (context.can(PermissionKeys.viewLease))
                          SidebarItem(
                            label: 'Reservasi',
                            icon: Icons.book_online,
                            page: const ReservationRoute(),
                          ),
                      ],
                    ),

                  // ─── Keuangan ──────────────────────────────────────
                  if (context.can(PermissionKeys.financeDashboardView) ||
                      context.can(PermissionKeys.financeExpenseView) ||
                      context.can(PermissionKeys.financeInvoiceView) ||
                      context.can(PermissionKeys.financePaymentVerify))
                    SidebarItem(
                      label: 'Keuangan',
                      icon: Icons.monetization_on,
                      hasAccess: true,
                      children: [
                        if (context.can(PermissionKeys.financeDashboardView))
                          SidebarItem(
                            label: 'Dashboard',
                            icon: Icons.dashboard_outlined,
                            page: const FinanceDashboardRoute(),
                          ),
                        if (context.can(PermissionKeys.financeExpenseView))
                          SidebarItem(
                            label: 'Pengeluaran',
                            icon: Icons.receipt_long,
                            page: const ExpenseListRoute(),
                          ),
                        if (context.can(PermissionKeys.financeInvoiceView))
                          SidebarItem(
                            label: 'Daftar Tagihan',
                            icon: Icons.description_outlined,
                            page: const InvoiceListRoute(),
                          ),
                        if (context.can(PermissionKeys.financePaymentVerify))
                          SidebarItem(
                            label: 'Verifikasi Pembayaran',
                            icon: Icons.check_circle_outline,
                            page: const PaymentVerificationRoute(),
                          ),
                      ],
                    ),

                  // ─── Inventaris & Pemeliharaan ─────────────────────
                  if (!isResident &&
                      !isMember &&
                      (context.can(PermissionKeys.viewInventory) ||
                          context.can(PermissionKeys.viewMaintenance) ||
                          context.can(PermissionKeys.viewDamageReport)))
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
                        if (context.can(PermissionKeys.viewMaintenance))
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

                  // ─── Lengkapi Profil (member baru yang belum melengkapi) ──
                  if (context.can(PermissionKeys.completeResidentProfile) &&
                      !isMember)
                    SidebarItem(
                      label: 'Lengkapi Profil',
                      icon: Icons.assignment_ind_outlined,
                      page: const CompleteProfileRoute(),
                    ),

                  // ─── Pengaturan ────────────────────────────────────
                  if (context.can(PermissionKeys.settingView))
                    SidebarItem(
                      label: 'Pengaturan',
                      icon: Icons.settings,
                      page: const SettingRoute(),
                    ),

                  // ─── Profil Saya (semua user login) ───────────────
                  if (!isGuest && !isResident)
                    SidebarItem(
                      label: 'Profil Saya',
                      icon: Icons.person_outline,
                      page: const ProfileRoute(),
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
