import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/constant/permission_key.dart';
import 'package:frontend/core/constant/style_constant.dart';
import 'package:frontend/core/navigation/auto_route.gr.dart';
import 'package:frontend/main.dart';
import 'package:frontend/presentation/bloc/auth/auth_bloc.dart';
import 'package:frontend/presentation/bloc/auth/auth_event.dart';
import 'package:frontend/presentation/bloc/auth/auth_state.dart';
import 'package:frontend/presentation/widget/core/sidebar/sidebar.dart';

@RoutePage()
class AppLayoutPage extends StatefulWidget {
  const AppLayoutPage({super.key});

  @override
  State<AppLayoutPage> createState() => _AppLayoutPageState();
}

class _AppLayoutPageState extends State<AppLayoutPage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Refresh permissions otomatis saat app dibuka kembali dari background
    if (state == AppLifecycleState.resumed && mounted) {
      context.read<AuthBloc>().add(const GetPermissionsEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    // Read router here (outer context) so _AppLayoutPageState subscribes to
    // RouterScope — not BlocBuilder's inner element. This prevents a
    // bottom-up rebuild of BlocBuilder during route transitions which
    // conflicts with AutoRoute's element lifecycle management.
    final activeRouteNames = <String>{};
    try {
      final router = AutoRouter.of(context, watch: true);
      final current = router.current;
      activeRouteNames.add(current.name);

      final segments = router.currentSegments;
      for (final s in segments) {
        activeRouteNames.add(s.name);
      }

      final stack = router.stack;
      for (final entry in stack) {
        final name = entry.name;
        if (name != null) {
          activeRouteNames.add(name);
        }
      }
    } catch (_) {}

    return Scaffold(
      backgroundColor: StyleConstant.backgroundColor,

      body: BlocListener<AuthBloc, AuthState>(
        listenWhen: (previous, current) => previous.isLoggedIn == true && current.isLoggedIn == false,
        listener: (context, state) {
          // Ketika logout, pastikan kembali ke root publik (RoomRoute)
          context.router.replaceAll([
            const AppLayoutRoute(
              children: [RoomRoute()],
            ),
          ]);
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final isGuest = !state.isLoggedIn;

          final roles = state.userInfo?.roles ?? [];

          final isMember = roles.contains('member');

          final isResident = roles.contains('resident');

          return Row(
            children: [
              CustomSidebar(
                activeRouteNames: activeRouteNames,

                items: [
                  // ─── Dashboard ─────────────────────────────────────
                  if (context.can(PermissionKeys.viewDashboard))
                    SidebarItem(
                      label: 'Dashboard Admin',
                      icon: Icons.dashboard,
                      page: DashboardRoute(),
                      hasAccess: true,
                    ),

                  if (context.can(PermissionKeys.viewResidentDashboard))
                    SidebarItem(
                      label: 'Dashboard Penghuni',
                      icon: Icons.dashboard_customize_outlined,
                      page: const ResidentDashboardRoute(),
                      hasAccess: true,
                    ),

                  // ─── Autentikasi Sistem (Permission & Role) ────────
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

                  // ─── Manajemen Akun ────────────────────────────────
                  if (context.can(PermissionKeys.viewUser))
                    SidebarItem(
                      label: 'Manajemen Akun',
                      icon: Icons.manage_accounts,
                      page: const UserManagementRoute(),
                      hasAccess: true,
                    ),

                  // ─── Manajemen Penghuni (Admin) ────────────────────
                  // Tampil jika memiliki salah satu permission pengelolaan penghuni/tamu
                  if (context.can(PermissionKeys.viewResident) ||
                      (context.can(PermissionKeys.viewGuest) && context.isFeatureEnabled('guest')) ||
                      (context.can(PermissionKeys.viewGuestBill) && context.isFeatureEnabled('guest')))
                    SidebarItem(
                      label: 'Manajemen Penghuni',
                      icon: Icons.admin_panel_settings,
                      hasAccess: true,
                      children: [
                        if (context.can(PermissionKeys.viewResident))
                          SidebarItem(
                            label: 'Daftar Penghuni',
                            icon: Icons.people,
                            page: const ResidentRoute(),
                          ),
                        if (context.can(PermissionKeys.viewGuest) && context.isFeatureEnabled('guest'))
                          SidebarItem(
                            label: 'Daftar Tamu',
                            icon: Icons.groups,
                            page: const GuestListRoute(),
                          ),
                        if (context.can(PermissionKeys.viewGuestBill) && context.isFeatureEnabled('guest'))
                          SidebarItem(
                            label: 'Tagihan Tamu',
                            icon: Icons.receipt_long_outlined,
                            page: const AdminGuestBillRoute(),
                          ),
                      ],
                    ),

                  // ─── Kamar & Reservasi (Admin) ─────────────────────
                  if (!isGuest &&
                      !isResident &&
                      !isMember &&
                      ((context.can(PermissionKeys.viewRooms) && context.isFeatureEnabled('room')) ||
                          context.isFeatureEnabled('schedule') ||
                          ((context.can(PermissionKeys.viewLease) ||
                              context.can(PermissionKeys.approveLease)) && context.isFeatureEnabled('schedule'))))
                    SidebarItem(
                      label: 'Kamar & Reservasi',
                      icon: Icons.room,
                      hasAccess: true,
                      children: [
                        if (context.can(PermissionKeys.viewRooms) && context.isFeatureEnabled('room'))
                          SidebarItem(
                            label: 'Kamar',
                            icon: Icons.meeting_room,
                            page: RoomRoute(),
                          ),
                        if (context.isFeatureEnabled('schedule'))
                          SidebarItem(
                            label: 'Jadwal Kamar',
                            icon: Icons.calendar_month_outlined,
                            page: const RoomScheduleRoute(),
                          ),
                        if ((context.can(PermissionKeys.viewLease) ||
                            context.can(PermissionKeys.approveLease)) && context.isFeatureEnabled('schedule'))
                          SidebarItem(
                            label: 'Reservasi',
                            icon: Icons.book_online,
                            page: const ReservationRoute(),
                          ),
                      ],
                    ),

                  // ─── Keuangan (Admin) ──────────────────────────────
                  if (context.isFeatureEnabled('finance') &&
                      ((context.can(PermissionKeys.financeDashboardView) && context.isFeatureEnabled('finance_dashboard')) ||
                      ((context.can(PermissionKeys.financeExpenseView) || context.can(PermissionKeys.financeFixedExpenseView)) && (context.isFeatureEnabled('finance_expense') || context.isFeatureEnabled('finance_fixed_expense'))) ||
                      (context.can(PermissionKeys.financeInvoiceView) && context.isFeatureEnabled('finance_invoice')) ||
                      (context.can(PermissionKeys.financePaymentVerify) && context.isFeatureEnabled('finance_invoice')) ||
                      (context.can(PermissionKeys.financePaymentView) && context.isFeatureEnabled('finance_invoice'))))
                    SidebarItem(
                      label: 'Keuangan',
                      icon: Icons.monetization_on,
                      hasAccess: true,
                      children: [
                        if (context.can(PermissionKeys.financeDashboardView) && context.isFeatureEnabled('finance_dashboard'))
                          SidebarItem(
                            label: 'Dashboard',
                            icon: Icons.dashboard_outlined,
                            page: const FinanceDashboardRoute(),
                          ),
                        if ((context.can(PermissionKeys.financeExpenseView) ||
                            context.can(PermissionKeys.financeFixedExpenseView)) && (context.isFeatureEnabled('finance_expense') || context.isFeatureEnabled('finance_fixed_expense')))
                          SidebarItem(
                            label: 'Pengeluaran',
                            icon: Icons.receipt_long,
                            page: const ExpenseListRoute(),
                          ),
                        if (context.can(PermissionKeys.financeInvoiceView) && context.isFeatureEnabled('finance_invoice'))
                          SidebarItem(
                            label: 'Daftar Tagihan',
                            icon: Icons.description_outlined,
                            page: const InvoiceListRoute(),
                          ),
                        if (context.can(PermissionKeys.financePaymentVerify) && context.isFeatureEnabled('finance_invoice'))
                          SidebarItem(
                            label: 'Manajemen Pembayaran',
                            icon: Icons.payments_outlined,
                            page: const PaymentVerificationRoute(),
                          ),
                      ],
                    ),

                  // ─── Inventaris & Pemeliharaan (Admin) ────────────
                  if (!isResident &&
                      !isMember &&
                      ((context.can(PermissionKeys.viewInventory) && context.isFeatureEnabled('inventory')) ||
                          (context.can(PermissionKeys.viewMaintenance) && context.isFeatureEnabled('maintenance_schedule')) ||
                          (context.can(PermissionKeys.viewDamageReport) && context.isFeatureEnabled('damage_report'))))
                    SidebarItem(
                      label: 'Inventaris & Pemeliharaan',
                      icon: Icons.inventory,
                      hasAccess: true,
                      children: [
                        if (context.can(PermissionKeys.viewInventory) && context.isFeatureEnabled('inventory'))
                          SidebarItem(
                            label: 'Inventaris',
                            icon: Icons.inventory,
                            page: const InventoryRoute(),
                          ),
                        if (context.can(PermissionKeys.viewMaintenance) && context.isFeatureEnabled('maintenance_schedule'))
                          SidebarItem(
                            label: 'Pemeliharaan',
                            icon: Icons.build,
                            page: const MaintananceRoute(),
                          ),
                        if (context.can(PermissionKeys.viewDamageReport) && context.isFeatureEnabled('damage_report'))
                          SidebarItem(
                            label: 'Laporan Kerusakan',
                            icon: Icons.report_problem_outlined,
                            page: const MaintenanceReportListRoute(),
                          ),
                      ],
                    ),

                  // ══════════════════════════════════════════════════
                  // Area untuk pengguna terdaftar (Member & Resident)
                  // ══════════════════════════════════════════════════

                  // ─── Kamar (Member, Resident, Guest) ──────────────
                  if ((isGuest || isMember || isResident) && context.isFeatureEnabled('room'))
                    SidebarItem(
                      label: 'Kamar',
                      icon: Icons.meeting_room,
                      page: RoomRoute(),
                    ),

                  // ─── Reservasi (Pengunjung belum login) ────────────
                  // if (isGuest)
                  //   SidebarItem(
                  //     label: 'Reservasi',
                  //     icon: Icons.book_online,
                  //     page: const ReservationRoute(),
                  //   ),

                  // ─── Area Member (pengguna terdaftar, belum punya kamar) ──
                  if (isMember) ...[
                    if ((context.can(PermissionKeys.applyLease) ||
                        context.can(PermissionKeys.viewLease)) && context.isFeatureEnabled('schedule'))
                      SidebarItem(
                        label: 'Reservasi Saya',
                        icon: Icons.book_online_outlined,
                        page: const MyReservationRoute(),
                      ),
                    if (context.can(PermissionKeys.financeMeSummaryView) && context.isFeatureEnabled('finance'))
                      SidebarItem(
                        label: 'Keuangan Saya',
                        icon: Icons.account_balance_wallet_outlined,
                        page: const MemberFinanceRoute(),
                      ),
                    if (context.isFeatureEnabled('guest'))
                      SidebarItem(
                        label: 'Tamu Saya',
                        icon: Icons.people_alt_outlined,
                        page: const MyGuestRoute(),
                      ),
                  ],

                  // ─── Area Penghuni (resident aktif) ────────────────
                  if (isResident && (
                      (context.can(PermissionKeys.financeMeSummaryView) && context.isFeatureEnabled('finance')) ||
                      ((context.can(PermissionKeys.applyLease) || context.can(PermissionKeys.viewLease)) && context.isFeatureEnabled('schedule')) ||
                      ((context.can(PermissionKeys.viewMyGuest) || context.can(PermissionKeys.createGuest) || context.can(PermissionKeys.payGuestBill)) && context.isFeatureEnabled('guest')) ||
                      (context.can(PermissionKeys.createDamageReport) && context.isFeatureEnabled('damage_report')) ||
                      (context.can(PermissionKeys.viewMyDamageReport) && context.isFeatureEnabled('damage_report')) ||
                      (context.can(PermissionKeys.viewMaintenance) && context.isFeatureEnabled('maintenance_schedule'))
                  ))
                    SidebarItem(
                      label: 'Area Penghuni',
                      icon: Icons.home_work_outlined,
                      hasAccess: true,
                      children: [
                        if (context.can(PermissionKeys.financeMeSummaryView) && context.isFeatureEnabled('finance'))
                          SidebarItem(
                            label: 'Keuangan Saya',
                            icon: Icons.account_balance_wallet_outlined,
                            page: const MemberFinanceRoute(),
                          ),
                        if ((context.can(PermissionKeys.applyLease) ||
                            context.can(PermissionKeys.viewLease)) && context.isFeatureEnabled('schedule'))
                          SidebarItem(
                            label: 'Reservasi Saya',
                            icon: Icons.book_online_outlined,
                            page: const MyReservationRoute(),
                          ),
                        if ((context.can(PermissionKeys.viewMyGuest) ||
                            context.can(PermissionKeys.createGuest) ||
                            context.can(PermissionKeys.payGuestBill)) && context.isFeatureEnabled('guest'))
                          SidebarItem(
                            label: 'Tamu Saya',
                            icon: Icons.people_alt_outlined,
                            page: const MyGuestRoute(),
                          ),
                        if (context.can(PermissionKeys.createDamageReport) && context.isFeatureEnabled('damage_report'))
                          SidebarItem(
                            label: 'Lapor Kerusakan',
                            icon: Icons.report_problem_outlined,
                            page: const MaintenanceCreateReportRoute(),
                          ),
                        if (context.can(PermissionKeys.viewMyDamageReport) && context.isFeatureEnabled('damage_report'))
                          SidebarItem(
                            label: 'Status Laporan',
                            icon: Icons.track_changes_outlined,
                            page: const MaintenanceReportListRoute(),
                          ),
                        if (context.can(PermissionKeys.viewMaintenance) && context.isFeatureEnabled('maintenance_schedule'))
                          SidebarItem(
                            label: 'Jadwal Pemeliharaan',
                            icon: Icons.calendar_today_outlined,
                            page: const MaintananceRoute(),
                          ),
                      ],
                    ),

                    // ─── Sistem & Akun ────────────────────────────
                    if (context.can(PermissionKeys.settingView) || state.isLoggedIn)
                      SidebarItem(
                        label: 'Sistem & Akun',
                        icon: Icons.settings_applications,
                        hasAccess: true,
                        children: [
                          if (context.can(PermissionKeys.settingView))
                            SidebarItem(
                              label: 'Pengaturan',
                              icon: Icons.settings,
                              page: const SettingRoute(),
                            ),
                          if ((isMember || isResident) &&
                              context.can(PermissionKeys.completeResidentProfile))
                            SidebarItem(
                              label: 'Lengkapi Profil',
                              icon: Icons.assignment_ind_outlined,
                              page: const CompleteProfileRoute(),
                            ),
                          if (state.isLoggedIn)
                            SidebarItem(
                              label: 'Profil Saya',
                              icon: Icons.person_outline,
                              page: const ProfileRoute(),
                            ),
                        ],
                      ),
                ],
              ),

              Expanded(child: AutoRouter()),
            ],
          );
        },
      ),
    ),
    );
  }
}