import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/navigation/auto_route.gr.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/theme/app_spacing.dart';
import 'package:frontend/core/dependency_injection/dependency_injection.dart';
import 'package:frontend/domain/entities/dashboard_entity.dart';
import 'package:frontend/presentation/bloc/auth/auth_bloc.dart';
import 'package:frontend/presentation/bloc/auth/auth_state.dart';
import 'package:frontend/presentation/bloc/dashboard/dashboard_bloc.dart';
import 'package:frontend/presentation/bloc/dashboard/dashboard_event.dart';
import 'package:frontend/presentation/bloc/dashboard/dashboard_state.dart';
import 'package:intl/intl.dart';

@RoutePage()
class ResidentDashboardPage extends StatelessWidget {
  const ResidentDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          serviceLocator<DashboardBloc>()..add(FetchResidentDashboard()),
      child: Scaffold(
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            final user = authState.userInfo;
            final name = user?.name ?? 'Penghuni';

            return BlocBuilder<DashboardBloc, DashboardState>(
              builder: (context, dashboardState) {
                if (dashboardState is DashboardLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (dashboardState is DashboardError) {
                  return Center(
                    child: Text('Gagal memuat data: ${dashboardState.message}'),
                  );
                }

                if (dashboardState is ResidentDashboardLoaded) {
                  final data = dashboardState.dashboard;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Hero Section
                        _buildHeroSection(context, name),
                        const SizedBox(height: AppSpacing.xl),

                        // Layout Builder for Grid
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final isDesktop = constraints.maxWidth > 900;

                            if (isDesktop) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 7,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        _buildStatusCard(context, data),
                                        const SizedBox(height: AppSpacing.xl),
                                        _buildQuickActions(context),
                                        _buildRecentDamageReports(
                                          context,
                                          data,
                                        ),
                                        _buildRecentGuests(context, data),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.xl),
                                  Expanded(
                                    flex: 5,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        _buildRecentBills(context, data),
                                        _buildMaintenanceSchedules(context, data),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            } else {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _buildStatusCard(context, data),
                                  const SizedBox(height: AppSpacing.xl),
                                  _buildQuickActions(context),
                                  _buildRecentDamageReports(context, data),
                                  _buildRecentGuests(context, data),
                                  const SizedBox(height: AppSpacing.xl),
                                  _buildRecentBills(context, data),
                                  _buildMaintenanceSchedules(context, data),
                                ],
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  );
                }

                return const SizedBox();
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, String name) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [primaryColor.withOpacity(0.85), primaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Halo,',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 4),
          Text(
            name,
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Selamat datang di portal penghuni Wisma Amal.\nSemoga harimu menyenangkan!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.9),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, ResidentDashboardEntity data) {
    final bgColor = Theme.of(context).colorScheme.surface;
    final colors = AppTheme.colors(context);
    final isActive =
        data.activeRoom?.status.toUpperCase() == 'ACTIVE' ||
        data.activeRoom?.status == 'Aktif';

    final statusColor = isActive ? colors.statusDone : colors.statusWaiting;
    final statusBg = isActive ? colors.statusDoneBg : colors.statusWaitingBg;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 24,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: statusBg, shape: BoxShape.circle),
            child: Icon(Icons.meeting_room, color: statusColor, size: 32),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kamar Anda',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data.activeRoom?.roomNumber ?? 'Belum Ada',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          if (data.activeRoom != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: statusBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(
                    isActive ? Icons.check_circle : Icons.hourglass_empty,
                    size: 16,
                    color: statusColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isActive ? 'Aktif' : data.activeRoom!.status,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Aksi Cepat',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSpacing.lg),
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: [
            _buildActionItem(
              context,
              icon: Icons.report_problem_outlined,
              label: 'Lapor\nKerusakan',
              color: Colors.orange,
              onTap: () {
                context.router.navigate(const MaintenanceCreateReportRoute());
              },
            ),
            _buildActionItem(
              context,
              icon: Icons.receipt_long_outlined,
              label: 'Tagihan\nSaya',
              color: Colors.blue,
              onTap: () {
                context.router.navigate(const MemberFinanceRoute());
              },
            ),
            _buildActionItem(
              context,
              icon: Icons.groups_outlined,
              label: 'Daftar\nTamu',
              color: Colors.purple,
              onTap: () {
                context.router.navigate(const MyGuestRoute());
              },
            ),
            _buildActionItem(
              context,
              icon: Icons.event_available_outlined,
              label: 'Reservasi\nFasilitas',
              color: Colors.teal,
              onTap: () {
                context.router.navigate(const RoomRoute());
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final bgColor = Theme.of(context).colorScheme.surface;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 120,
        height: 120,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Theme.of(context).dividerColor),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentBills(BuildContext context, ResidentDashboardEntity data) {
    final bgColor = Theme.of(context).colorScheme.surface;
    final formatCurrency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final colors = AppTheme.colors(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 24,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tagihan Terbaru',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  context.router.navigate(const MemberFinanceRoute());
                },
                child: const Text('Lihat Semua'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (data.recentBills.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Belum ada tagihan',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            )
          else
            ...data.recentBills.asMap().entries.map((entry) {
              final idx = entry.key;
              final bill = entry.value;
              final isPaid = bill.status.toUpperCase() == 'PAID';
              final color = isPaid ? colors.statusDone : colors.statusWaiting;
              final statusText = isPaid ? 'Lunas' : 'Menunggu Pembayaran';
              final isLast = idx == data.recentBills.length - 1;

              return Column(
                children: [
                  _buildBillItem(
                    context,
                    bill.title,
                    formatCurrency.format(bill.amount),
                    statusText,
                    color,
                  ),
                  if (!isLast) const Divider(height: 24),
                ],
              );
            }),
        ],
      ),
    );
  }

  Widget _buildBillItem(
    BuildContext context,
    String title,
    String amount,
    String status,
    Color statusColor,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.receipt_outlined, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                status,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Text(
          amount,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentDamageReports(
    BuildContext context,
    ResidentDashboardEntity data,
  ) {
    if (data.isMaintenanceActive != true ||
        data.recentDamageReports == null ||
        data.recentDamageReports!.isEmpty) {
      return const SizedBox();
    }

    final bgColor = Theme.of(context).colorScheme.surface;
    final colors = AppTheme.colors(context);

    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.xl),
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 24,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Laporan Kerusakan Saya',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  context.router.navigate(const MaintenanceReportListRoute());
                },
                child: const Text('Lihat Semua'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...data.recentDamageReports!.asMap().entries.map((entry) {
            final idx = entry.key;
            final report = entry.value;
            final isLast = idx == data.recentDamageReports!.length - 1;

            final status = report.status.toUpperCase();
            final Color statusColor = status == 'PENDING'
                ? colors.statusWaiting
                : status == 'IN_PROGRESS'
                ? colors.statusProcess
                : colors.statusDone;
            final Color statusBg = status == 'PENDING'
                ? colors.statusWaitingBg
                : status == 'IN_PROGRESS'
                ? colors.statusProcessBg
                : colors.statusDoneBg;

            return Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.build_outlined,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            report.title,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('dd MMM yyyy').format(report.reportedAt),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.6),
                                ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        status == 'PENDING'
                            ? 'Menunggu'
                            : status == 'IN_PROGRESS'
                            ? 'Proses'
                            : 'Selesai',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                if (!isLast) const Divider(height: 24),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRecentGuests(
    BuildContext context,
    ResidentDashboardEntity data,
  ) {
    if (data.isGuestActive != true ||
        data.recentGuests == null ||
        data.recentGuests!.isEmpty) {
      return const SizedBox();
    }

    final bgColor = Theme.of(context).colorScheme.surface;

    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.xl),
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 24,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tamu Saya',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  context.router.navigate(const MyGuestRoute());
                },
                child: const Text('Lihat Semua'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...data.recentGuests!.asMap().entries.map((entry) {
            final idx = entry.key;
            final guest = entry.value;
            final isLast = idx == data.recentGuests!.length - 1;

            return Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.people_outline,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            guest.name,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Hubungan: ${guest.relationship}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.6),
                                ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      DateFormat('dd MMM').format(guest.checkInAt),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (!isLast) const Divider(height: 24),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMaintenanceSchedules(
    BuildContext context,
    ResidentDashboardEntity data,
  ) {
    if (data.isMaintenanceActive != true ||
        data.maintenanceSchedules == null ||
        data.maintenanceSchedules!.isEmpty) {
      return const SizedBox();
    }

    final bgColor = Theme.of(context).colorScheme.surface;
    final colors = AppTheme.colors(context);

    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.xl),
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 24,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Agenda Pemeliharaan Pekan Ini',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  context.router.navigate(const MaintananceRoute());
                },
                child: const Text('Lihat Semua'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...data.maintenanceSchedules!.map((schedule) {
            final status = schedule.status.toUpperCase();
            final Color statusColor = status == 'DONE'
                ? colors.statusDone
                : status == 'CANCELLED'
                ? colors.statusCancelled
                : colors.statusProcess;
            final Color statusBg = status == 'DONE'
                ? colors.statusDoneBg
                : status == 'CANCELLED'
                ? colors.statusCancelledBg
                : colors.statusProcessBg;
            final String statusText = status == 'DONE'
                ? 'Selesai'
                : status == 'CANCELLED'
                ? 'Batal'
                : 'Proses';

            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      DateFormat('dd\nMMM').format(schedule.startTime),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            height: 1.1,
                          ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Teknisi: ${schedule.technicianName}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        Text(
                          'Lokasi: ${schedule.location} • ${schedule.type}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      statusText,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
