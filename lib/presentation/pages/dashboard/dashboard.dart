import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/dependency_injection/dependency_injection.dart';
import 'package:frontend/core/navigation/auto_route.gr.dart';
import 'package:frontend/domain/entity/table/tabel_colum.dart';
import 'package:frontend/presentation/bloc/dashboard/dashboard_bloc.dart';
import 'package:frontend/presentation/bloc/dashboard/dashboard_event.dart';
import 'package:frontend/presentation/bloc/dashboard/dashboard_state.dart';
import 'package:frontend/presentation/pages/dashboard/widget/bento_widgets.dart';
import 'package:frontend/presentation/widget/core/table/table.dart';
import 'package:intl/intl.dart';

@RoutePage()
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          serviceLocator<DashboardBloc>()..add(FetchAdminDashboard()),
      child: DashboardView(),
    );
  }
}

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(FetchAdminDashboard());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DashboardError) {
            return Center(child: Text('Gagal memuat data: ${state.message}'));
          }

          if (state is AdminDashboardLoaded) {
            final data = state.dashboard;
            final formatCurrency = NumberFormat.currency(
              locale: 'id_ID',
              symbol: 'Rp ',
              decimalDigits: 0,
            );

            // Helper to safely format amounts
            String formatAmount(double val) {
              if (val >= 1000000000)
                return 'Rp ${(val / 1000000000).toStringAsFixed(1)}M';
              if (val >= 1000000)
                return 'Rp ${(val / 1000000).toStringAsFixed(1)}Jt';
              return formatCurrency.format(val);
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth > 900;

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32.0,
                    vertical: 24.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dashboard',
                        style: Theme.of(context).textTheme.headlineLarge
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: -1,
                            ),
                      ),
                      const SizedBox(height: 32),

                      // TOP GRID SECTION
                      if (isDesktop)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left Area: Hero + Quick Alerts
                            Expanded(
                              flex: 5,
                              child: Column(
                                children: [
                                  HeroBentoCard(
                                    adminName:
                                        'Admin', // Idealnya diambil dari session/auth
                                    occupancyRate: data.totalRooms == 0
                                        ? 0
                                        : data.occupiedRooms / data.totalRooms,
                                    totalRooms: data.totalRooms,
                                  ),
                                  const SizedBox(height: 24),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: AlertBentoCard(
                                          title: 'Total Penghuni',
                                          count: data.totalResidents,
                                          description:
                                              'Jumlah penghuni aktif di sistem.',
                                          icon: Icons.people_alt_rounded,
                                          color: Colors.blueAccent,
                                        ),
                                      ),
                                      const SizedBox(width: 24),
                                      Expanded(
                                        child: AlertBentoCard(
                                          title: 'Aktivitas Terbaru',
                                          count: data.recentActivities.length,
                                          description:
                                              'Jumlah transaksi terakhir bulan ini.',
                                          icon: Icons.receipt_long_rounded,
                                          color: Colors.orange,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 24),
                            // Right Area: Stat Cards + Actions
                            Expanded(
                              flex: 3,
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: StatBentoCard(
                                          title: 'Kamar Tersedia',
                                          value: data.emptyRooms.toString(),
                                          icon: Icons.meeting_room_rounded,
                                          iconColor: Colors.teal,
                                          subtitle:
                                              'Dari ${data.totalRooms} Total',
                                        ),
                                      ),
                                      const SizedBox(width: 24),
                                      Expanded(
                                        child: StatBentoCard(
                                          title: 'Kamar Terisi',
                                          value: data.occupiedRooms.toString(),
                                          icon: Icons.bed_rounded,
                                          iconColor: Colors.blueAccent,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: StatBentoCard(
                                          title: 'Pendapatan Bulan Ini',
                                          value: formatAmount(
                                            data.monthlyIncome,
                                          ),
                                          icon: Icons
                                              .account_balance_wallet_rounded,
                                          iconColor: Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      else
                        // Mobile / Tablet Stacked Layout
                        Column(
                          children: [
                            HeroBentoCard(
                              adminName: 'Admin',
                              occupancyRate: data.totalRooms == 0
                                  ? 0
                                  : data.occupiedRooms / data.totalRooms,
                              totalRooms: data.totalRooms,
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: StatBentoCard(
                                    title: 'Kamar Tersedia',
                                    value: data.emptyRooms.toString(),
                                    icon: Icons.meeting_room_rounded,
                                    iconColor: Colors.teal,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: StatBentoCard(
                                    title: 'Kamar Terisi',
                                    value: data.occupiedRooms.toString(),
                                    icon: Icons.bed_rounded,
                                    iconColor: Colors.blueAccent,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            StatBentoCard(
                              title: 'Pendapatan Bulan Ini',
                              value: formatAmount(data.monthlyIncome),
                              icon: Icons.account_balance_wallet_rounded,
                              iconColor: Colors.green,
                            ),
                            const SizedBox(height: 20),
                            AlertBentoCard(
                              title: 'Total Penghuni',
                              count: data.totalResidents,
                              description: 'Jumlah penghuni aktif di sistem.',
                              icon: Icons.people_alt_rounded,
                              color: Colors.blueAccent,
                            ),
                            const SizedBox(height: 16),
                            AlertBentoCard(
                              title: 'Aktivitas Terbaru',
                              count: data.recentActivities.length,
                              description:
                                  'Jumlah transaksi terakhir bulan ini.',
                              icon: Icons.receipt_long_rounded,
                              color: Colors.orange,
                            ),
                          ],
                        ),

                      const SizedBox(height: 32),

                      // QUICK ACTIONS GRID
                      Text(
                        'Aksi Cepat',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isMobile = constraints.maxWidth < 600;
                          if (isMobile) {
                            return Column(
                              children: [
                                QuickActionBento(
                                  label: 'Tambah Penghuni',
                                  icon: Icons.person_add_alt_1_rounded,
                                  color: Colors.blue,
                                  onTap: () {
                                    context.router.navigate(
                                      const ResidentRoute(),
                                    );
                                  },
                                ),
                                const SizedBox(height: 16),
                                QuickActionBento(
                                  label: 'Daftar Tagihan',
                                  icon: Icons.request_quote_rounded,
                                  color: Colors.purple,
                                  onTap: () {
                                    context.router.navigate(
                                      const InvoiceListRoute(),
                                    );
                                  },
                                ),
                                const SizedBox(height: 16),
                                QuickActionBento(
                                  label: 'Catat Pengeluaran',
                                  icon: Icons.payments_rounded,
                                  color: Colors.green,
                                  onTap: () {
                                    context.router.navigate(
                                      const ExpenseListRoute(),
                                    );
                                  },
                                ),
                              ],
                            );
                          }
                          return Row(
                            children: [
                              Expanded(
                                child: QuickActionBento(
                                  label: 'Tambah Penghuni',
                                  icon: Icons.person_add_alt_1_rounded,
                                  color: Colors.blue,
                                  onTap: () {
                                    context.router.navigate(
                                      const ResidentRoute(),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: QuickActionBento(
                                  label: 'Daftar Tagihan',
                                  icon: Icons.request_quote_rounded,
                                  color: Colors.purple,
                                  onTap: () {
                                    context.router.navigate(
                                      const InvoiceListRoute(),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: QuickActionBento(
                                  label: 'Catat Pengeluaran',
                                  icon: Icons.payments_rounded,
                                  color: Colors.green,
                                  onTap: () {
                                    context.router.navigate(
                                      const ExpenseListRoute(),
                                    );
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                      ),

                      // DYNAMIC SECTIONS
                      if (data.isMaintenanceActive == true &&
                          data.recentDamageReports != null) ...[
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Laporan Kerusakan Terbaru',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            TextButton(
                              onPressed: () {
                                context.router.navigate(
                                  const MaintenanceReportListRoute(),
                                );
                              },
                              child: const Text('Lihat Semua'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        BentoContainer(
                          padding: EdgeInsets.zero,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: TableCard(
                              title: 'Keluhan Masuk',
                              columns: const [
                                TableColumn(label: 'Judul', flex: 2),
                                TableColumn(label: 'Kamar'),
                                TableColumn(label: 'Pelapor'),
                                TableColumn(label: 'Tanggal'),
                                TableColumn(label: 'Status'),
                              ],
                              rows: data.recentDamageReports!
                                  .map(
                                    (report) => [
                                      report.title,
                                      report.roomNumber ?? '-',
                                      report.reporterName,
                                      DateFormat(
                                        'dd MMM yyyy',
                                      ).format(report.reportedAt),
                                      _buildStatusBadge(
                                        context,
                                        report.status.toUpperCase(),
                                        report.status.toUpperCase() == 'PENDING'
                                            ? Colors.red
                                            : report.status.toUpperCase() ==
                                                  'IN_PROGRESS'
                                            ? Colors.orange
                                            : Colors.green,
                                      ),
                                    ],
                                  )
                                  .toList(),
                            ),
                          ),
                        ),
                      ],

                      if ((data.isMaintenanceActive == true &&
                              data.maintenanceSchedules != null &&
                              data.maintenanceSchedules!.isNotEmpty) ||
                          (data.isInventoryActive == true &&
                              data.inventorySummary != null)) ...[
                        const SizedBox(height: 32),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final isDesktop = constraints.maxWidth > 900;
                            final widgets = [
                              if (data.isMaintenanceActive == true &&
                                  data.maintenanceSchedules != null &&
                                  data.maintenanceSchedules!.isNotEmpty)
                                Expanded(
                                  flex: isDesktop ? 6 : 1,
                                  child: BentoContainer(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Agenda Pemeliharaan Pekan Ini',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                            Icon(
                                              Icons.calendar_month,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        ...data.maintenanceSchedules!.map((
                                          schedule,
                                        ) {
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 12.0,
                                            ),
                                            child: Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.all(
                                                    8,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary
                                                        .withOpacity(0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    DateFormat(
                                                      'dd\nMMM',
                                                    ).format(
                                                      schedule.startTime,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .labelSmall
                                                        ?.copyWith(
                                                          color: Theme.of(
                                                            context,
                                                          ).colorScheme.primary,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          height: 1.1,
                                                        ),
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        'Teknisi: ${schedule.technicianName}',
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyMedium
                                                            ?.copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                      ),
                                                      Text(
                                                        'Lokasi: ${schedule.location} • ${schedule.type}',
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodySmall
                                                            ?.copyWith(
                                                              color: Theme.of(context)
                                                                  .colorScheme
                                                                  .onSurfaceVariant,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                _buildStatusBadge(
                                                  context,
                                                  schedule.status.toUpperCase(),
                                                  schedule.status
                                                              .toUpperCase() ==
                                                          'DONE'
                                                      ? Colors.green
                                                      : schedule.status
                                                                .toUpperCase() ==
                                                            'CANCELLED'
                                                      ? Colors.red
                                                      : Colors.orange,
                                                ),
                                              ],
                                            ),
                                          );
                                        }),
                                      ],
                                    ),
                                  ),
                                ),
                              if (isDesktop &&
                                  data.isMaintenanceActive == true &&
                                  data.maintenanceSchedules != null &&
                                  data.maintenanceSchedules!.isNotEmpty &&
                                  data.isInventoryActive == true &&
                                  data.inventorySummary != null)
                                const SizedBox(width: 24),
                              if (data.isInventoryActive == true &&
                                  data.inventorySummary != null)
                                Expanded(
                                  flex: isDesktop ? 4 : 1,
                                  child: BentoContainer(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Status Inventaris',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                            Icon(
                                              Icons.inventory,
                                              color: Colors.teal,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 24),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    data
                                                        .inventorySummary!
                                                        .totalItems
                                                        .toString(),
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .headlineMedium
                                                        ?.copyWith(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                  ),
                                                  Text(
                                                    'Total Barang',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium
                                                        ?.copyWith(
                                                          color: Theme.of(context)
                                                              .colorScheme
                                                              .onSurfaceVariant,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              height: 40,
                                              width: 1,
                                              color: Theme.of(
                                                context,
                                              ).dividerColor,
                                            ),
                                            const SizedBox(width: 24),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    data
                                                        .inventorySummary!
                                                        .brokenItems
                                                        .toString(),
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .headlineMedium
                                                        ?.copyWith(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.red,
                                                        ),
                                                  ),
                                                  Text(
                                                    'Rusak',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium
                                                        ?.copyWith(
                                                          color: Theme.of(context)
                                                              .colorScheme
                                                              .onSurfaceVariant,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ];

                            if (isDesktop) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: widgets,
                              );
                            } else {
                              return Column(
                                children: [
                                  if (data.isMaintenanceActive == true &&
                                      data.maintenanceSchedules != null &&
                                      data
                                          .maintenanceSchedules!
                                          .isNotEmpty) ...[
                                    widgets[0],
                                    const SizedBox(height: 24),
                                  ],
                                  if (data.isInventoryActive == true &&
                                      data.inventorySummary != null)
                                    widgets.last,
                                ],
                              );
                            }
                          },
                        ),
                      ],

                      const SizedBox(height: 32),

                      // TABLE SECTION
                      BentoContainer(
                        padding: EdgeInsets.zero,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: TableCard(
                            title: 'Transaksi Terbaru',
                            columns: const [
                              TableColumn(label: 'Tipe', flex: 2),
                              TableColumn(label: 'Kamar'),
                              TableColumn(label: 'Penyewa'),
                              TableColumn(label: 'Tanggal'),
                              TableColumn(label: 'Status'),
                            ],
                            rows: data.recentActivities
                                .map(
                                  (activity) => [
                                    activity.type,
                                    activity.roomNumber ?? '-',
                                    activity.tenantName ?? '-',
                                    DateFormat(
                                      'dd MMM yyyy',
                                    ).format(activity.createdAt),
                                    _buildStatusBadge(
                                      context,
                                      activity.status,
                                      activity.status == 'PAID'
                                          ? Colors.green
                                          : Colors.orange,
                                    ),
                                  ],
                                )
                                .toList(),
                          ),
                        ),
                      ),

                      const SizedBox(height: 48), // Bottom padding
                    ],
                  ),
                );
              },
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildStatusBadge(
    BuildContext context,
    String text,
    MaterialColor color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.shade200),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color.shade700,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
